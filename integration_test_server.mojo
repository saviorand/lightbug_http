from lightbug_http import *

@value
struct IntegerationTestService(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var p = req.uri.path
        if p == "/redirect":
            return HTTPResponse(
                "get off my lawn".as_bytes_slice(),
                headers=Headers(
                    Header(HeaderKey.LOCATION, "/rd-destination")
                ),
                status_code=StatusCode.PERMANENT_REDIRECT
            )
        elif p == "/rd-destination":
            return OK("yay you made it")
        elif p == "/close-connection":
            return OK("connection closed")

        return NotFound("wrong")

fn main() raises:
    var server = Server(tcp_keep_alive=True)
    server.listen_and_serve("127.0.0.1:8080", IntegerationTestService())
            