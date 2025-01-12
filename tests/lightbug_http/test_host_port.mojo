import testing
from lightbug_http.net import join_host_port, HostPort, TCPAddr
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
