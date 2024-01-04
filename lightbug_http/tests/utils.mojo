from python import Python, PythonObject
from lightbug_http.io.bytes import Bytes
from lightbug_http.error import ErrorHandler
from lightbug_http.http import HTTPRequest, HTTPResponse, ResponseHeader
from lightbug_http.net import Listener, Addr, Connection, TCPAddr
from lightbug_http.service import HTTPService, OK
from lightbug_http.server import ServerTrait
from lightbug_http.client import Client


fn new_httpx_client() raises -> PythonObject:
    let httpx = Python.import_module("httpx")
    return httpx


fn new_fake_listener(request_count: Int, request: Bytes) -> FakeListener:
    return FakeListener(request_count, request)


struct FakeServer(ServerTrait):
    var __listener: FakeListener
    var __handler: FakeResponder

    fn __init__(inout self, listener: FakeListener, handler: FakeResponder):
        self.__listener = listener
        self.__handler = handler

    fn __init__(
        inout self, addr: String, service: HTTPService, error_handler: ErrorHandler
    ):
        try:
            self.__listener = FakeListener()
        except e:
            print(e)
        self.__handler = FakeResponder()

    fn get_concurrency(self) -> Int:
        return 1

    fn listen_and_serve(self, address: String, handler: HTTPService) raises -> None:
        ...

    fn serve(inout self) -> None:
        while not self.__listener.closed:
            try:
                _ = self.__listener.accept[FakeConnection]()
            except e:
                print(e)

    fn serve(self, ln: Listener, handler: HTTPService) raises -> None:
        ...


@value
struct FakeResponder(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        let method = String(req.header.method())
        if method != "GET":
            raise Error("Did not expect a non-GET request! Got: " + method)
        return OK(String("Hello, world!")._buffer)


@value
struct FakeConnection(Connection):
    fn __init__(inout self, laddr: String, raddr: String) raises:
        ...

    fn __init__(inout self, laddr: TCPAddr, raddr: TCPAddr) raises:
        ...

    fn read(self, inout buf: Bytes) raises -> Int:
        return 0

    fn write(self, buf: Bytes) raises -> Int:
        return 0

    fn close(self) raises:
        ...

    fn local_addr(inout self) raises -> TCPAddr:
        return TCPAddr()

    fn remote_addr(self) raises -> TCPAddr:
        return TCPAddr()


@value
struct FakeListener(Listener):
    var request_count: Int
    var request: Bytes
    var closed: Bool

    fn __init__(inout self) raises:
        self.request_count = 0
        self.request = Bytes()
        self.closed = False

    fn __init__(inout self, addr: TCPAddr) raises:
        self.request_count = 0
        self.request = Bytes()
        self.closed = False

    fn __init__(inout self, request_count: Int, request: Bytes) -> None:
        self.request_count = request_count
        self.request = request
        self.closed = False

    @always_inline
    fn accept[T: Connection](self) raises -> T:
        return FakeConnection()

    fn close(self) raises:
        pass

    fn addr(self) -> TCPAddr:
        return TCPAddr()


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
