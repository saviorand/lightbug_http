import test_http, test_io, test_fd, test_connection, test_cookies, test_server, test_tls
from mojoweb.io.bytes import Bytes
from mojoweb.python.server import PythonServer
from mojoweb.client import Client
from mojoweb.header import ResponseHeader
from mojoweb.http import HTTPRequest, HTTPResponse
from mojoweb.service import RawBytesService


@value
struct TestClient(Client):
    fn __init__(inout self):
        ...

    fn get(inout self, request: HTTPRequest) -> HTTPResponse:
        return HTTPResponse(ResponseHeader(), String("Nice")._buffer)


@value
struct Printer(RawBytesService):
    fn func(self, req: Bytes) raises -> Bytes:
        print(String(req))
        return req


fn main() raises:
    # var client = TestClient()
    # test_http.test_request_simple_url(client)
    var server = PythonServer()
    let handler = Printer()
    server.listen_and_serve("0.0.0.0:8080", handler)
