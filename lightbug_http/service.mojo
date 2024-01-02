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


@value
struct ExampleRouter(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        let body = req.body_raw

        if req.uri.path() == "/":
            print("I'm on the index path!")
        if req.uri.path() == "/first":
            print("I'm on /first!")
        elif req.uri.path() == "/second":
            print("I'm on /second!")
        elif req.uri.path() == "/echo":
            print(String(body))

        return OK(body)
