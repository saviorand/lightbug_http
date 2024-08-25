@value
struct NetworkType:
    var value: String

    alias empty = NetworkType("")
    alias tcp = NetworkType("tcp")
    alias tcp4 = NetworkType("tcp4")
    alias tcp6 = NetworkType("tcp6")
    alias udp = NetworkType("udp")
    alias udp4 = NetworkType("udp4")
    alias udp6 = NetworkType("udp6")
    alias ip = NetworkType("ip")
    alias ip4 = NetworkType("ip4")
    alias ip6 = NetworkType("ip6")
    alias unix = NetworkType("unix")


trait Addr(CollectionElement, Stringable):
    fn network(self) -> String:
        """Name of the network (for example, "tcp", "udp")."""
        ...


@value
struct BaseAddr:
    """Addr struct representing a TCP address.

    Args:
        ip: IP address.
        port: Port number.
        zone: IPv6 addressing zone.
    """

    var ip: String
    var port: Int
    var zone: String  # IPv6 addressing zone

    fn __init__(inout self, ip: String = "", port: Int = 0, zone: String = ""):
        self.ip = ip
        self.port = port
        self.zone = zone

    fn __init__(inout self, other: TCPAddr):
        self.ip = other.ip
        self.port = other.port
        self.zone = other.zone

    fn __init__(inout self, other: UDPAddr):
        self.ip = other.ip
        self.port = other.port
        self.zone = other.zone

    fn __str__(self) -> String:
        if self.zone != "":
            return join_host_port(self.ip + "%" + self.zone, str(self.port))
        return join_host_port(self.ip, str(self.port))


fn resolve_internet_addr(network: String, address: String) -> (TCPAddr, Error):
    var host: String = ""
    var port: String = ""
    var portnum: Int = 0
    var err = Error()
    if (
        network == NetworkType.tcp.value
        or network == NetworkType.tcp4.value
        or network == NetworkType.tcp6.value
        or network == NetworkType.udp.value
        or network == NetworkType.udp4.value
        or network == NetworkType.udp6.value
    ):
        if address != "":
            var result = split_host_port(address)
            if result[1]:
                return TCPAddr(), result[1]

            host = result[0].host
            port = str(result[0].port)
            portnum = result[0].port
    elif network == NetworkType.ip.value or network == NetworkType.ip4.value or network == NetworkType.ip6.value:
        if address != "":
            host = address
    elif network == NetworkType.unix.value:
        return TCPAddr(), Error("Unix addresses not supported yet")
    else:
        return TCPAddr(), Error("unsupported network type: " + network)
    return TCPAddr(host, portnum), err


alias MISSING_PORT_ERROR = Error("missing port in address")
alias TOO_MANY_COLONS_ERROR = Error("too many colons in address")


@value
struct HostPort(Stringable):
    var host: String
    var port: Int

    fn __init__(inout self, host: String = "", port: Int = 0):
        self.host = host
        self.port = port

    fn __str__(self) -> String:
        return join_host_port(self.host, str(self.port))


fn join_host_port(host: String, port: String) -> String:
    if host.find(":") != -1:  # must be IPv6 literal
        return "[" + host + "]:" + port
    return host + ":" + port


fn split_host_port(hostport: String) -> (HostPort, Error):
    var host: String = ""
    var port: String = ""
    var colon_index = hostport.rfind(":")
    var j: Int = 0
    var k: Int = 0

    if colon_index == -1:
        return HostPort(), MISSING_PORT_ERROR
    if hostport[0] == "[":
        var end_bracket_index = hostport.find("]")
        if end_bracket_index == -1:
            return HostPort(), Error("missing ']' in address")
        if end_bracket_index + 1 == len(hostport):
            return HostPort(), MISSING_PORT_ERROR
        elif end_bracket_index + 1 == colon_index:
            host = hostport[1:end_bracket_index]
            j = 1
            k = end_bracket_index + 1
        else:
            if hostport[end_bracket_index + 1] == ":":
                return HostPort(), TOO_MANY_COLONS_ERROR
            else:
                return HostPort(), MISSING_PORT_ERROR
    else:
        host = hostport[:colon_index]
        if host.find(":") != -1:
            return HostPort(), TOO_MANY_COLONS_ERROR
    if hostport[j:].find("[") != -1:
        return HostPort(), Error("unexpected '[' in address")
    if hostport[k:].find("]") != -1:
        return HostPort(), Error("unexpected ']' in address")
    port = hostport[colon_index + 1 :]

    if port == "":
        return HostPort(), MISSING_PORT_ERROR
    if host == "":
        return HostPort(), Error("missing host")

    try:
        return HostPort(host, atol(port)), Error()
    except e:
        return HostPort(), e
