import testing
from collections import Dict, List
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.http import HTTPRequest, HTTPResponse, encode
from lightbug_http.header import RequestHeader
from lightbug_http.uri import URI
from tests.utils import (
    default_server_conn_string,
    getRequest,
)

def test_http():
    test_encode_http_request()
    test_encode_http_response()

def test_encode_http_request():
    var uri = URI(default_server_conn_string)
    var req = HTTPRequest(
            uri,
            String("Hello world!").as_bytes(),
            RequestHeader(getRequest),
        )

    var req_encoded = encode(req)
    req_encoded.append(0)
    testing.assert_equal(String(req_encoded^), "GET / HTTP/1.1\r\nContent-Length: 12\r\nConnection: keep-alive\r\n\r\nHello world!")

def test_encode_http_response():
    var res = HTTPResponse(
        bytes("Hello, World!"),
    )

    var res_encoded = encode(res)
    res_encoded.append(0)
    var res_str = String(res_encoded^)
    
    # Since we cannot compare the exact date, we will only compare the headers until the date and the body
    var expected_full = "HTTP/1.1 200 OK\r\nServer: lightbug_http\r\nContent-Type: application/octet-stream\r\nContent-Length: 13\r\nConnection: keep-alive\r\nDate: 2024-06-02T13:41:50.766880+00:00\r\n\r\nHello, World!"
    
    var expected_headers_len = 124
    var hello_world_len = len(String("Hello, World!"))
    var date_header_len = len(String("Date: 2024-06-02T13:41:50.766880+00:00"))
    
    var expected_split = String(expected_full).split("\r\n\r\n")
    var expected_headers = expected_split[0]
    var expected_body = expected_split[1]
    
    testing.assert_equal(res_str[:expected_headers_len], expected_headers[:len(expected_headers) - date_header_len])
    testing.assert_equal(res_str[(len(res_str) - hello_world_len):len(res_str) + 1], expected_body)