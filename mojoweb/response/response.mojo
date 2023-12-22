from python import PythonObject
from utils.list import Dim

trait TCPResponseTrait(Copyable):
    @always_inline
    fn body(self) -> String:
        ...

    fn to_bytes(self, py_builtins: PythonObject, encoding: StringLiteral = "utf-8") raises -> PythonObject:
        ...

    @always_inline
    fn log_message(self, execution_time: Float64, raw_request: String, symbol: String = "") -> String:
        ...
    
    @always_inline
    fn print_log_message(self, execution_time: Float64, raw_request: String, symbol: String) -> None:
        ...


@value
struct TCPResponse(TCPResponseTrait):
    var __body: String

    fn __init__(inout self, body: String) -> None:
        self.__body = body
    
    @always_inline
    fn body(self) -> String:
        return self.__body

    fn to_bytes(self, py_builtins: PythonObject, encoding: StringLiteral = "utf-8") raises -> PythonObject:
        return py_builtins.bytes(self.body(), encoding)
    
    @always_inline
    fn log_message(self, execution_time: Float64, raw_request: String, symbol: String = "") -> String:
        let body = self.body()
        let short_body = body if not len(body) > 40 else body[:40] + "..."
        let short_input = raw_request if not len(raw_request) > 40 else raw_request[:40] + "..."
        return  "\t--- raw request body: '" + short_input + "'\n\t"
                + "--- response body: '" + short_body + "'\n\t"
                + "--- execution time: " + str(execution_time) + " secs " + symbol
    
    @always_inline
    fn print_log_message(self, execution_time: Float64, raw_request: String, symbol: String) -> None:
        let message = self.log_message(
            execution_time=execution_time, 
            raw_request=raw_request,
            symbol=symbol,
        )
        print(message)
    
    @staticmethod
    fn error(error_str: String) -> Self:
        return Self("MALFORMED_REQUEST_MESSAGE" + " '" + error_str + "'")
    
    @staticmethod
    fn empty_error(error_str: String) -> Self:
        return Self(body="EMPTY_REQUEST_MESSAGE" + " '" + error_str + ")")

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
