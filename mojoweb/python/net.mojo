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
from mojoweb.net import Connection
from mojoweb.strings import NetworkType, CharSet


@value
struct PythonTCPListener(Listener):
    var socket: PythonObject

    fn __init__(inout self):
        ...

    @always_inline
    fn accept(self) raises -> Connection:
        let conn_addr = self.socket.accept()
        # check if the first is laddr and second is raddr
        # py=self.__py.builtins
        return PythonConnection(Tuple(conn_addr))

    fn addr(self) -> Addr:
        ...

    # fn __close_socket(self) raises -> None:
    #     _ = self.socket.close()
    # @always_inline
    # fn __accept_connection(self) raises -> Connection:
    #


struct PythonListenConfig(ListenConfig):
    var __py: PythonObject

    fn __init__(inout self, keep_alive: Duration):
        ...

    fn listen(inout self, network: NetworkType, address: String) raises -> Listener:
        let addr = resolve_internet_addr(network, address)
        var listener = PythonTCPListener()
        listener.socket = self.__py.socket.socket(
            self.__py.socket.AF_INET,
            self.__py.socket.SOCK_STREAM,
        )
        _ = listener.socket.bind((addr.ip, addr.port))
        _ = listener.socket.listen()


struct PythonConnection(Connection):
    var pymodules: Modules
    var conn: PythonObject
    var addr: PythonObject

    fn __init__(inout self, conn_addr: Tuple) raises:
        let py_conn_addr = PythonObject(conn_addr)
        self.conn = py_conn_addr[0]
        self.addr = py_conn_addr[1]
        self.pymodules = Modules()

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


struct PythonNet(Net):
    var lc: PythonListenConfig

    fn __init__(inout self, keep_alive: Duration):
        self.lc = PythonListenConfig(keep_alive)

    fn listen(self, network: NetworkType, addr: String) raises -> Listener:
        return self.lc.listen(network, addr)
