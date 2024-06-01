from testing import assert_equal
from lightbug_http.header import RequestHeader, ResponseHeader
from lightbug_http.io.bytes import Bytes
from lightbug_http.strings import empty_string

def test_header():
    test_parse_request_first_line_happy_path()
    test_parse_request_first_line_error()
    test_parse_response_first_line_happy_path()
    test_parse_response_first_line_no_message()
    test_parse_request_header()
    test_parse_request_header_empty()
    test_parse_response_header()
    test_parse_response_header_empty()

def test_parse_request_first_line_happy_path():
    var cases = Dict[String, List[StringLiteral]]()

    # Well-formed request lines
    cases["GET /index.html HTTP/1.1"] = List("GET", "/index.html", "HTTP/1.1")
    cases["POST /index.html HTTP/1.1"] = List("POST", "/index.html", "HTTP/1.1")
    cases["GET / HTTP/1.1"] = List("GET", "/", "HTTP/1.1")
    
    # Not quite well-formed, but we can fall back to default values
    cases["GET "] = List("GET", "/", "HTTP/1.1")
    cases["GET /"] = List("GET", "/", "HTTP/1.1")
    cases["GET /index.html"] = List("GET", "/index.html", "HTTP/1.1")

    for c in cases.items():
        var header = RequestHeader("".as_bytes_slice())
        header.parse(c[].key)
        assert_equal(String(header.method()), c[].value[0])
        assert_equal(String(header.request_uri()), c[].value[1])
        assert_equal(header.protocol_str(), c[].value[2])

def test_parse_response_first_line_happy_path():
    var cases = Dict[String, List[StringLiteral]]()

    # Well-formed status (response) lines
    cases["HTTP/1.1 200 OK"] = List("HTTP/1.1", "200", "OK")
    # cases["HTTP/1.1 404 Not Found"] = List("HTTP/1.1", "404", "Not Found")
    # cases["HTTP/1.1 500 Internal Server Error"] = List("HTTP/1.1", "500", "Internal Server Error")

    # # Trailing whitespace in status message is allowed
    # cases["HTTP/1.1 200 OK "] = List("HTTP/1.1", "200", "OK ")

    for c in cases.items():
        var header = ResponseHeader(empty_string.as_bytes_slice())
        header.parse(c[].key)
        assert_equal(header.protocol_str(), c[].value[0])
        assert_equal(header.status_code().__str__(), c[].value[1])
        # also behaving weirdly with "OK" with byte slice, had to switch to string for now
        assert_equal(header.status_message_str(), c[].value[2])


# Status lines without a message are perfectly valid
def test_parse_response_first_line_no_message():
    var cases = Dict[String, List[StringLiteral]]()

    # Well-formed status (response) lines
    cases["HTTP/1.1 200"] = List("HTTP/1.1", "200")

    # Not quite well-formed, but we can fall back to default values
    cases["HTTP/1.1 200 "] = List("HTTP/1.1", "200")

    for c in cases.items():
        var header = ResponseHeader(String("")._buffer)
        header.parse(c[].key)
        assert_equal(String(header.status_message()), Bytes(String("").as_bytes())) # Empty string

def test_parse_request_first_line_error():
    var cases = Dict[String, String]()

    cases["G"] = "Cannot find HTTP request method in the request"
    cases[""] = "Cannot find HTTP request method in the request"
    cases["GET"] = "Cannot find HTTP request method in the request" # This is misleading, update
    cases["GET /index.html HTTP"] = "Invalid protocol"

    for c in cases.items():
        var header = RequestHeader("")
        # try:
            # header.parse(c[].key)
        # except e:
            # assert_equal(e, c[].value)

def test_parse_request_header():
    var headers_str = Bytes(String('''
    Host: example.com\r\n
    User-Agent: Mozilla/5.0\r\n
    Content-Type: text/html\r\n
    Content-Length: 1234\r\n
    Connection: close\r\n
    Trailer: end-of-message\r\n
    ''')._buffer)

    var header = RequestHeader(headers_str)
    header.parse("GET /index.html HTTP/1.1")
    # assert_equal(header.method(), "GET")
    assert_equal(String(header.request_uri()), "/index.html")
    assert_equal(String(header.protocol()), "HTTP/1.1")
    assert_equal(header.no_http_1_1, False)
    assert_equal(String(header.host()), "example.com")
    assert_equal(String(header.user_agent()), "Mozilla/5.0")
    assert_equal(String(header.content_type()), "text/html")
    assert_equal(header.content_length(), 1234)
    assert_equal(header.connection_close(), True)
    assert_equal(header.trailer_str(), "end-of-message")

def test_parse_request_header_empty():
    var headers_str = Bytes()
    var header = RequestHeader(headers_str)
    header.parse("GET /index.html HTTP/1.1")
    # assert_equal(header.method(), "GET")
    assert_equal(String(header.request_uri()), "/index.html")
    assert_equal(String(header.protocol()), "HTTP/1.1")
    assert_equal(header.no_http_1_1, False)
    assert_equal(String(header.host()), String(empty_string.as_bytes_slice()))
    assert_equal(String(header.user_agent()), String(empty_string.as_bytes_slice()))
    assert_equal(String(header.content_type()), String(empty_string.as_bytes_slice()))
    assert_equal(header.content_length(), -2)
    assert_equal(header.connection_close(), False)
    assert_equal(String(header.trailer()), String(empty_string.as_bytes_slice()))


def test_parse_response_header():
    var headers_str = Bytes(String('''
    Server: example.com\r\n
    User-Agent: Mozilla/5.0\r\n
    Content-Type: text/html\r\n
    Content-Encoding: gzip\r\n
    Content-Length: 1234\r\n
    Connection: close\r\n
    Trailer: end-of-message\r\n
    ''')._buffer)

    var header = ResponseHeader(headers_str)
    header.parse("HTTP/1.1 200 OK")
    assert_equal(String(header.protocol()), "HTTP/1.1")
    assert_equal(header.no_http_1_1, False)
    assert_equal(header.status_code(), 200)
    assert_equal(String(header.status_message()), "OK")
    assert_equal(String(header.server()), "example.com")
    assert_equal(String(header.content_type()), "text/html")
    assert_equal(String(header.content_encoding()), "gzip")
    assert_equal(header.content_length(), 1234)
    assert_equal(header.connection_close(), True)
    assert_equal(header.trailer_str(), "end-of-message")

def test_parse_response_header_empty():
    var headers_str = Bytes()

    var header = ResponseHeader(headers_str)
    header.parse("HTTP/1.1 200 OK")
    assert_equal(String(header.protocol()), "HTTP/1.1")
    assert_equal(header.no_http_1_1, False)
    assert_equal(header.status_code(), 200)
    assert_equal(String(header.status_message()), "OK")
    assert_equal(String(header.server()), String(empty_string.as_bytes_slice()))
    assert_equal(String(header.content_type()), String(empty_string.as_bytes_slice()))
    assert_equal(String(header.content_encoding()), String(empty_string.as_bytes_slice()))
    assert_equal(header.content_length(), -2)
    assert_equal(header.connection_close(), False)
    assert_equal(String(header.trailer()), String(empty_string.as_bytes_slice()))