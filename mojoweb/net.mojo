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


trait Addr(CollectionElement):
    fn __init__(inout self):
        ...

    fn __init__(inout self, ip: String, port: Int):
        ...

    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...


alias TCPAddrList = DynamicVector[TCPAddr]


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


# This should return a TCPAddrList, but we don't support that yet
fn resolve_internet_addr(network: NetworkType, address: String) raises -> TCPAddr:
    let network_str = network.value
    var host: String
    var port: String
    var portnum: Int
    if (
        network_str == NetworkType.tcp.value
        or network_str == NetworkType.tcp4.value
        or network_str == NetworkType.tcp6.value
        or network_str == NetworkType.udp.value
        or network_str == NetworkType.udp4.value
        or network_str == NetworkType.udp6.value
    ):
        if address != "":
            let host_port = split_host_port(address)
            host = host_port.get[0, StringLiteral]()
            port = host_port.get[1, StringLiteral]()
            portnum = atol(port.__str__())
    elif (
        network_str == NetworkType.ip.value
        or network_str == NetworkType.ip4.value
        or network_str == NetworkType.ip6.value
    ):
        if address != "":
            host = address
    elif network_str == NetworkType.unix.value:
        raise Error("Unix addresses not supported yet")
    else:
        raise Error("unsupported network type: " + network_str)
    # var list = TCPAddrList()
    # list.append(TCPAddr(host, portnum))
    return TCPAddr(host, portnum)


fn join_host_port(host: String, port: String) -> String:
    if host.find(":") != -1:  # must be IPv6 literal
        return "[" + host + "]:" + port
    return host + ":" + port


alias missingPortError = Error("missing port in address")
alias tooManyColonsError = Error("too many colons in address")


fn split_host_port(hostport: String) raises -> (String, String):
    var host: String
    var port: String
    let colon_index = hostport.rfind(":")
    var j: Int = 0
    var k: Int = 0

    if colon_index == -1:
        raise missingPortError
    if hostport[0] == "[":
        let end_bracket_index = hostport.find("]")
        if end_bracket_index == -1:
            raise Error("missing ']' in address")
        if end_bracket_index + 1 == len(hostport):
            raise missingPortError
        elif end_bracket_index + 1 == colon_index:
            host = hostport[1:end_bracket_index]
            j = 1
            k = end_bracket_index + 1
        else:
            if hostport[end_bracket_index + 1] == ":":
                raise tooManyColonsError
            else:
                raise missingPortError
    else:
        host = hostport[:colon_index]
        if host.find(":") != -1:
            raise tooManyColonsError
    if hostport[j:].find("[") != -1:
        raise Error("unexpected '[' in address")
    if hostport[k:].find("]") != -1:
        raise Error("unexpected ']' in address")
    port = hostport[colon_index + 1 :]

    return host, port
