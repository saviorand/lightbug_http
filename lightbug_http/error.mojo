from lightbug_http.http import HTTPResponse
from lightbug_http.header import ResponseHeader
from lightbug_http.io.bytes import bytes

# TODO: Custom error handlers provided by the user
@value
struct ErrorHandler:
    fn Error(self) -> HTTPResponse:
        return HTTPResponse(ResponseHeader(), bytes("TODO"))