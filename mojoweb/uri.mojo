from mojoweb.utils import Bytes
from mojoweb.args import Args


@value
struct URI:
    var path_original: Bytes
    var scheme: Bytes
    var path: Bytes
    var query_string: Bytes
    var hash: Bytes
    var host: Bytes

    var query_args: Args
    var parsed_query_args: Bool

    var disable_path_normalization: Bool

    var full_uri: Bytes
    var request_uri: Bytes

    var username: Bytes
    var password: Bytes

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
        self.path_original = Bytes()
        self.scheme = scheme
        self.path = path
        self.query_string = query_string
        self.hash = hash
        self.host = host
        self.query_args = Args()
        self.parsed_query_args = False
        self.disable_path_normalization = disable_path_normalization
        self.full_uri = full_uri
        self.request_uri = request_uri
        self.username = username
        self.password = password

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
        self.path_original = Bytes()
        self.scheme = scheme
        self.path = path
        self.query_string = query_string
        self.hash = hash
        self.host = host
        self.query_args = Args()
        self.parsed_query_args = parsed_query_args
        self.disable_path_normalization = disable_path_normalization
        self.full_uri = full_uri
        self.request_uri = request_uri
        self.username = username
        self.password = password

    # TODO: fn set_path(inout self, path: String) -> Self:

    # TODO: fn set_path_bytes(inout self, path: Bytes) -> Self:

    # TODO: fn set_scheme(inout self, scheme: String) -> Self:

    # TODO: fn set_scheme_bytes(inout self, scheme: Bytes) -> Self:

    fn set_query_string(inout self, query_string: String) -> Self:
        return Self(
            self.path,
            self.scheme,
            query_string._buffer,
            self.hash,
            self.host,
            False,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            self.username,
            self.password,
        )

    fn set_query_string_bytes(inout self, query_string: Bytes) -> Self:
        return Self(
            self.path,
            self.scheme,
            query_string,
            self.hash,
            self.host,
            False,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            self.username,
            self.password,
        )

    fn set_hash(inout self, hash: String) -> Self:
        return Self(
            self.path,
            self.scheme,
            self.query_string,
            hash._buffer,
            self.host,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            self.username,
            self.password,
        )

    fn set_hash_bytes(inout self, hash: Bytes) -> Self:
        return Self(
            self.path,
            self.scheme,
            self.query_string,
            hash,
            self.host,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            self.username,
            self.password,
        )

    fn set_host(inout self, host: String) -> Self:
        return Self(
            self.path,
            self.scheme,
            self.query_string,
            self.hash,
            host._buffer,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            self.username,
            self.password,
        )

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        return Self(
            self.path,
            self.scheme,
            self.query_string,
            self.hash,
            host,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            self.username,
            self.password,
        )

    fn set_username(inout self, username: String) -> Self:
        return Self(
            self.path,
            self.scheme,
            self.query_string,
            self.hash,
            self.host,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            username._buffer,
            self.password,
        )

    fn set_username_bytes(inout self, username: Bytes) -> Self:
        return Self(
            self.path,
            self.scheme,
            self.query_string,
            self.hash,
            self.host,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            username,
            self.password,
        )

    fn set_password(inout self, password: String) -> Self:
        return Self(
            self.path,
            self.scheme,
            self.query_string,
            self.hash,
            self.host,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            self.username,
            password._buffer,
        )

    fn set_password_bytes(inout self, password: Bytes) -> Self:
        return Self(
            self.path,
            self.scheme,
            self.query_string,
            self.hash,
            self.host,
            self.disable_path_normalization,
            self.full_uri,
            self.request_uri,
            self.username,
            password,
        )
