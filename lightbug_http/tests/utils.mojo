from lightbug_http.io.bytes import Bytes
from lightbug_http.http import HTTPRequest, HTTPResponse, ResponseHeader
from lightbug_http.client import Client


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
