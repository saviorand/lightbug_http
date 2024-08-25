from lightbug_http.python import Modules
from lightbug_http.io.bytes import Bytes, UnsafeString, bytes
from lightbug_http.io.sync import Duration
from lightbug_http.net import (
    Net,
    TCPAddr,
    Listener,
    ListenConfig,
    resolve_internet_addr,
    default_buffer_size,
)
from lightbug_http.net import Connection, default_tcp_keep_alive
from lightbug_http.strings import CharSet


@value
struct PythonTCPListener:
    var __pymodules: PythonObject
    var __addr: TCPAddr
    var socket: PythonObject

    fn __init__(inout self) raises:
        self.__pymodules = None
        self.__addr = TCPAddr("localhost", 8080)
        self.socket = None

    fn __init__(inout self, addr: TCPAddr) raises:
        self.__pymodules = None
        self.__addr = addr
        self.socket = None

    fn __init__(inout self, pymodules: PythonObject, addr: TCPAddr) raises:
        self.__pymodules = pymodules
        self.__addr = addr
        self.socket = None

    fn __init__(
        inout self, pymodules: PythonObject, addr: TCPAddr, socket: PythonObject
    ) raises:
        self.__pymodules = pymodules
        self.__addr = addr
        self.socket = socket

    @always_inline
    fn accept(self) raises -> PythonConnection:
        var conn_addr = self.socket.accept()
        return PythonConnection(self.__pymodules, conn_addr)

    fn close(self) raises:
        if self.socket == None:
            raise Error("socket is None, cannot close")
        _ = self.socket.close()

    fn addr(self) -> TCPAddr:
        return self.__addr


struct PythonListenConfig:
    var __pymodules: Modules
    var __keep_alive: Duration

    fn __init__(inout self):
        self.__keep_alive = default_tcp_keep_alive
        self.__pymodules = Modules()

    fn __init__(inout self, keep_alive: Duration):
        self.__keep_alive = keep_alive
        self.__pymodules = Modules()

    fn listen(inout self, network: String, address: String) raises -> PythonTCPListener:
        var addr = resolve_internet_addr(network, address)
        var listener = PythonTCPListener(
            self.__pymodules.builtins,
            addr,
            self.__pymodules.socket.socket(
                self.__pymodules.socket.AF_INET,
                self.__pymodules.socket.SOCK_STREAM,
            ),
        )
        _ = listener.socket.bind((UnsafeString(addr.ip), addr.port))
        _ = listener.socket.listen()
        print("Listening on " + addr.ip + ":" + addr.port.__str__())
        return listener


@value
struct PythonConnection(Connection):
    var pymodules: PythonObject
    var conn: PythonObject
    var raddr: PythonObject
    var laddr: PythonObject

    fn __init__(inout self, laddr: String, raddr: String) raises:
        self.conn = None
        self.raddr = PythonObject(raddr)
        self.laddr = PythonObject(laddr)
        self.pymodules = Modules().builtins

    fn __init__(inout self, laddr: TCPAddr, raddr: TCPAddr) raises:
        self.conn = None
        self.raddr = PythonObject(raddr.ip + ":" + raddr.port.__str__())
        self.laddr = PythonObject(laddr.ip + ":" + laddr.port.__str__())
        self.pymodules = Modules().builtins

    fn __init__(inout self, pymodules: PythonObject, py_conn_addr: PythonObject) raises:
        self.conn = py_conn_addr[0]
        self.raddr = py_conn_addr[1]
        self.laddr = ""
        self.pymodules = pymodules

    fn read(self, inout buf: Bytes) raises -> Int:
        var data = self.conn.recv(default_buffer_size)
        buf = bytes(
            self.pymodules.bytes.decode(data, CharSet.utf8.value).__str__()
        )
        return len(buf)

    fn write(self, buf: Bytes) raises -> Int:
        var data = self.pymodules.bytes(String(buf), CharSet.utf8.value)
        _ = self.conn.sendall(data)
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

    fn __init__(inout self):
        self.__lc = PythonListenConfig(default_tcp_keep_alive)

    fn __init__(inout self, keep_alive: Duration) raises:
        self.__lc = PythonListenConfig(keep_alive)

    fn listen(inout self, network: String, addr: String) raises -> PythonTCPListener:
        return self.__lc.listen(network, addr)
