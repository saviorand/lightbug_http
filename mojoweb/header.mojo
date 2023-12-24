from mojoweb.utils import Bytes

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

    var method: Bytes
    var request_uri: Bytes
    var proto: Bytes
    var host: Bytes
    var content_type: Bytes
    var user_agent: Bytes
    # TODO: var mul_header

    # TODO: var cookies

    # immutable copy of original headers
    var raw_headers: Bytes


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

    fn status_code(self) -> Int:
        if self.__status_code == 0:
            return statusOK
        return self.__status_code

    fn set_status_code(inout self, code: Int):
        self.__status_code = code
