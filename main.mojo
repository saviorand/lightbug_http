from lightbug_http.io.bytes import Bytes
from lightbug_http.python.server import PythonServer
from lightbug_http.client import Client
from lightbug_http.header import ResponseHeader
from lightbug_http.http import HTTPRequest, HTTPResponse
from lightbug_http.service import RawBytesService


@value
struct Printer(RawBytesService):
    fn func(self, req: Bytes) raises -> Bytes:
        print(String(req))
        return req


fn main() raises:
    var server = PythonServer()
    let handler = Printer()
    server.listen_and_serve("0.0.0.0:8080", handler)
