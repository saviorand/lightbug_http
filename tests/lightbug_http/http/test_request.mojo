import testing
from lightbug_http.http import HTTPRequest, StatusCode
from lightbug_http.strings import to_string


def test_request_from_bytes():
    alias data = "GET /redirect HTTP/1.1\r\nHost: 127.0.0.1:8080\r\nUser-Agent: python-requests/2.32.3\r\nAccept-Encoding: gzip, deflate, br, zstd\r\nAccept: */*\r\nconnection: keep-alive\r\n\r\n"
    var request = HTTPRequest.from_bytes("127.0.0.1", 4096, data.as_bytes())
    testing.assert_equal(request.protocol, "HTTP/1.1")
    testing.assert_equal(request.method, "GET")
    testing.assert_equal(request.uri.request_uri, "/redirect")
    testing.assert_equal(request.headers["Host"], "127.0.0.1:8080")
    testing.assert_equal(request.headers["User-Agent"], "python-requests/2.32.3")

    testing.assert_false(request.connection_close())
    request.set_connection_close()
    testing.assert_true(request.connection_close())


def test_read_body():
    alias data = "GET /redirect HTTP/1.1\r\nHost: 127.0.0.1:8080\r\nUser-Agent: python-requests/2.32.3\r\nAccept-Encoding: gzip, deflate, br, zstd\r\nAccept: */\r\nContent-Length: 17\r\nconnection: keep-alive\r\n\r\nThis is the body!"
    var request = HTTPRequest.from_bytes("127.0.0.1", 4096, data.as_bytes())
    testing.assert_equal(request.protocol, "HTTP/1.1")
    testing.assert_equal(request.method, "GET")
    testing.assert_equal(request.uri.request_uri, "/redirect")
    testing.assert_equal(request.headers["Host"], "127.0.0.1:8080")
    testing.assert_equal(request.headers["User-Agent"], "python-requests/2.32.3")

    testing.assert_equal(request.get_body(), "This is the body!")


def test_encode():
    ...
