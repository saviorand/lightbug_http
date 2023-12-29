from mojoweb.strings import NetworkType
from mojoweb.io.bytes import Bytes
from mojoweb.io.sync import Duration


trait Net:
    fn listen(self, network: NetworkType, addr: String) raises -> Listener:
        ...


trait ListenConfig:
    fn __init__(inout self, keep_alive: Duration):
        # TODO: support mptcp?
        ...

    fn listen(self, network: NetworkType, address: String) raises -> Listener:
        ...

    # fn control(self, network: NetworkType, address: String) raises -> None:
    #     ...


trait Listener(CollectionElement):
    fn __init__(inout self, value: String):
        ...

    fn accept(self) raises -> Connection:
        ...

    fn addr(self) -> Addr:
        ...


trait Connection:
    fn __init__(inout self, laddr: Addr, raddr: Addr):
        ...

    fn read(self, buf: Bytes) raises -> Int:
        ...

    fn write(self, buf: Bytes) raises -> Int:
        ...

    fn close(self) raises:
        ...

    fn local_addr(self) -> Addr:
        ...

    fn remote_addr(self) -> Addr:
        ...


alias TCPAddrList = DynamicVector[TCPAddr]


trait Addr(CollectionElement):
    fn __init__(inout self):
        ...

    fn __init__(inout self, ip: String, port: Int):
        ...

    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...


fn join_host_port(host: String, port: String) -> String:
    if host.find(":") != -1:  # must be IPv6 literal
        return "[" + host + "]:" + port
    return host + ":" + port


@value
struct TCPAddr(Addr):
    var __string: String
    var ip: Bytes
    var port: Int
    var zone: String  # IPv6 addressing zone

    fn __init__(inout self):
        # TODO: do these defaults make sense?
        self.ip = String("127.0.0.1")._buffer
        self.port = 80

    fn __init__(inout self, ip: String, port: Int):
        self.ip = ip._buffer
        self.port = port

    fn network(self) -> String:
        return NetworkType.tcp.value

    fn string(self) -> String:
        if self.zone != "":
            return join_host_port(String(self.ip) + "%" + self.zone, self.port)
        return join_host_port(self.ip, self.port)
