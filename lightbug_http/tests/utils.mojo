from lightbug_http.io.bytes import Bytes
from lightbug_http.http import HTTPRequest, HTTPResponse, ResponseHeader
from lightbug_http.service import HTTPService, OK
from lightbug_http.client import Client


struct FakeServer:
    var __listener: FakeListener
    var __handler: FakeResponder

    fn __init__(inout self, listener: FakeListener, handler: FakeResponder):
        self.__listener = listener
        self.__handler = handler

    fn serve(inout self) -> None:
        while not self.__listener.closed:
            self.__listener.accept()


@value
struct FakeResponder(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        # let method = String(req.header.method())
        # if method != "GET":
        #     raise Error("Did not expect a non-GET request! Got: " + method)
        return OK(String("Hello, world!")._buffer)


@value
struct FakeListener:
    var request_count: Int
    var request: Bytes
    var closed: Bool

    fn __init__(inout self, request_count: Int, request: Bytes) -> None:
        self.request_count = request_count
        self.request = request
        self.closed = False

    fn accept(inout self) -> None:
        self.request_count -= 1
        if self.request_count == 0:
            self.closed = True


@value
struct TestClient(Client):
    fn __init__(inout self):
        ...

    fn get(inout self, request: HTTPRequest) -> HTTPResponse:
        return HTTPResponse(ResponseHeader(), String("Nice")._buffer)


@value
struct TestStruct:
    var a: String
    var b: String
    var c: Bytes
    var d: Int
    var e: TestStructNested

    fn __init__(inout self, a: String, b: String) -> None:
        self.a = a
        self.b = b
        self.c = String("c")._buffer
        self.d = 1
        self.e = TestStructNested("a", 1)

    fn set_a_direct(inout self, a: String) -> Self:
        self.a = a
        return self

    fn set_a_copy(self, a: String) -> Self:
        return Self(a, self.b)


@value
struct TestStructNested:
    var a: String
    var b: Int

    fn __init__(inout self, a: String, b: Int) -> None:
        self.a = a
        self.b = b

    fn set_a_direct(inout self, a: String) -> Self:
        self.a = a
        return self

    fn set_a_copy(self, a: String) -> Self:
        return Self(a, self.b)


alias getRequest = String(
    "GET /foobar?baz HTTP/1.1\r\nHost: google.com\r\nUser-Agent: aaa/bbb/ccc/ddd/eee"
    " Firefox Chrome MSIE Opera\r\n"
    + "Referer: http://example.com/aaa?bbb=ccc\r\nCookie: foo=bar; baz=baraz;"
    " aa=aakslsdweriwereowriewroire\r\n\r\n"
)._buffer


fn new_fake_listener(request_count: Int, request: Bytes) -> FakeListener:
    return FakeListener(request_count, request)
