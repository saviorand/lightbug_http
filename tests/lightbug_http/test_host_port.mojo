import testing
from lightbug_http.net import join_host_port, parse_address, TCPAddr
from lightbug_http.strings import NetworkType


def test_split_host_port():
    # IPv4
    var hp = parse_address("127.0.0.1:8080")
    testing.assert_equal(hp[0], "127.0.0.1")
    testing.assert_equal(hp[1], 8080)

    # IPv6
    hp = parse_address("[::1]:8080")
    testing.assert_equal(hp[0], "::1")
    testing.assert_equal(hp[1], 8080)

    # # TODO: IPv6 long form - Not supported yet.
    # hp = parse_address("0:0:0:0:0:0:0:1:8080")
    # testing.assert_equal(hp[0], "0:0:0:0:0:0:0:1")
    # testing.assert_equal(hp[1], 8080)


def test_join_host_port():
    # IPv4
    testing.assert_equal(join_host_port("127.0.0.1", "8080"), "127.0.0.1:8080")

    # IPv6
    testing.assert_equal(join_host_port("::1", "8080"), "[::1]:8080")

    # TODO: IPv6 long form - Not supported yet.
