from mojoweb.utils import Bytes, bytes_equal
from mojoweb.strings import strHttp11, strSlash, strMethodGet

alias statusOK = 200


@value
struct RequestHeader:
    var disable_normalization: Bool
    var no_http_1_1: Bool
    var connection_close: Bool
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

    fn __init__(
        inout self,
        disable_normalization: Bool,
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
        self.no_http_1_1 = False
        self.connection_close = connection_close
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

    # assign no http 1.1
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
        self.connection_close = connection_close
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

    fn content_type(self) -> Bytes:
        return self.__content_type

    fn set_content_type(self, content_type: String) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            cookies_collected=self.cookies_collected,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=self.__request_uri,
            proto=self.proto,
            host=self.__host,
            content_type=content_type._buffer,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn set_content_type_bytes(self, content_type: Bytes) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            cookies_collected=self.cookies_collected,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=self.__request_uri,
            proto=self.proto,
            host=self.__host,
            content_type=content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn host(self) -> Bytes:
        return self.__host

    fn set_host(self, host: String) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            cookies_collected=self.cookies_collected,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=self.__request_uri,
            proto=self.proto,
            host=host._buffer,
            content_type=self.__content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn set_host_bytes(self, host: Bytes) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            cookies_collected=self.cookies_collected,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=self.__request_uri,
            proto=self.proto,
            host=host,
            content_type=self.__content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn user_agent(self) -> Bytes:
        return self.__user_agent

    fn set_user_agent(self, user_agent: String) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            cookies_collected=self.cookies_collected,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=self.__request_uri,
            proto=self.proto,
            host=self.__host,
            content_type=self.__content_type,
            user_agent=user_agent._buffer,
            raw_headers=self.raw_headers,
        )

    fn set_user_agent_bytes(self, user_agent: Bytes) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            cookies_collected=self.cookies_collected,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=self.__request_uri,
            proto=self.proto,
            host=self.__host,
            content_type=self.__content_type,
            user_agent=user_agent,
            raw_headers=self.raw_headers,
        )

    fn method(self) -> Bytes:
        if len(self.__method) == 0:
            return strMethodGet
        return self.__method

    fn set_method(self, method: String) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            cookies_collected=self.cookies_collected,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=method._buffer,
            request_uri=self.__request_uri,
            proto=self.proto,
            host=self.__host,
            content_type=self.__content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn set_method_bytes(self, method: Bytes) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            cookies_collected=self.cookies_collected,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=method,
            request_uri=self.__request_uri,
            proto=self.proto,
            host=self.__host,
            content_type=self.__content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn protocol(self) -> Bytes:
        if len(self.proto) == 0:
            return strHttp11
        return self.proto

    fn set_protocol(self, method: String) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            no_http_1_1=bytes_equal(method._buffer, strHttp11),
            connection_close=self.connection_close,
            cookies_collected=self.cookies_collected,
            no_default_content_type=self.no_default_content_type,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=self.__request_uri,
            proto=method._buffer,
            host=self.__host,
            content_type=self.__content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn set_protocol_bytes(self, method: Bytes) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            no_http_1_1=bytes_equal(method, strHttp11),
            connection_close=self.connection_close,
            cookies_collected=self.cookies_collected,
            no_default_content_type=self.no_default_content_type,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=self.__request_uri,
            proto=method,
            host=self.__host,
            content_type=self.__content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn request_uri(self) -> Bytes:
        if len(self.__request_uri) == 0:
            return strSlash
        return self.__request_uri

    fn set_request_uri(self, request_uri: String) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            no_http_1_1=self.no_http_1_1,
            connection_close=self.connection_close,
            cookies_collected=self.cookies_collected,
            no_default_content_type=self.no_default_content_type,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=request_uri._buffer,
            proto=self.proto,
            host=self.__host,
            content_type=self.__content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )

    fn set_request_uri_bytes(self, request_uri: Bytes) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            no_http_1_1=self.no_http_1_1,
            connection_close=self.connection_close,
            cookies_collected=self.cookies_collected,
            no_default_content_type=self.no_default_content_type,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            method=self.__method,
            request_uri=request_uri,
            proto=self.proto,
            host=self.__host,
            content_type=self.__content_type,
            user_agent=self.__user_agent,
            raw_headers=self.raw_headers,
        )


@value
struct ResponseHeader:
    var disable_normalization: Bool
    var no_http_1_1: Bool
    var connection_close: Bool
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
        self.connection_close = connection_close
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

    fn status_code(self) -> Int:
        if self.__status_code == 0:
            return statusOK
        return self.__status_code

    fn set_status_code(self, code: Int) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            no_http_1_1=self.no_http_1_1,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            no_default_date=self.no_default_date,
            status_code=code,
            status_message=self.__status_message,
            protocol=self.__protocol,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            content_type=self.content_type,
            content_encoding=self.content_encoding,
            server=self.server,
        )

    fn status_message(self) -> Bytes:
        return self.__status_message

    fn set_status_message(self, message: Bytes) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            no_http_1_1=self.no_http_1_1,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            no_default_date=self.no_default_date,
            status_code=self.__status_code,
            status_message=message,
            protocol=self.__protocol,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            content_type=self.content_type,
            content_encoding=self.content_encoding,
            server=self.server,
        )

    fn protocol(self) -> Bytes:
        if len(self.__protocol) == 0:
            return strHttp11
        return self.__protocol

    fn set_protocol(self, protocol: Bytes) -> Self:
        return Self(
            disable_normalization=self.disable_normalization,
            no_http_1_1=self.no_http_1_1,
            connection_close=self.connection_close,
            no_default_content_type=self.no_default_content_type,
            no_default_date=self.no_default_date,
            status_code=self.__status_code,
            status_message=self.__status_message,
            protocol=protocol,
            content_length=self.content_length,
            content_length_bytes=self.content_length_bytes,
            content_type=self.content_type,
            content_encoding=self.content_encoding,
            server=self.server,
        )
