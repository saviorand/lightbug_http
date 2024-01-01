from lightbug_http.http import HTTPRequest, HTTPResponse, OK
from lightbug_http.io.bytes import Bytes


trait HTTPService:
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        ...


@value
struct Printer(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        let body = req.body_raw

        print(String(body))

        return OK(body)
