from mojoweb.http import Response
from mojoweb.header import ResponseHeader


@value
struct ErrorHandler:
    fn Error(self) -> Response:
        return Response(ResponseHeader(), String("TODO")._buffer)
