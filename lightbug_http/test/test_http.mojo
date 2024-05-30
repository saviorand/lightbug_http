from testing import assert_equal
from lightbug_http.io.bytes import Bytes
from lightbug_http.http import HTTPRequest, HTTPResponse, split_http_response_string, split_http_request_string

def test_http():
    test_split_http_response_string()
    test_split_http_request_string()
    # test_encode_http_request()
    # test_encode_http_response()

def test_split_http_response_string():
    var cases = Dict[String, List[StringLiteral]]()
    cases[String("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: 13\r\n\r\nHello, World!")] = List(
        "HTTP/1.1 200 OK",
        "\r\nContent-Type: text/html\r\nContent-Length: 13",
        "Hello, World!")
    
    for c in cases.items():
        var buf = Bytes(c[].key._buffer)
        response_first_line, response_headers, response_body = split_http_response_string(buf)
        assert_equal(response_first_line, c[].value[0])
        assert_equal(response_headers, c[].value[1])
        assert_equal(response_body, c[].value[2])
    

def test_split_http_request_string():
    ...

# def test_encode_http_request():
#     var req = HTTPRequest(
#                     # uri,
#                     # buf,
#                     # header,
#                 )
#     ...

# def test_encode_http_response():
#     ...