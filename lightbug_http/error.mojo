from lightbug_http.http import HTTPResponse
from lightbug_http.header import ResponseHeader


@value
struct ErrorHandler:
    fn Error(self) -> HTTPResponse:
        return HTTPResponse(ResponseHeader(), String("TODO")._buffer)
