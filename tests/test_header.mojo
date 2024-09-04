from utils import Span
from collections import Dict
import testing
from gojo.bytes import buffer
from gojo.bufio import Reader
from lightbug_http.header import RequestHeader, ResponseHeader, headerScanner
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.strings import empty_string 
from lightbug_http.net import default_buffer_size


fn to_string(b: Span[UInt8]) -> String:
    var bytes = List[UInt8, True](b)
    bytes.append(0)
    return String(bytes)


fn to_string(owned b: List[UInt8, True]) -> String:
    b.append(0)
    return String(b)

def test_header():
    test_parse_request_header()
    test_parse_response_header()
    test_header_scanner()

def test_parse_request_header():
    var headers_str = 'GET /index.html HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n'
    var header = RequestHeader()
    var reader = Reader(buffer.Buffer(headers_str))
    _ = header.parse_raw(reader)
    testing.assert_equal(to_string(header.request_uri()), "/index.html")
    testing.assert_equal(to_string(header.protocol()), "HTTP/1.1")
    testing.assert_equal(header.no_http_1_1, False)
    testing.assert_equal(to_string(header.host()), String("example.com"))
    testing.assert_equal(to_string(header.user_agent()), "Mozilla/5.0")
    testing.assert_equal(to_string(header.content_type()), "text/html")
    testing.assert_equal(header.content_length(), 1234)
    testing.assert_equal(header.connection_close(), True)

def test_parse_response_header():
    var headers_str = 'HTTP/1.1 200 OK\r\nServer: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Encoding: gzip\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n'
    var header = ResponseHeader()
    var reader = Reader(buffer.Buffer(headers_str))
    _ = header.parse_raw(reader)
    testing.assert_equal(to_string(header.protocol()), "HTTP/1.1")
    testing.assert_equal(header.no_http_1_1, False)
    testing.assert_equal(header.status_code(), 200)
    testing.assert_equal(to_string(header.status_message()), "OK")
    testing.assert_equal(to_string(header.server()), "example.com")
    testing.assert_equal(to_string(header.content_type()), "text/html")
    testing.assert_equal(to_string(header.content_encoding()), "gzip")
    testing.assert_equal(header.content_length(), 1234)
    testing.assert_equal(header.connection_close(), True)
    testing.assert_equal(header.trailer_str(), "end-of-message")


def test_header_scanner():
    var headers_str = 'Server: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Encoding: gzip\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n'
    var expected_results = List[List[String]](
        List[String]("Server", "example.com"),
        List[String]("User-Agent", "Mozilla/5.0"),
        List[String]("Content-Type", "text/html"),
        List[String]("Content-Encoding", "gzip"),
        List[String]("Content-Length", "1234"),
        List[String]("Connection", "close"),
        List[String]("Trailer", "end-of-message")
    )
    var scanner = headerScanner()
    scanner.set_b(headers_str.as_bytes_slice())
    var i = 0
    while scanner.next():
        if len(scanner.key()) > 0:
            testing.assert_equal(to_string(scanner.key()), expected_results[i][0])
            testing.assert_equal(to_string(scanner.value()), expected_results[i][1])
        i += 1
    
    headers_str = 'Host: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n'
    expected_results = List[List[String]](
        List[String]("Host", "example.com"),
        List[String]("User-Agent", "Mozilla/5.0"),
        List[String]("Content-Type", "text/html"),
        List[String]("Content-Length", "1234"),
        List[String]("Connection", "close"),
        List[String]("Trailer", "end-of-message")
    )
    scanner = headerScanner()
    scanner.set_b(headers_str.as_bytes_slice())
    i = 0
    while scanner.next():
        if len(scanner.key()) > 0:
            testing.assert_equal(to_string(scanner.key()), expected_results[i][0])
            testing.assert_equal(to_string(scanner.value()), expected_results[i][1])
        i += 1
