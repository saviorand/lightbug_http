from testing import assert_equal
from lightbug_http.header import RequestHeader, ResponseHeader
from lightbug_http.io.bytes import Bytes

def test_header():
    test_parse_request_first_line_happy_path()
    test_parse_request_first_line_error()
    test_parse_response_first_line_happy_path()
    test_parse_response_first_line_no_message()
    test_parse_request_header()

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
        var header = RequestHeader(String("")._buffer)
        header.parse(c[].key)
        assert_equal(header.method(), c[].value[0])
        assert_equal(header.request_uri(), c[].value[1])
        assert_equal(header.protocol(), c[].value[2])

def test_parse_response_first_line_happy_path():
    var cases = Dict[String, List[StringLiteral]]()

    # Well-formed status (response) lines
    cases["HTTP/1.1 200 OK"] = List("HTTP/1.1", "200", "OK")
    cases["HTTP/1.1 404 Not Found"] = List("HTTP/1.1", "404", "Not Found")
    cases["HTTP/1.1 500 Internal Server Error"] = List("HTTP/1.1", "500", "Internal Server Error")

    # Trailing whitespace in status message is allowed
    cases["HTTP/1.1 200 OK "] = List("HTTP/1.1", "200", "OK ")

    for c in cases.items():
        var header = ResponseHeader(String("")._buffer)
        header.parse(c[].key)
        assert_equal(header.protocol(), c[].value[0])
        assert_equal(header.status_code(), c[].value[1])
        assert_equal(header.status_message(), c[].value[2])


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
        assert_equal(header.status_message(), Bytes(String("").as_bytes())) # Empty string

def test_parse_request_first_line_error():
    var cases = Dict[String, String]()

    cases["G"] = "Cannot find HTTP request method in the request"
    cases[""] = "Cannot find HTTP request method in the request"
    cases["GET"] = "Cannot find HTTP request method in the request" # This is misleading, update
    cases["GET /index.html HTTP"] = "Invalid protocol"

    for c in cases.items():
        var header = RequestHeader("")
        try:
            header.parse(c[].key)
        except e:
            assert_equal(e, c[].value)

def test_parse_request_header():
    var case_1_well_formed_headers = Bytes(String('''
    Host: example.com\r\n
    User-Agent: Mozilla/5.0\r\n
    Content-Type: text/html\r\n
    Content-Length: 1234\r\n
    Connection: close\r\n
    Trailer: end-of-message\r\n
    ''')._buffer)

    var header = RequestHeader(case_1_well_formed_headers)
    header.parse("GET /index.html HTTP/1.1")
    assert_equal(header.method(), "GET")
    assert_equal(header.request_uri(), "/index.html")
    assert_equal(header.protocol(), "HTTP/1.1")
    assert_equal(header.no_http_1_1, False)
    assert_equal(header.host(), "example.com")
    assert_equal(header.user_agent(), "Mozilla/5.0")
    assert_equal(header.content_type(), "text/html")
    assert_equal(header.content_length(), 1234)
    assert_equal(header.connection_close(), True)
    assert_equal(header.trailer(), "end-of-message")
