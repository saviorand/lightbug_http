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

        if req.__uri.path() == "/":
            print("I'm on the index path!")
        if req.__uri.path() == "/first":
            print("I'm on /first!")
        elif req.__uri.path() == "/second":
            print("I'm on /second!")
        elif req.__uri.path() == "/echo":
            print(String(body))

        return OK(body)


@value
struct FakeResponder(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        # let method = String(req.header.method())
        # if method != "GET":
        #     raise Error("Did not expect a non-GET request! Got: " + method)
        return OK(String("Hello, world!")._buffer)
