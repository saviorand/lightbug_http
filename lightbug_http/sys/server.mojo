from lightbug_http.server import DefaultConcurrency
from lightbug_http.net import Listener
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.sys.net import SysListener, SysConnection, SysNet
from lightbug_http.service import HTTPService
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes, to_bytes, to_string
from lightbug_http.error import ErrorHandler
from lightbug_http.strings import next_line, NetworkType, S
from external.b64 import encode as b64_encode


struct SysServer:
    var error_handler: ErrorHandler

    var name: String
    var max_concurrent_connections: Int
    var max_requests_per_connection: Int

    var max_request_body_size: Int
    var tcp_keep_alive: Bool

    var ln: SysListener

    fn __init__(inout self) raises:
        self.error_handler = ErrorHandler()
        self.name = "lightbug_http"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.max_request_body_size = 0
        self.tcp_keep_alive = False
        self.ln = SysListener()

    fn __init__(inout self, error_handler: ErrorHandler) raises:
        self.error_handler = error_handler
        self.name = "lightbug_http"
        self.max_concurrent_connections = 1000
        self.max_requests_per_connection = 0
        self.max_request_body_size = 0
        self.tcp_keep_alive = False
        self.ln = SysListener()

    fn get_concurrency(self) -> Int:
        var concurrency = self.max_concurrent_connections
        if concurrency <= 0:
            concurrency = DefaultConcurrency
        return concurrency

    fn listen_and_serve[
        T: HTTPService
    ](inout self, address: String, handler: T) raises -> None:
        var __net = SysNet()
        let listener = __net.listen(NetworkType.tcp4.value, address)
        self.serve(listener, handler)

    fn listen_and_serve_async[
        T: HTTPService
    ](inout self, address: String, handler: T) raises -> None:
        var __net = SysNet()
        let listener = __net.listen(NetworkType.tcp4.value, address)
        self.serve_async(listener, handler)

    fn serve_async[
        T: HTTPService
    ](inout self, ln: SysListener, handler: T) raises -> None:
        self.ln = ln
        # let max_worker_count = self.get_concurrency()
        # TODO: logic for non-blocking read and write here, see for example https://github.com/valyala/fasthttp/blob/9ba16466dfd5d83e2e6a005576ee0d8e127457e2/server.go#L1789

        async fn handle_connection(conn: SysConnection, handler: T) -> None:
            var buf = Bytes()
            try:
                let read_len = await conn.read_async(buf)
            except e:
                try:
                    conn.close()
                except e:
                    print("Failed to close connection")
                print("Failed to read from connection")
            try:
                let first_line_and_headers = next_line(buf)
                let request_line = first_line_and_headers.first_line
                let rest_of_headers = first_line_and_headers.rest

                var uri = URI(request_line)
                try:
                    uri.parse()
                except:
                    try:
                        conn.close()
                    except e:
                        print("Failed to close connection")
                    print("Failed to parse request line")

                var header = RequestHeader(buf)
                try:
                    header.parse()
                except:
                    try:
                        conn.close()
                    except e:
                        print("Failed to close connection")
                    print("Failed to parse request header")

                let res = handler.func(
                    HTTPRequest(
                        uri,
                        buf,
                        header,
                    )
                )
                var res_encoded = encode(res)
                try:
                    _ = await conn.write_async(res_encoded)
                except e:
                    print("Ooph! " + e.__str__())
                    try:
                        conn.close()
                    except e:
                        print("Failed to close connection")
                    print("Failed to read from connection")
                try:
                    conn.close()
                except e:
                    print("Failed to close connection")
            except e:
                print("Failed to parse request line")
                try:
                    conn.close()
                except e:
                    print("Failed to close connection")

        while True:
            let conn = self.ln.accept[SysConnection]()
            let coroutine: Coroutine[NoneType] = handle_connection(conn, handler)
            _ = coroutine()  # Execute the coroutine synchronously

    fn serve[T: HTTPService](inout self, ln: SysListener, handler: T) raises -> None:
        self.ln = ln

        while True:
            let conn = self.ln.accept[SysConnection]()
            var buf = Bytes()
            let read_len = conn.read(buf)
            let first_line_and_headers = next_line(buf)
            let request_line = first_line_and_headers.first_line
            let rest_of_headers = first_line_and_headers.rest

            var uri = URI(request_line)
            try:
                uri.parse()
            except:
                conn.close()
                raise Error("Failed to parse request line")

            var header = RequestHeader(buf)
            try:
                header.parse()
            except:
                conn.close()
                raise Error("Failed to parse request header")

            let res = handler.func(
                HTTPRequest(
                    uri,
                    buf,
                    header,
                )
            )
            let res_encoded = encode(res)
            _ = conn.write(res_encoded)
            conn.close()
