from mojoweb.http import Response
from mojoweb.header import ResponseHeader


@value
struct Error:
    fn Error(self) -> Response:
        return Response(ResponseHeader(), String("TODO")._buffer)
