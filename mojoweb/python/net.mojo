from mojoweb.python import Modules
from mojoweb.io.bytes import Bytes, python_bytes_to_bytes
from mojoweb.io.sync import Duration
from mojoweb.net import (
    Net,
    TCPAddr,
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
    var __pymodules: PythonObject
    var __addr: TCPAddr
    var socket: PythonObject

    fn __init__(inout self, pymodules: PythonObject, addr: TCPAddr) raises:
        self.__pymodules = pymodules
        self.__addr = addr
        self.socket = None

    @always_inline
    fn accept(self) raises -> PythonConnection:
        if self.socket == None:
            raise Error("socket is None, cannot accept")
        let conn_addr = self.socket.accept()
        return PythonConnection(self.__pymodules, Tuple(conn_addr))

    fn close(self) raises:
        if self.socket == None:
            raise Error("socket is None, cannot close")
        _ = self.socket.close()

    fn addr(self) -> TCPAddr:
        return self.__addr


@value
struct PythonListenConfig:
    var __pymodules: PythonObject
    var __keep_alive: Duration

    fn __init__(inout self) raises:
        self.__keep_alive = Duration(default_tcp_keep_alive)
        self.__pymodules = Modules().builtins

    fn __init__(inout self, keep_alive: Duration) raises:
        self.__keep_alive = Duration(keep_alive)
        self.__pymodules = Modules().builtins

    fn listen(
        inout self, network: NetworkType, address: String
    ) raises -> PythonTCPListener:
        let addr = resolve_internet_addr(network, address)
        var listener = PythonTCPListener(self.__pymodules, addr)
        listener.socket = self.__pymodules.socket.socket(
            self.__pymodules.socket.AF_INET,
            self.__pymodules.socket.SOCK_STREAM,
        )
        _ = listener.socket.bind((addr.ip, addr.port))
        _ = listener.socket.listen()
        return listener


struct PythonConnection:
    var pymodules: PythonObject
    var conn: PythonObject
    var raddr: PythonObject
    var laddr: PythonObject

    fn __init__(inout self, pymodules: PythonObject, conn_addr: Tuple) raises:
        let py_conn_addr = PythonObject(conn_addr)
        self.conn = py_conn_addr[0]
        self.raddr = py_conn_addr[1]
        self.laddr = ""
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

    fn local_addr(inout self) raises -> TCPAddr:
        if self.laddr.__str__() == "":
            self.laddr = self.conn.getsockname()
        return TCPAddr(self.laddr[0].__str__(), self.laddr[1].__int__())

    fn remote_addr(self) raises -> TCPAddr:
        return TCPAddr(self.raddr[0].__str__(), self.raddr[1].__int__())


struct PythonNet:
    var __lc: PythonListenConfig

    fn __init__(inout self) raises:
        self.__lc = PythonListenConfig(default_tcp_keep_alive)

    fn __init__(inout self, keep_alive: Duration) raises:
        self.__lc = PythonListenConfig(keep_alive)

    fn listen(
        inout self, network: NetworkType, addr: String
    ) raises -> PythonTCPListener:
        return self.__lc.listen(network, addr)
