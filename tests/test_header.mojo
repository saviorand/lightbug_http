import testing
from gojo.bytes import buffer
from gojo.bufio import Reader
from lightbug_http.header import RequestHeader, ResponseHeader
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.strings import empty_string 
from lightbug_http.net import default_buffer_size

def test_header():
    test_parse_request_header()
    test_parse_response_header()

def test_parse_request_header():
    var headers_str = bytes('''GET /index.html HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n''')
    var header = RequestHeader()
    var b = Bytes(headers_str)
    var buf = buffer.Buffer(b^)
    var reader = Reader(buf^)
    _ = header.parse_raw(reader)
    testing.assert_equal(String(header.request_uri()), "/index.html")
    testing.assert_equal(String(header.protocol()), "HTTP/1.1")
    testing.assert_equal(header.no_http_1_1, False)
    testing.assert_equal(String(header.host()), String("example.com"))
    testing.assert_equal(String(header.user_agent()), "Mozilla/5.0")
    testing.assert_equal(String(header.content_type()), "text/html")
    testing.assert_equal(header.content_length(), 1234)
    testing.assert_equal(header.connection_close(), True)

def test_parse_response_header():
    var headers_str = 'HTTP/1.1 200 OK\r\nServer: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Encoding: gzip\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n'
    var header = ResponseHeader()
    var reader = Reader(buffer.Buffer(headers_str))
    _ = header.parse_raw(reader)
    testing.assert_equal(String(header.protocol()), "HTTP/1.1")
    testing.assert_equal(header.no_http_1_1, False)
    testing.assert_equal(header.status_code(), 200)
    testing.assert_equal(String(header.status_message()), "OK")
    testing.assert_equal(String(header.server()), "example.com")
    testing.assert_equal(String(header.content_type()), "text/html")
    testing.assert_equal(String(header.content_encoding()), "gzip")
    testing.assert_equal(header.content_length(), 1234)
    testing.assert_equal(header.connection_close(), True)
    testing.assert_equal(header.trailer_str(), "end-of-message")
