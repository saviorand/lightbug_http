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
        self.path_original = path
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

    fn set_host(inout self, host: String) -> Self:
        return Self(
            self.path_original,
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
