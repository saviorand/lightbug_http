import testing
from lightbug_http.server import Server


def test_server():
    var server = Server()
    server.set_address("0.0.0.0")
    testing.assert_equal(server.address(), "0.0.0.0")
    server.set_max_request_body_size(1024)
    testing.assert_equal(server.max_request_body_size(), 1024)
    testing.assert_equal(server.get_concurrency(), 1000)

    server = Server(max_concurrent_connections=10)
    testing.assert_equal(server.get_concurrency(), 10)
