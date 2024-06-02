from testing import assert_equal
from lightbug_http.io.bytes import Bytes
from lightbug_http.http import HTTPRequest, HTTPResponse, split_http_string_list_headers, encode
from lightbug_http.header import RequestHeader
from lightbug_http.uri import URI
from tests.utils import (
    default_server_conn_string,
    getRequest,
)

def test_http():
    test_split_http_string()
    test_encode_http_request()
    test_encode_http_response()

def test_split_http_string():
    var cases = Dict[StringLiteral, StringLiteral]()
    var expected_first_line = Dict[StringLiteral, StringLiteral]()
    var expected_headers = Dict[StringLiteral, List[StringLiteral]]()
    var expected_body = Dict[StringLiteral, StringLiteral]()
    
    cases["with_headers"] = "GET /index.html HTTP/1.1\r\nHost: www.example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\nHello, World!"
    expected_first_line["with_headers"] = "GET /index.html HTTP/1.1"
    expected_headers["with_headers"] = List(
        "Host: www.example.com",
        "User-Agent: Mozilla/5.0",
        "Content-Type: text/html",
        "Content-Length: 1234",
        "Connection: close",
        "Trailer: end-of-message"
    )
    expected_body["with_headers"] = "Hello, World!"

    cases["no_headers"] = "GET /index.html HTTP/1.1\r\n\r\nHello, World!"
    expected_first_line["no_headers"] = "GET /index.html HTTP/1.1"
    expected_headers["no_headers"] = List[StringLiteral]()
    expected_body["no_headers"] = "Hello, World!"

    cases["no_body"] = "GET /index.html HTTP/1.1\r\nHost: www.example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n"
    expected_first_line["no_body"] = "GET /index.html HTTP/1.1"
    expected_headers["no_body"] = List(
        "Host: www.example.com",
        "User-Agent: Mozilla/5.0",
        "Content-Type: text/html",
        "Content-Length: 1234",
        "Connection: close",
        "Trailer: end-of-message"
    )
    expected_body["no_body"] = ""
    
    cases["no_headers_no_body"] = "GET /index.html HTTP/1.1\r\n\r\n"
    expected_first_line["no_headers_no_body"] = "GET /index.html HTTP/1.1"
    expected_headers["no_headers_no_body"] = List[StringLiteral]()
    expected_body["no_headers_no_body"] = ""


    for c in cases.items():
        var buf = Bytes(String(c[].value)._buffer)
        request_first_line, request_headers, request_body = split_http_string_list_headers(buf)
        
        assert_equal(request_first_line, expected_first_line[c[].key])
        
        for i in range(len(request_headers)):
            assert_equal(request_headers[i], expected_headers[c[].key][i])
        
        assert_equal(request_body, expected_body[c[].key])

def test_encode_http_request():
    var uri = URI(default_server_conn_string)
    var req = HTTPRequest(
            uri,
            String("Hello world!").as_bytes(),
            RequestHeader(getRequest),
        )

    var req_encoded = encode(req, uri)
    assert_equal(req_encoded, "GET / HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Length: 12\r\nConnection: keep-alive\r\n\r\nHello world!")

def test_encode_http_response():
    var res = HTTPResponse(
        String("Hello, World!")._buffer,
    )

    var res_encoded = encode(res)
    var res_str = String(res_encoded)
    
    # Since we cannot compare the exact date, we will only compare the headers until the date and the body
    var expected_full = "HTTP/1.1 200 OK\r\nServer: lightbug_http\r\nContent-Type: application/octet-stream\r\nContent-Length: 14\r\nConnection: keep-alive\r\nDate: 2024-06-02T13:41:50.766880+00:00\r\n\r\nHello, World!"
    
    var expected_headers_len = 124
    var hello_world_len = len(String("Hello, World!")) + 1
    var date_header_len = len(String("Date: 2024-06-02T13:41:50.766880+00:00"))
    
    var expected_split = String(expected_full).split("\r\n\r\n")
    var expected_headers = expected_split[0]
    var expected_body = expected_split[1]
    
    assert_equal(res_str[:expected_headers_len], expected_headers[:len(expected_headers) - date_header_len])
    assert_equal(res_str[(len(res_str) - hello_world_len):len(res_str) - 1], expected_body)