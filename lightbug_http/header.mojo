from lightbug_http.strings import strHttp11, strSlash, strMethodGet
from lightbug_http.io.bytes import Bytes, bytes_equal

alias statusOK = 200


@value
struct RequestHeader:
    var disable_normalization: Bool
    var no_http_1_1: Bool
    var __connection_close: Bool
    var no_default_content_type: Bool

    var cookies_collected: Bool

    var content_length: Int
    var content_length_bytes: Bytes

    var __method: Bytes
    var __request_uri: Bytes
    var proto: Bytes
    var __host: Bytes
    var __content_type: Bytes
    var __user_agent: Bytes
    # TODO: var mul_header

    # TODO: var cookies

    # immutable copy of original headers
    var raw_headers: Bytes

    fn __init__(inout self) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.no_default_content_type = False
        self.cookies_collected = False
        self.content_length = 0
        self.content_length_bytes = Bytes()
        self.__method = Bytes()
        self.__request_uri = Bytes()
        self.proto = Bytes()
        self.__host = Bytes()
        self.__content_type = Bytes()
        self.__user_agent = Bytes()
        self.raw_headers = Bytes()

    fn __init__(
        inout self,
        disable_normalization: Bool,
        no_http_1_1: Bool,
        connection_close: Bool,
        no_default_content_type: Bool,
        cookies_collected: Bool,
        content_length: Int,
        content_length_bytes: Bytes,
        method: Bytes,
        request_uri: Bytes,
        proto: Bytes,
        host: Bytes,
        content_type: Bytes,
        user_agent: Bytes,
        raw_headers: Bytes,
    ) -> None:
        self.disable_normalization = disable_normalization
        self.no_http_1_1 = no_http_1_1
        self.__connection_close = connection_close
        self.no_default_content_type = no_default_content_type
        self.cookies_collected = cookies_collected
        self.content_length = content_length
        self.content_length_bytes = content_length_bytes
        self.__method = method
        self.__request_uri = request_uri
        self.proto = proto
        self.__host = host
        self.__content_type = content_type
        self.__user_agent = user_agent
        self.raw_headers = raw_headers

    fn set_content_type(inout self, content_type: String) -> Self:
        self.__content_type = content_type._buffer
        return self

    fn set_content_type_bytes(inout self, content_type: Bytes) -> Self:
        self.__content_type = content_type
        return self

    fn content_type(self) -> Bytes:
        return self.__content_type

    fn set_host(inout self, host: String) -> Self:
        self.__host = host._buffer
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        self.__host = host
        return self

    fn host(self) -> Bytes:
        return self.__host

    fn set_user_agent(inout self, user_agent: String) -> Self:
        self.__user_agent = user_agent._buffer
        return self

    fn set_user_agent_bytes(inout self, user_agent: Bytes) -> Self:
        self.__user_agent = user_agent
        return self

    fn user_agent(self) -> Bytes:
        return self.__user_agent

    fn set_method(inout self, method: String) -> Self:
        self.__method = method._buffer
        return self

    fn set_method_bytes(inout self, method: Bytes) -> Self:
        self.__method = method
        return self

    fn method(self) -> Bytes:
        if len(self.__method) == 0:
            return strMethodGet
        return self.__method

    fn set_protocol(inout self, method: String) -> Self:
        self.no_http_1_1 = bytes_equal(method._buffer, strHttp11)
        self.proto = method._buffer
        return self

    fn set_protocol_bytes(inout self, method: Bytes) -> Self:
        self.no_http_1_1 = bytes_equal(method, strHttp11)
        self.proto = method
        return self

    fn protocol(self) -> Bytes:
        if len(self.proto) == 0:
            return strHttp11
        return self.proto

    fn set_request_uri(inout self, request_uri: String) -> Self:
        self.__request_uri = request_uri._buffer
        return self

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        self.__request_uri = request_uri
        return self

    fn request_uri(self) -> Bytes:
        if len(self.__request_uri) == 0:
            return strSlash
        return self.__request_uri

    fn set_connection_close(inout self) -> Self:
        self.__connection_close = True
        return self

    fn reset_connection_close(inout self) -> Self:
        if self.__connection_close == False:
            return self
        else:
            self.__connection_close = False
            return self

    fn connection_close(self) -> Bool:
        return self.__connection_close


@value
struct ResponseHeader:
    var disable_normalization: Bool
    var no_http_1_1: Bool
    var __connection_close: Bool
    var no_default_content_type: Bool
    var no_default_date: Bool

    var __status_code: Int
    var __status_message: Bytes
    var __protocol: Bytes
    var content_length: Int
    var content_length_bytes: Bytes

    var content_type: Bytes
    var content_encoding: Bytes
    var server: Bytes
    # TODO: var mul_header

    # TODO: var cookies
    fn __init__(
        inout self,
    ) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.no_default_content_type = False
        self.no_default_date = False
        self.__status_code = 200
        self.__status_message = Bytes()
        self.__protocol = Bytes()
        self.content_length = 0
        self.content_length_bytes = Bytes()
        self.content_type = Bytes()
        self.content_encoding = Bytes()
        self.server = Bytes()

    fn __init__(
        inout self,
        disable_normalization: Bool,
        no_http_1_1: Bool,
        connection_close: Bool,
        no_default_content_type: Bool,
        no_default_date: Bool,
        status_code: Int,
        status_message: Bytes,
        protocol: Bytes,
        content_length: Int,
        content_length_bytes: Bytes,
        content_type: Bytes,
        content_encoding: Bytes,
        server: Bytes,
    ) -> None:
        self.disable_normalization = disable_normalization
        self.no_http_1_1 = no_http_1_1
        self.__connection_close = connection_close
        self.no_default_content_type = no_default_content_type
        self.no_default_date = no_default_date
        self.__status_code = status_code
        self.__status_message = status_message
        self.__protocol = protocol
        self.content_length = content_length
        self.content_length_bytes = content_length_bytes
        self.content_type = content_type
        self.content_encoding = content_encoding
        self.server = server

    fn set_status_code(inout self, code: Int) -> Self:
        self.__status_code = code
        return self

    fn status_code(self) -> Int:
        if self.__status_code == 0:
            return statusOK
        return self.__status_code

    fn set_status_message(inout self, message: Bytes) -> Self:
        self.__status_message = message
        return self

    fn status_message(self) -> Bytes:
        return self.__status_message

    fn set_protocol(inout self, protocol: Bytes) -> Self:
        self.__protocol = protocol
        return self

    fn protocol(self) -> Bytes:
        if len(self.__protocol) == 0:
            return strHttp11
        return self.__protocol

    fn set_connection_close(inout self) -> Self:
        self.__connection_close = True
        return self

    fn reset_connection_close(inout self) -> Self:
        if self.__connection_close == False:
            return self
        else:
            self.__connection_close = False
            return self

    fn connection_close(self) -> Bool:
        return self.__connection_close
