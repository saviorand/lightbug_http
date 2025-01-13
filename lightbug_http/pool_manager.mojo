from sys.ffi import OpaquePointer
from bit import is_power_of_two
from builtin.value import StringableCollectionElement
from memory import UnsafePointer, bitcast, memcpy
from collections import Dict, Optional
from collections.dict import RepresentableKeyElement
from lightbug_http.net import create_connection, TCPConnection, Connection
from lightbug_http.utils import logger
from lightbug_http.owning_list import OwningList


struct PoolManager[ConnectionType: Connection]():
    var _connections: OwningList[ConnectionType]
    var _capacity: Int
    var mapping: Dict[String, Int]

    fn __init__(out self, capacity: Int = 10):
        self._connections = OwningList[ConnectionType](capacity=capacity)
        self._capacity = capacity
        self.mapping = Dict[String, Int]()

    fn __del__(owned self):
        logger.debug(
            "PoolManager shutting down and closing remaining connections before destruction:", self._connections.size
        )
        self.clear()

    fn give(mut self, host: String, owned value: ConnectionType) raises:
        if host in self.mapping:
            self._connections[self.mapping[host]] = value^
            return

        if self._connections.size == self._capacity:
            raise Error("PoolManager.give: Cache is full.")

        self._connections[self._connections.size] = value^
        self.mapping[host] = self._connections.size
        self._connections.size += 1
        logger.debug("Checked in connection for peer:", host + ", at index:", self._connections.size)

    fn take(mut self, host: String) raises -> ConnectionType:
        var index: Int
        try:
            index = self.mapping[host]
            _ = self.mapping.pop(host)
        except:
            raise Error("PoolManager.take: Key not found.")

        var connection = self._connections.pop(index)
        #  Shift everything over by one
        for kv in self.mapping.items():
            if kv[].value > index:
                self.mapping[kv[].key] -= 1

        logger.debug("Checked out connection for peer:", host + ", from index:", self._connections.size + 1)
        return connection^

    fn clear(mut self):
        while self._connections:
            var connection = self._connections.pop(0)
            try:
                connection.teardown()
            except e:
                # TODO: This is used in __del__, would be nice if we didn't have to absorb the error.
                logger.error("Failed to tear down connection. Error:", e)
        self.mapping.clear()

    fn __contains__(self, host: String) -> Bool:
        return host in self.mapping

    fn __setitem__(mut self, host: String, owned value: ConnectionType) raises -> None:
        if host in self.mapping:
            self._connections[self.mapping[host]] = value^
        else:
            self.give(host, value^)

    fn __getitem__(self, host: String) raises -> ref [self._connections] ConnectionType:
        return self._connections[self.mapping[host]]
