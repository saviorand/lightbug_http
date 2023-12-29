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


alias AddrList = DynamicVector[Addr]


@value
struct Addr(CollectionElement):
    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...


fn resolve_addr_list(network: NetworkType, address: String) raises -> AddrList:
    ...
