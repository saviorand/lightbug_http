from external.gojo.tests.wrapper import MojoTest
from external.gojo.bytes import buffer
from external.gojo.bufio import Reader
from lightbug_http.header import RequestHeader, ResponseHeader
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.strings import empty_string 
from lightbug_http.net import default_buffer_size

def test_header():
    test_parse_request_header()
    test_parse_response_header()

def test_parse_request_header():
    var test = MojoTest("test_parse_request_header")
    var headers_str = bytes('''GET /index.html HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n''')
    var header = RequestHeader()
    var b = Bytes(headers_str)
    var buf = buffer.new_buffer(b^)
    var reader = Reader(buf^)
    _ = header.parse_raw(reader)
    test.assert_equal(String(header.request_uri()), "/index.html")
    test.assert_equal(String(header.protocol()), "HTTP/1.1")
    test.assert_equal(header.no_http_1_1, False)
    test.assert_equal(String(header.host()), String("example.com"))
    test.assert_equal(String(header.user_agent()), "Mozilla/5.0")
    test.assert_equal(String(header.content_type()), "text/html")
    test.assert_equal(header.content_length(), 1234)
    test.assert_equal(header.connection_close(), True)

def test_parse_response_header():
    var test = MojoTest("test_parse_response_header")
    var headers_str = bytes('''HTTP/1.1 200 OK\r\nServer: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Encoding: gzip\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n''')
    var header = ResponseHeader()
    var b = Bytes(headers_str)
    var buf = buffer.new_buffer(b^)
    var reader = Reader(buf^)
    _ = header.parse_raw(reader)
    test.assert_equal(String(header.protocol()), "HTTP/1.1")
    test.assert_equal(header.no_http_1_1, False)
    test.assert_equal(header.status_code(), 200)
    test.assert_equal(String(header.status_message()), "OK")
    test.assert_equal(String(header.server()), "example.com")
    test.assert_equal(String(header.content_type()), "text/html")
    test.assert_equal(String(header.content_encoding()), "gzip")
    test.assert_equal(header.content_length(), 1234)
    test.assert_equal(header.connection_close(), True)
    test.assert_equal(header.trailer_str(), "end-of-message")
