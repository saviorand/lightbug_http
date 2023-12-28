from mojoweb.strings import NetworkType
from mojoweb.io.bytes import Bytes


trait Listener(CollectionElement):
    fn __init__(inout self, value: String):
        ...


trait Connection:
    fn __init__(inout self, laddr: Addr, raddr: Addr):
        ...

    fn read(self, buf: Bytes) raises -> Int:
        ...

    fn write(self, buf: Bytes) raises -> Int:
        ...

    fn local_addr(self) -> Addr:
        ...

    fn remote_addr(self) -> Addr:
        ...


trait Addr:
    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...


trait Net:
    fn listen(self, network: NetworkType, addr: String) -> Listener:
        ...


@value
struct TCPAddr(Addr):
    var ip: String
    var port: Int

    fn __init__(inout self):
        # TODO: do these defaults make sense?
        self.ip = "127.0.0.1"
        self.port = 80

    fn __init__(inout self, ip: String, port: Int):
        self.ip = ip
        self.port = port

    fn network(self) -> String:
        return "tcp"

    fn string(self) -> String:
        return self.ip + ":" + self.port
