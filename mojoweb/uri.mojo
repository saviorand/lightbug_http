from mojoweb.utils import Bytes, bytes_equal
from mojoweb.args import Args
from mojoweb.strings import strSlash, strHttp, strHttps


fn normalise_path(path: Bytes, path_original: Bytes) -> Bytes:
    # TODO: implement
    return path


# TODO: fn unescape()
# TODO fn should_escape()


@value
struct URI:
    var __path_original: Bytes
    var __scheme: Bytes
    var __path: Bytes
    var __query_string: Bytes
    var __hash: Bytes
    var __host: Bytes

    var __query_args: Args
    var parsed_query_args: Bool

    var disable_path_normalization: Bool

    var __full_uri: Bytes
    var __request_uri: Bytes

    var __username: Bytes
    var __password: Bytes

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
        self.__query_args = Args()
        self.parsed_query_args = False
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
        parsed_query_args: Bool,
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
        self.__query_args = Args()
        self.parsed_query_args = parsed_query_args
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

    fn set_path_bytes(inout self, path: Bytes) -> Self:
        self.__path = normalise_path(path, self.__path_original)
        return self

    fn path(self) -> Bytes:
        var processed_path = self.__path
        if len(processed_path) == 0:
            processed_path = strSlash
        return processed_path

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

    fn is_https(self) -> Bool:
        return bytes_equal(self.__scheme, strHttps)

    fn is_http(self) -> Bool:
        return bytes_equal(self.__scheme, strHttp) or len(self.__scheme) == 0

    fn set_query_string(inout self, query_string: String) -> Self:
        self.__query_string = query_string._buffer
        self.parsed_query_args = False
        return self

    fn set_query_string_bytes(inout self, query_string: Bytes) -> Self:
        self.__query_string = query_string
        self.parsed_query_args = False
        return self

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

    # TODO: fn parse()
    # TODO: fn parse_host()

    fn request_uri(self) -> Bytes:
        # TODO: implement processing logic
        return self.__request_uri

    fn set_username(inout self, username: String) -> Self:
        self.__username = username._buffer
        return self

    fn set_username_bytes(inout self, username: Bytes) -> Self:
        self.__username = username
        return self

    fn set_password(inout self, password: String) -> Self:
        self.__password = password._buffer
        return self

    fn set_password_bytes(inout self, password: Bytes) -> Self:
        self.__password = password
        return self
