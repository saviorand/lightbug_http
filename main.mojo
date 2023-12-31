from lightbug_http.io.bytes import Bytes
from lightbug_http.python.server import PythonServer
from lightbug_http.client import Client
from lightbug_http.header import ResponseHeader
from lightbug_http.http import HTTPRequest, HTTPResponse
from lightbug_http.service import HTTPService


@value
struct Printer(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        let req_body = req.body_raw
        print(String(req_body))
        return HTTPResponse(
            ResponseHeader(
                200, String("OK")._buffer, String("Content-Type: text/plain")._buffer
            ),
            req_body,
        )


fn main() raises:
    var server = PythonServer()
    let handler = Printer()
    server.listen_and_serve("0.0.0.0:8080", handler)
