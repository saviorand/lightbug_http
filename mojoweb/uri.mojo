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

    fn __init__(inout self, host: Bytes, path: Bytes, query_string: Bytes, hash: Bytes):
        self.host = host
        self.path_original = path
        self.query_string = query_string
        self.hash = hash

    fn __copyinit__(inout self, other: Self):
        print("Cannot copy URI")

    # fn set_host(inout self, host: String):
    #     self.host = host._buffer
