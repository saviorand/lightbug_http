from testing import assert_equal, assert_true
from lightbug_http.utils import ByteReader
from lightbug_http.header import Headers, Header
from lightbug_http.cookie import Cookie
from lightbug_http.io.bytes import Bytes, bytes


def test_header_case_insensitive():
    var headers = Headers(Header("Host", "SomeHost"))
    assert_true("host" in headers)
    assert_true("HOST" in headers)
    assert_true("hOST" in headers)
    assert_equal(headers["Host"], "SomeHost")
    assert_equal(headers["host"], "SomeHost")


def test_parse_request_header():
    var headers_str = bytes(
        """GET /index.html HTTP/1.1\r\nHost:example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n"""
    )
    var header = Headers()
    var b = Bytes(headers_str)
    var reader = ByteReader(b^)
    var method: String
    var protocol: String
    var uri: String
    method, uri, protocol = header.parse_raw(reader)
    assert_equal(uri, "/index.html")
    assert_equal(protocol, "HTTP/1.1")
    assert_equal(method, "GET")
    assert_equal(header["Host"], "example.com")
    assert_equal(header["User-Agent"], "Mozilla/5.0")
    assert_equal(header["Content-Type"], "text/html")
    assert_equal(header["Content-Length"], "1234")
    assert_equal(header["Connection"], "close")


def test_parse_response_header():
    var headers_str = bytes(
        """HTTP/1.1 200 OK\r\nServer: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Encoding: gzip\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n"""
    )
    var header = Headers()
    var protocol: String
    var status_code: String
    var status_text: String
    var reader = ByteReader(headers_str^)
    protocol, status_code, status_text = header.parse_raw(reader)
    assert_equal(protocol, "HTTP/1.1")
    assert_equal(status_code, "200")
    assert_equal(status_text, "OK")
    assert_equal(header["Server"], "example.com")
    assert_equal(header["Content-Type"], "text/html")
    assert_equal(header["Content-Encoding"], "gzip")
    assert_equal(header["Content-Length"], "1234")
    assert_equal(header["Connection"], "close")
    assert_equal(header["Trailer"], "end-of-message")


def test_cookie_header():
    var headers = Headers(Cookie("mycookie", "myvalue").to_header())
    assert_true = ("Set-Cookie" in headers)
    assert_equal(headers["Set-Cookie"], "mycookie=myvalue")
