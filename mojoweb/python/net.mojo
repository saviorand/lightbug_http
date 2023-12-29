from mojoweb.python import Modules
from mojoweb.io.bytes import Bytes
from mojoweb.io.sync import Duration
from mojoweb.net import Net, Addr, Listener, ListenConfig, resolve_internet_addr
from mojoweb.http import Request, Response
from mojoweb.service import Service
from mojoweb.net import Connection
from mojoweb.strings import NetworkType


@value
struct PythonTCPListener(Listener):
    fn __init__(inout self, value: String):
        ...

    fn accept(self) raises -> Connection:
        ...

    fn addr(self) -> Addr:
        ...


struct PythonListenConfig(ListenConfig):
    var __py: PythonObject
    var socket: PythonObject

    fn __init__(inout self, keep_alive: Duration):
        ...

    fn listen(inout self, network: NetworkType, address: String) raises -> Listener:
        let addr = resolve_internet_addr(network, address)
        self.socket = self.__py.socket.socket(
            self.__py.socket.AF_INET,
            self.__py.socket.SOCK_STREAM,
        )
        _ = self.socket.bind((addr.ip, addr.port))
        _ = self.socket.listen()

    # fn control(self, network: NetworkType, address: String) raises -> None:
    #     ...


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
    var lc: PythonListenConfig

    fn __init__(inout self, keep_alive: Duration):
        self.lc = PythonListenConfig(keep_alive)

    fn listen(self, network: NetworkType, addr: String) raises -> Listener:
        return self.lc.listen(network, addr)
