from lightbug_http import *
from lightbug_http.io.bytes import bytes

@value
struct MyPrinter(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var body = req.body_raw
        return HTTPResponse(bytes("howdy"))
    

fn main() raises:
    var server = SysServer(tcp_keep_alive = True)
    var handler = MyPrinter()
    server.listen_and_serve("0.0.0.0:8080", handler)
