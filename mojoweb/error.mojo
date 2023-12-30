from mojoweb.http import HTTPResponse
from mojoweb.header import ResponseHeader


@value
struct ErrorHandler:
    fn Error(self) -> HTTPResponse:
        return HTTPResponse(ResponseHeader(), String("TODO")._buffer)
