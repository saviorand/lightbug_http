from lightbug_http.http import HTTPResponse
from lightbug_http.header import ResponseHeader


# TODO: Custom error handlers provided by the user
@value
struct ErrorHandler:
    fn Error(self) -> HTTPResponse:
        return HTTPResponse(ResponseHeader(), String("TODO")._buffer)


alias errNeedMore = Error("need more data: cannot find trailing lf")
alias errInvalidName = Error("invalid header name")
alias errSmallBuffer = Error("small read buffer. Increase ReadBufferSize")
