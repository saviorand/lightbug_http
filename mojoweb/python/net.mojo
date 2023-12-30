from mojoweb.python import Modules
from mojoweb.io.bytes import Bytes, python_bytes_to_bytes
from mojoweb.io.sync import Duration
from mojoweb.net import (
    Net,
    Addr,
    Listener,
    ListenConfig,
    resolve_internet_addr,
    default_buffer_size,
)
from mojoweb.http import Request, Response
from mojoweb.service import Service
from mojoweb.net import Connection, default_tcp_keep_alive
from mojoweb.strings import NetworkType, CharSet


# TODO: This should implement Listener once Mojo supports returning generics
@value
struct PythonTCPListener(CollectionElement):
    var pymodules: PythonObject
    var socket: PythonObject

    fn __init__(inout self, pymodules: PythonObject) raises:
        self.pymodules = pymodules

    @always_inline
    fn accept(self) raises -> PythonConnection:
        let conn_addr = self.socket.accept()
        return PythonConnection(self.pymodules, Tuple(conn_addr))

    fn close(self) raises:
        _ = self.socket.close()

    fn addr(self) -> Addr:
        ...


struct PythonListenConfig:
    var keep_alive: Duration
    var pymodules: PythonObject

    fn __init__(inout self) raises:
        self.keep_alive = Duration(default_tcp_keep_alive)
        self.pymodules = Modules().builtins

    fn __init__(inout self, keep_alive: Duration) raises:
        self.keep_alive = keep_alive
        self.pymodules = Modules().builtins

    fn listen(
        inout self, network: NetworkType, address: String
    ) raises -> PythonTCPListener:
        let addr = resolve_internet_addr(network, address)
        var listener = PythonTCPListener(self.pymodules)
        listener.socket = self.pymodules.socket.socket(
            self.pymodules.socket.AF_INET,
            self.pymodules.socket.SOCK_STREAM,
        )
        _ = listener.socket.bind((addr.ip, addr.port))
        _ = listener.socket.listen()
        return listener


struct PythonConnection:
    var pymodules: PythonObject
    var conn: PythonObject
    var addr: PythonObject

    fn __init__(inout self, pymodules: PythonObject, conn_addr: Tuple) raises:
        let py_conn_addr = PythonObject(conn_addr)
        self.conn = py_conn_addr[0]
        self.addr = py_conn_addr[1]
        self.pymodules = pymodules

    fn read(self, inout buf: Bytes) raises -> Int:
        let data = self.conn.recv(default_buffer_size)
        python_bytes_to_bytes(buf, data)
        return len(buf)

    fn write(self, buf: Bytes) raises -> Int:
        _ = self.conn.sendall(
            self.pymodules.builtins.bytes(String(buf), CharSet.utf8.value)
        )
        return len(buf)

    fn close(self) raises:
        _ = self.conn.close()

    fn local_addr(self) -> Addr:
        ...

    fn remote_addr(self) -> Addr:
        ...


struct PythonNet:
    var lc: PythonListenConfig

    fn __init__(inout self, keep_alive: Duration) raises:
        self.lc = PythonListenConfig(keep_alive)

    fn listen(
        inout self, network: NetworkType, addr: String
    ) raises -> PythonTCPListener:
        return self.lc.listen(network, addr)
