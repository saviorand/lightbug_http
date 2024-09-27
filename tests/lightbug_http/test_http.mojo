import testing
from collections import Dict, List
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.http import HTTPRequest, HTTPResponse, encode
from lightbug_http.header import Header, Headers, HeaderKey
from lightbug_http.uri import URI
from lightbug_http.strings import to_string

alias default_server_conn_string = "http://localhost:8080"


def test_encode_http_request():
    var uri = URI.parse_raises(default_server_conn_string + "/foobar?baz")
    var req = HTTPRequest(
        uri,
        body=String("Hello world!").as_bytes(),
        headers=Headers(Header("Connection", "keep-alive")),
    )

    var as_str = str(req)
    var req_encoded = to_string(encode(req^))


    var expected = String(
        "GET /foobar?baz HTTP/1.1\r\nconnection: keep-alive\r\ncontent-length:"
        " 12\r\nhost: localhost:8080\r\n\r\nHello world!"
    )

    testing.assert_equal(
        req_encoded,
        expected
    )
    testing.assert_equal(req_encoded, as_str)


def test_encode_http_response():
    var res = HTTPResponse(bytes("Hello, World!"))
    res.headers[HeaderKey.DATE] = "2024-06-02T13:41:50.766880+00:00"
    var as_str = str(res)
    var res_encoded = to_string(encode(res^))
    var expected_full = "HTTP/1.1 200 OK\r\nserver: lightbug_http\r\ncontent-type: application/octet-stream\r\nconnection: keep-alive\r\ncontent-length: 13\r\ndate: 2024-06-02T13:41:50.766880+00:00\r\n\r\nHello, World!"

    testing.assert_equal(res_encoded, expected_full)
    testing.assert_equal(res_encoded, as_str)


# def test_http_version_parse():
#     var v1 = HttpVersion("HTTP/1.1")
#     testing.assert_equal(v1, 1.1)