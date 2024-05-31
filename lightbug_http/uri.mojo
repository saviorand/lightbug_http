from lightbug_http.io.bytes import Bytes, bytes_equal
from lightbug_http.strings import (
    strSlash,
    strHttp11,
    strHttp10,
    strHttp,
    http,
    strHttps,
    https,
)


@value
struct URI:
    var __path_original: Bytes
    var __scheme: Bytes
    var __path: Bytes
    var __query_string: Bytes
    var __hash: Bytes
    var __host: Bytes
    var __http_version: Bytes

    var disable_path_normalization: Bool

    var __full_uri: Bytes
    var __request_uri: Bytes

    var __username: Bytes
    var __password: Bytes

    fn __init__(
        inout self,
        full_uri: String,
    ) -> None:
        self.__path_original = Bytes()
        self.__scheme = Bytes()
        self.__path = Bytes()
        self.__query_string = Bytes()
        self.__hash = Bytes()
        self.__host = String("127.0.0.1")._buffer
        self.__http_version = strHttp11
        self.disable_path_normalization = False
        self.__full_uri = full_uri._buffer
        self.__request_uri = Bytes()
        self.__username = Bytes()
        self.__password = Bytes()

    fn __init__(
        inout self,
        scheme: String,
        host: String,
        path: String,
    ) -> None:
        self.__path_original = path._buffer
        self.__scheme = scheme._buffer
        self.__path = normalise_path(path._buffer, self.__path_original)
        self.__query_string = Bytes()
        self.__hash = Bytes()
        self.__host = host._buffer
        self.__http_version = strHttp11
        self.disable_path_normalization = False
        self.__full_uri = Bytes()
        self.__request_uri = Bytes()
        self.__username = Bytes()
        self.__password = Bytes()

    fn __init__(
        inout self,
        path_original: Bytes,
        path: Bytes,
        scheme: Bytes,
        query_string: Bytes,
        hash: Bytes,
        host: Bytes,
        http_version: Bytes,
        disable_path_normalization: Bool,
        full_uri: Bytes,
        request_uri: Bytes,
        username: Bytes,
        password: Bytes,
    ):
        self.__path_original = path_original
        self.__scheme = scheme
        self.__path = path
        self.__query_string = query_string
        self.__hash = hash
        self.__host = host
        self.__http_version = http_version
        self.disable_path_normalization = disable_path_normalization
        self.__full_uri = full_uri
        self.__request_uri = request_uri
        self.__username = username
        self.__password = password

    fn path_original(self) -> Bytes:
        return self.__path_original

    fn set_path(inout self, path: String) -> Self:
        self.__path = normalise_path(path._buffer, self.__path_original)
        return self

    fn set_path_sbytes(inout self, path: Bytes) -> Self:
        self.__path = normalise_path(path, self.__path_original)
        return self

    fn path(self) -> String:
        var processed_path = self.__path
        if len(processed_path) == 0:
            processed_path = strSlash
        return String(processed_path)

    fn set_scheme(inout self, scheme: String) -> Self:
        self.__scheme = scheme._buffer
        return self

    fn set_scheme_bytes(inout self, scheme: Bytes) -> Self:
        self.__scheme = scheme
        return self

    fn scheme(self) -> Bytes:
        var processed_scheme = self.__scheme
        if len(processed_scheme) == 0:
            processed_scheme = strHttp
        return processed_scheme

    fn http_version(self) -> Bytes:
        return self.__http_version

    fn set_http_version(inout self, http_version: String) -> Self:
        self.__http_version = http_version._buffer
        return self

    fn is_http_1_1(self) -> Bool:
        return bytes_equal(self.__http_version, strHttp11)

    fn is_http_1_0(self) -> Bool:
        return bytes_equal(self.__http_version, strHttp10)

    fn is_https(self) -> Bool:
        return bytes_equal(self.__scheme, https._buffer)

    fn is_http(self) -> Bool:
        return bytes_equal(self.__scheme, http._buffer) or len(self.__scheme) == 0

    fn set_request_uri(inout self, request_uri: String) -> Self:
        self.__request_uri = request_uri._buffer
        return self

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        self.__request_uri = request_uri
        return self
    
    fn request_uri(self) -> Bytes:
        return self.__request_uri

    fn set_query_string(inout self, query_string: String) -> Self:
        self.__query_string = query_string._buffer
        return self

    fn set_query_string_bytes(inout self, query_string: Bytes) -> Self:
        self.__query_string = query_string
        return self
    
    fn query_string(self) -> Bytes:
        return self.__query_string

    fn set_hash(inout self, hash: String) -> Self:
        self.__hash = hash._buffer
        return self

    fn set_hash_bytes(inout self, hash: Bytes) -> Self:
        self.__hash = hash
        return self

    fn hash(self) -> Bytes:
        return self.__hash

    fn set_host(inout self, host: String) -> Self:
        self.__host = host._buffer
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        self.__host = host
        return self

    fn host(self) -> Bytes:
        return self.__host
    
    fn host_str(self) -> String:
        return self.__host

    fn full_uri(self) -> Bytes:
        return self.__full_uri

    fn set_username(inout self, username: String) -> Self:
        self.__username = username._buffer
        return self

    fn set_username_bytes(inout self, username: Bytes) -> Self:
        self.__username = username
        return self
    
    fn username(self) -> Bytes:
        return self.__username

    fn set_password(inout self, password: String) -> Self:
        self.__password = password._buffer
        return self

    fn set_password_bytes(inout self, password: Bytes) -> Self:
        self.__password = password
        return self
    
    fn password(self) -> Bytes:
        return self.__password

    fn parse(inout self) raises -> None:
        var raw_uri = String(self.__full_uri)

        # Defaults to HTTP/1.1
        var proto_str = String(strHttp11)
        var is_https = False

        # Parse the protocol
        var proto_end = raw_uri.find("://")
        var remainder_uri: String
        if proto_end >= 0:
            proto_str = raw_uri[:proto_end]
            if proto_str == https:
                is_https = True
            remainder_uri = raw_uri[proto_end + 3:]
        else:
            remainder_uri = raw_uri

        # Parse the host and optional port
        var path_start = remainder_uri.find("/")
        var host_and_port: String
        var request_uri: String
        if path_start >= 0:
            host_and_port = remainder_uri[:path_start]
            request_uri = remainder_uri[path_start:]
            self.__host = host_and_port[:path_start]._buffer
        else:
            host_and_port = remainder_uri
            request_uri = strSlash
            self.__host = host_and_port._buffer

        if is_https:
            _ = self.set_scheme(https)
        else:
            _ = self.set_scheme(http)
        
        # Parse path
        var n = request_uri.find("?")
        if n >= 0:
            self.__path_original = request_uri[:n]._buffer
            self.__query_string = request_uri[n + 1 :]._buffer
        else:
            self.__path_original = request_uri._buffer
            self.__query_string = Bytes()

        self.__path = normalise_path(self.__path_original, self.__path_original)

        _ = self.set_request_uri(request_uri)


fn normalise_path(path: Bytes, path_original: Bytes) -> Bytes:
    # TODO: implement
    return path
