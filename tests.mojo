import test_http, test_io, test_fd, test_connection, test_cookies, test_server, test_tls
from mojoweb.client import Client
from mojoweb.header import ResponseHeader
from mojoweb.http import HTTPRequest, HTTPResponse


@value
struct TestClient(Client):
    fn __init__(inout self):
        ...

    fn get(inout self, request: HTTPRequest) -> HTTPResponse:
        return HTTPResponse(ResponseHeader(), String("Nice")._buffer)


fn main() raises:
    var client = TestClient()
    test_http.test_request_simple_url(client)
