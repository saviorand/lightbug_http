from utils import Span, StringSlice
from lightbug_http.io.bytes import Bytes, bytes_equal, bytes
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
        self.__host = Bytes()
        self.__http_version = Bytes()
        self.disable_path_normalization = False
        self.__full_uri = full_uri.as_bytes()
        self.__request_uri = Bytes()
        self.__username = Bytes()
        self.__password = Bytes()
    
    fn __init__(
        inout self,
        full_uri: String,
        host: String
    ) -> None:
        self.__path_original = Bytes()
        self.__scheme = Bytes()
        self.__path = Bytes()
        self.__query_string = Bytes()
        self.__hash = Bytes()
        self.__host = host.as_bytes()
        self.__http_version = Bytes()
        self.disable_path_normalization = False
        self.__full_uri = full_uri.as_bytes()
        self.__request_uri = Bytes()
        self.__username = Bytes()
        self.__password = Bytes()

    fn __init__(
        inout self,
        scheme: String,
        host: String,
        path: String,
    ) -> None:
        self.__path_original = path.as_bytes()
        self.__scheme = scheme.as_bytes()
        self.__path = normalise_path(self.__path_original, self.__path_original)
        self.__query_string = Bytes()
        self.__hash = Bytes()
        self.__host = host.as_bytes()
        self.__http_version = Bytes()
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

    fn path_original(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__path_original)

    fn set_path(inout self, path: String) -> Self:
        self.__path = normalise_path(path.as_bytes(), self.__path_original)
        return self

    fn set_path_bytes(inout self, path: Bytes) -> Self:
        self.__path = normalise_path(path, self.__path_original)
        return self

    fn path(self) -> String:
        return StringSlice(unsafe_from_utf8=self.path_bytes())
    
    fn path_bytes(self) -> Span[UInt8, __lifetime_of(self)]:
        if len(self.__path) == 0:
            return Span[UInt8, __lifetime_of(self)](unsafe_ptr=strSlash.unsafe_ptr(), len=len(strSlash))
        return Span[UInt8, __lifetime_of(self)](self.__path)

    fn set_scheme(inout self, scheme: String) -> Self:
        self.__scheme = scheme.as_bytes()
        return self

    fn set_scheme_bytes(inout self, scheme: Bytes) -> Self:
        self.__scheme = scheme
        return self

    fn scheme(self) -> Span[UInt8, __lifetime_of(self)]:
        if len(self.__scheme) == 0:
            return Span[UInt8, __lifetime_of(self)](unsafe_ptr=strHttp.unsafe_ptr(), len=len(strHttp))
        return Span[UInt8, __lifetime_of(self)](self.__scheme)

    fn http_version(self) -> Span[UInt8, __lifetime_of(self)]:
        if len(self.__http_version) == 0:
            return Span[UInt8, __lifetime_of(self)](unsafe_ptr=strHttp11.unsafe_ptr(), len=len(strHttp11))
        return Span[UInt8, __lifetime_of(self)](self.__http_version)

    fn http_version_str(self) -> String:
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8_ptr=self.http_version().unsafe_ptr(), len=len(self.__http_version))

    fn set_http_version(inout self, http_version: String) -> Self:
        self.__http_version = http_version.as_bytes()
        return self
    
    fn set_http_version_bytes(inout self, http_version: Bytes) -> Self:
        self.__http_version = http_version
        return self

    fn is_http_1_1(self) -> Bool:
        return bytes_equal(self.http_version(), strHttp11.as_bytes_slice())

    fn is_http_1_0(self) -> Bool:
        return bytes_equal(self.http_version(), strHttp10.as_bytes_slice())

    fn is_https(self) -> Bool:
        return bytes_equal(self.__scheme, https.as_bytes_slice())

    fn is_http(self) -> Bool:
        return bytes_equal(self.__scheme, http.as_bytes_slice()) or len(self.__scheme) == 0

    fn set_request_uri(inout self, request_uri: String) -> Self:
        self.__request_uri = request_uri.as_bytes()
        return self

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        self.__request_uri = request_uri
        return self
    
    fn request_uri(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__request_uri)

    fn set_query_string(inout self, query_string: String) -> Self:
        self.__query_string = query_string.as_bytes()
        return self

    fn set_query_string_bytes(inout self, query_string: Bytes) -> Self:
        self.__query_string = query_string
        return self
    
    fn query_string(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__query_string)

    fn set_hash(inout self, hash: String) -> Self:
        self.__hash = hash.as_bytes()
        return self

    fn set_hash_bytes(inout self, hash: Bytes) -> Self:
        self.__hash = hash
        return self

    fn hash(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__hash)

    fn set_host(inout self, host: String) -> Self:
        self.__host = host.as_bytes()
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        self.__host = host
        return self

    fn host(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__host)
    
    fn host_str(self) -> String:
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8=self.host())

    fn full_uri(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__full_uri)
    
    fn full_uri_str(self) -> String:
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8=self.full_uri())

    fn set_username(inout self, username: String) -> Self:
        self.__username = username.as_bytes()
        return self

    fn set_username_bytes(inout self, username: Bytes) -> Self:
        self.__username = username
        return self
    
    fn username(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__username)

    fn set_password(inout self, password: String) -> Self:
        self.__password = password.as_bytes()
        return self

    fn set_password_bytes(inout self, password: Bytes) -> Self:
        self.__password = password
        return self
    
    fn password(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__password)

    fn parse(inout self) raises -> None:
        var raw_uri = self.full_uri_str()
        var proto_str = String(strHttp11)
        var is_https = False

        var proto_end = raw_uri.find("://")
        var remainder_uri: String
        if proto_end >= 0:
            proto_str = raw_uri[:proto_end]
            if proto_str == https:
                is_https = True
            remainder_uri = raw_uri[proto_end + 3:]
        else:
            remainder_uri = raw_uri
        
        _ = self.set_scheme_bytes(proto_str.as_bytes())
        
        var path_start = remainder_uri.find("/")
        var host_and_port: String
        var request_uri: String
        if path_start >= 0:
            host_and_port = remainder_uri[:path_start]
            request_uri = remainder_uri[path_start:]
            _ = self.set_host(host_and_port[:path_start])
        else:
            host_and_port = remainder_uri
            request_uri = strSlash
            _ = self.set_host(host_and_port)

        if is_https:
            _ = self.set_scheme(https)
        else:
            _ = self.set_scheme(http)
        
        var n = request_uri.find("?")
        if n >= 0:
            self.__path_original = request_uri[:n].as_bytes()
            self.__query_string = request_uri[n + 1 :].as_bytes()
        else:
            self.__path_original = request_uri.as_bytes()
            self.__query_string = Bytes()

        _ = self.set_path_bytes(normalise_path(self.__path_original, self.__path_original))
        _ = self.set_request_uri(request_uri)


fn normalise_path(path: Bytes, path_original: Bytes) -> Bytes:
    # TODO: implement
    return path
