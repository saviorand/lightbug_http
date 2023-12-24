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
        path: Bytes,
        scheme: Bytes,
        query_string: Bytes,
        hash: Bytes,
        host: Bytes,
        disable_path_normalization: Bool,
        full_uri: Bytes,
        request_uri: Bytes,
        username: Bytes,
        password: Bytes,
    ):
        self.__path_original = Bytes()
        self.__scheme = scheme
        self.__path = path
        self.__query_string = query_string
        self.__hash = hash
        self.__host = host
        self.__query_args = Args()
        self.parsed_query_args = False
        self.disable_path_normalization = disable_path_normalization
        self.__full_uri = full_uri
        self.__request_uri = request_uri
        self.__username = username
        self.__password = password

    # assign paths
    fn __init__(
        inout self,
        path_original: Bytes,
        path: Bytes,
        scheme: Bytes,
        query_string: Bytes,
        hash: Bytes,
        host: Bytes,
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
        self.parsed_query_args = False
        self.disable_path_normalization = disable_path_normalization
        self.__full_uri = full_uri
        self.__request_uri = request_uri
        self.__username = username
        self.__password = password

    # assign parsed query args
    fn __init__(
        inout self,
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
        self.__path_original = Bytes()
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

    fn path_original(inout self) -> Bytes:
        return self.__path_original

    fn path(inout self) -> Bytes:
        var processed_path = self.__path
        if len(processed_path) == 0:
            processed_path = strSlash
        return processed_path

    fn set_path(inout self, path: String) -> Self:
        return Self(
            path._buffer,
            normalise_path(path._buffer, self.__path_original),
            self.__scheme,
            self.__query_string,
            self.__hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn set_path_bytes(inout self, path: Bytes) -> Self:
        return Self(
            path,
            normalise_path(path, self.__path_original),
            self.__scheme,
            self.__query_string,
            self.__hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn scheme(inout self) -> Bytes:
        var processed_scheme = self.__scheme
        if len(processed_scheme) == 0:
            processed_scheme = strHttp
        return processed_scheme

    fn set_scheme(self, scheme: String) -> Self:
        return Self(
            self.__path,
            scheme._buffer,
            self.__query_string,
            self.__hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn set_scheme_bytes(inout self, scheme: Bytes) -> Self:
        return Self(
            self.__path,
            scheme,
            self.__query_string,
            self.__hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn is_https(inout self) -> Bool:
        return bytes_equal(self.__scheme, strHttps)

    fn is_http(inout self) -> Bool:
        return bytes_equal(self.__scheme, strHttp) or len(self.__scheme) == 0

    fn set_query_string(inout self, query_string: String) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            query_string._buffer,
            self.__hash,
            self.__host,
            False,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn set_query_string_bytes(inout self, query_string: Bytes) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            query_string,
            self.__hash,
            self.__host,
            False,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn hash(inout self) -> Bytes:
        return self.__hash

    fn set_hash(inout self, hash: String) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            self.__query_string,
            hash._buffer,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn set_hash_bytes(inout self, hash: Bytes) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            self.__query_string,
            hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn host(inout self) -> Bytes:
        return self.__host

    fn set_host(inout self, host: String) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            self.__query_string,
            self.__hash,
            host._buffer,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            self.__query_string,
            self.__hash,
            host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            self.__password,
        )

    # TODO: fn parse()
    # TODO: fn parse_host()

    fn set_username(inout self, username: String) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            self.__query_string,
            self.__hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            username._buffer,
            self.__password,
        )

    fn set_username_bytes(inout self, username: Bytes) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            self.__query_string,
            self.__hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            username,
            self.__password,
        )

    fn set_password(inout self, password: String) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            self.__query_string,
            self.__hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            password._buffer,
        )

    fn set_password_bytes(inout self, password: Bytes) -> Self:
        return Self(
            self.__path,
            self.__scheme,
            self.__query_string,
            self.__hash,
            self.__host,
            self.disable_path_normalization,
            self.__full_uri,
            self.__request_uri,
            self.__username,
            password,
        )
