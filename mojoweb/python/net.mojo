from mojoweb.python import Modules
from mojoweb.io.bytes import Bytes
from mojoweb.net import Net, Addr, Listener
from mojoweb.http import Request, Response
from mojoweb.service import Service
from mojoweb.net import Connection
from mojoweb.strings import NetworkType


@value
struct PythonListener(Listener):
    var value: String

    fn __init__(inout self, value: String):
        self.value = value


struct PythonConnection(Connection):
    # var conn: PythonObject
    # var addr: PythonObject
    # var __py: PythonObject
    fn __init__(inout self, laddr: Addr, raddr: Addr):
        ...
        #         self.__py = py

    fn read(self, buf: Bytes) raises -> Int:
        ...
        #     fn recieve_data(
        #     self, size: Int = 1024, encoding: StringLiteral = "utf-8"
        # ) raises -> String:
        #     let data = self.conn.recv(size).decode(encoding)
        #     return str(data)

    fn write(self, buf: Bytes) raises -> Int:
        ...
        # let response_bytes = response.to_bytes(py_builtins=self.__py)
        # _ = self.conn.sendall(response_bytes)

    fn close(self) raises:
        ...
        # _ = self.conn.close()

    fn local_addr(self) -> Addr:
        ...

    fn remote_addr(self) -> Addr:
        ...


struct PythonNet(Net):
    fn listen(self, network: NetworkType, addr: String) -> Listener:
        ...
