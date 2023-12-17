from python import PythonObject
from utils.list import Dim


trait Response(Copyable):
    fn __init__(
        inout self,
        charset: CharSet = CharSet.utf8,
        status_code: Int = 200,
        content: String = "",
    ) raises -> None:
        ...

    fn _to_bytes(self) raises -> DynamicVector[Int8]:
        ...

    @always_inline
    fn body(self) -> String:
        ...

    @always_inline
    fn status(self) -> Int:
        ...


@value
struct MediaType:
    var value: String

    alias empty = MediaType("")
    alias plain = MediaType("text/plain")
    alias json = MediaType("application/json")


@value
struct CharSet:
    var value: String

    alias utf8 = CharSet("utf-8")


@value
struct HTTPResponse(Response):
    var __body: String
    var media_type: MediaType
    var charset: CharSet
    var status_code: Int

    fn __init__(
        inout self,
        charset: CharSet = CharSet.utf8,
        status_code: Int = 200,
        body: String = "",
        # headers: typing.Optional[typing.Mapping[str, str]] = None,
    ) raises -> None:
        self.__body = self.__body
        self.media_type = self.media_type
        self.charset = charset
        self.status_code = status_code
        # self.init_headers(headers)

    fn _to_bytes(self) raises -> DynamicVector[Int8]:
        if self.charset.value != "utf-8":
            raise Error("Only utf-8 is supported for now")
        return self.__body._buffer

    @always_inline
    fn body(self) -> String:
        return self.__body

    @always_inline
    fn status(self) -> Int:
        return self.status_code
