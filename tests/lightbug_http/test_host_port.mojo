import testing
from lightbug_http.net import resolve_internet_addr, join_host_port, HostPort, TCPAddr
from lightbug_http.strings import NetworkType


def test_split_host_port():
    # IPv4
    var hp = HostPort.from_string("127.0.0.1:8080")
    testing.assert_equal(hp.host, "127.0.0.1")
    testing.assert_equal(hp.port, 8080)

    # IPv6
    hp = HostPort.from_string("[::1]:8080")
    testing.assert_equal(hp.host, "::1")
    testing.assert_equal(hp.port, 8080)

    # # TODO: IPv6 long form - Not supported yet.
    # hp = HostPort.from_string("0:0:0:0:0:0:0:1:8080")
    # testing.assert_equal(hp.host, "0:0:0:0:0:0:0:1")
    # testing.assert_equal(hp.port, 8080)


def test_join_host_port():
    # IPv4
    testing.assert_equal(join_host_port("127.0.0.1", "8080"), "127.0.0.1:8080")

    # IPv6
    testing.assert_equal(join_host_port("::1", "8080"), "[::1]:8080")

    # TODO: IPv6 long form - Not supported yet.


def test_resolve_internet_addr():
    # TCP/UDP
    alias address = "127.0.0.1:8080"
    alias addr = TCPAddr("127.0.0.1", 8080, "")
    testing.assert_true(resolve_internet_addr[NetworkType.tcp](address) == addr)
    testing.assert_true(resolve_internet_addr[NetworkType.tcp4](address) == addr)
    testing.assert_true(resolve_internet_addr[NetworkType.tcp6](address) == addr)
    testing.assert_true(resolve_internet_addr[NetworkType.udp](address) == addr)
    testing.assert_true(resolve_internet_addr[NetworkType.udp4](address) == addr)
    testing.assert_true(resolve_internet_addr[NetworkType.udp6](address) == addr)

    # IP
    alias ip_address = "127.0.0.1"
    alias ip_addr = TCPAddr("127.0.0.1", 0)
    testing.assert_true(resolve_internet_addr[NetworkType.ip](ip_address) == ip_addr)
    testing.assert_true(resolve_internet_addr[NetworkType.ip4](ip_address) == ip_addr)
    testing.assert_true(resolve_internet_addr[NetworkType.ip6](ip_address) == ip_addr)
