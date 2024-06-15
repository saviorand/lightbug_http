from external.gojo.tests.wrapper import MojoTest
from external.gojo.bytes import buffer
from external.gojo.bufio import Reader
from lightbug_http.header import RequestHeader, ResponseHeader
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.strings import empty_string 
from lightbug_http.net import default_buffer_size

def test_header():
    # test_parse_request_first_line_happy_path()
    # test_parse_request_first_line_error()
    # test_parse_response_first_line_happy_path()
    # test_parse_response_first_line_no_message()
    test_parse_request_header()
    test_parse_request_header_empty()
    test_parse_response_header()
    test_parse_response_header_empty()

# def test_parse_request_first_line_happy_path():
#     var test = MojoTest("test_parse_request_first_line_happy_path")
#     var cases = Dict[String, List[StringLiteral]]()

#     # Well-formed request lines
#     cases["GET /index.html HTTP/1.1\n"] = List("GET", "/index.html", "HTTP/1.1")
#     cases["POST /index.html HTTP/1.1"] = List("POST", "/index.html", "HTTP/1.1")
#     cases["GET / HTTP/1.1"] = List("GET", "/", "HTTP/1.1")
    
#     # Not quite well-formed, but we can fall back to default values
#     cases["GET "] = List("GET", "/", "HTTP/1.1")
#     cases["GET /"] = List("GET", "/", "HTTP/1.1")
#     cases["GET /index.html"] = List("GET", "/index.html", "HTTP/1.1")

#     for c in cases.items():
#         var header = RequestHeader()
#         var b = Bytes(c[].key.as_bytes_slice())
#         var buf = buffer.new_buffer(b^)
#         var reader = Reader(buf^)
#         _ = header.parse_raw(reader)
#         test.assert_equal(String(header.method()), c[].value[0])
#         test.assert_equal(String(header.request_uri()), c[].value[1])
#         test.assert_equal(header.protocol_str(), c[].value[2])

# def test_parse_request_first_line_error():
#     var test = MojoTest("test_parse_request_first_line_error")
#     var cases = Dict[String, String]()

#     cases["G"] = "Cannot find HTTP request method in the request"
#     cases[""] = "Cannot find HTTP request method in the request"
#     cases["GET"] = "Cannot find HTTP request method in the request" # This is misleading, update
#     cases["GET /index.html HTTP"] = "Invalid protocol"

#     for c in cases.items():
#         var header = RequestHeader(c[].key)
#         var b = Bytes(capacity=default_buffer_size)
#         var buf = buffer.new_buffer(b^)
#         var reader = Reader(buf^)
#         try:
#             _ = header.parse_raw(reader)
#         except e:
#             test.assert_equal(String(e.__str__()), c[].value)

# def test_parse_response_first_line_happy_path():
#     var test = MojoTest("test_parse_response_first_line_happy_path")
#     var cases = Dict[String, List[StringLiteral]]()

#     # Well-formed status (response) lines
#     cases["HTTP/1.1 200 OK"] = List("HTTP/1.1", "200", "OK")
#     cases["HTTP/1.1 404 Not Found"] = List("HTTP/1.1", "404", "Not Found")
#     cases["HTTP/1.1 500 Internal Server Error"] = List("HTTP/1.1", "500", "Internal Server Error")

#     # Trailing whitespace in status message is allowed
#     cases["HTTP/1.1 200 OK "] = List("HTTP/1.1", "200", "OK ")

#     for c in cases.items():
#         var header = ResponseHeader(empty_string.as_bytes_slice())
#         header.parse_raw(c[].key)
#         test.assert_equal(String(header.protocol()), c[].value[0])
#         test.assert_equal(header.status_code().__str__(), c[].value[1])
#         # also behaving weirdly with "OK" with byte slice, had to switch to string for now
#         test.assert_equal(header.status_message_str(), c[].value[2])

# # Status lines without a message are perfectly valid
# def test_parse_response_first_line_no_message():
#     var test = MojoTest("test_parse_response_first_line_no_message")
#     var cases = Dict[String, List[StringLiteral]]()

#     # Well-formed status (response) lines
#     cases["HTTP/1.1 200"] = List("HTTP/1.1", "200")

#     # Not quite well-formed, but we can fall back to default values
#     cases["HTTP/1.1 200 "] = List("HTTP/1.1", "200")

#     for c in cases.items():
#         var header = ResponseHeader(bytes(""))
#         header.parse_raw(c[].key)
#         test.assert_equal(String(header.status_message()), Bytes(String("").as_bytes())) # Empty string

def test_parse_request_header():
    var test = MojoTest("test_parse_request_header")
    var headers_str = bytes('''GET /index.html HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n''')

    var header = RequestHeader()
    var b = Bytes(headers_str)
    var buf = buffer.new_buffer(b^)
    var reader = Reader(buf^)
    _ = header.parse_raw(reader)
    test.assert_equal(String(header.request_uri()), "/index.html")
    test.assert_equal(String(header.protocol()), "HTTP/1.1")
    test.assert_equal(header.no_http_1_1, False)
    test.assert_equal(String(header.host()), "example.com")
    test.assert_equal(String(header.user_agent()), "Mozilla/5.0")
    test.assert_equal(String(header.content_type()), "text/html")
    test.assert_equal(header.content_length(), 1234)
    test.assert_equal(header.connection_close(), True)
    # test.assert_equal(String(header.trailer()), "end-of-message")

def test_parse_request_header_empty():
    var test = MojoTest("test_parse_request_header_empty")
    var headers_str = Bytes()
    var header = RequestHeader(headers_str)
    var b = Bytes(capacity=default_buffer_size)
    var buf = buffer.new_buffer(b^)
    var reader = Reader(buf^)
    _ = header.parse_raw(reader)
    _ = header.parse_raw(reader)
    test.assert_equal(String(header.request_uri()), "/index.html")
    test.assert_equal(String(header.protocol()), "HTTP/1.1")
    test.assert_equal(header.no_http_1_1, False)
    test.assert_equal(String(header.host()), String(empty_string.as_bytes_slice()))
    test.assert_equal(String(header.user_agent()), String(empty_string.as_bytes_slice()))
    test.assert_equal(String(header.content_type()), String(empty_string.as_bytes_slice()))
    test.assert_equal(header.content_length(), -2)
    test.assert_equal(header.connection_close(), False)
    test.assert_equal(String(header.trailer()), String(empty_string.as_bytes_slice()))


def test_parse_response_header():
    var test = MojoTest("test_parse_response_header")
    var headers_str = bytes('''
    Server: example.com\r\n
    User-Agent: Mozilla/5.0\r\n
    Content-Type: text/html\r\n
    Content-Encoding: gzip\r\n
    Content-Length: 1234\r\n
    Connection: close\r\n
    Trailer: end-of-message\r\n
    ''')

    var header = ResponseHeader(headers_str)
    header.parse_raw("HTTP/1.1 200 OK")
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

def test_parse_response_header_empty():
    var test = MojoTest("test_parse_response_header_empty")
    var headers_str = Bytes()

    var header = ResponseHeader(headers_str)
    header.parse_raw("HTTP/1.1 200 OK")
    test.assert_equal(String(header.protocol()), "HTTP/1.1")
    test.assert_equal(header.no_http_1_1, False)
    test.assert_equal(header.status_code(), 200)
    test.assert_equal(String(header.status_message()), "OK")
    test.assert_equal(String(header.server()), String(empty_string.as_bytes_slice()))
    test.assert_equal(String(header.content_type()), String(empty_string.as_bytes_slice()))
    test.assert_equal(String(header.content_encoding()), String(empty_string.as_bytes_slice()))
    test.assert_equal(header.content_length(), -2)
    test.assert_equal(header.connection_close(), False)
    test.assert_equal(String(header.trailer()), String(empty_string.as_bytes_slice()))