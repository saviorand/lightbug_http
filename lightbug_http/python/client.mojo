from lightbug_http.http import HTTPRequest, HTTPResponse, encode
from lightbug_http.uri import URI
from lightbug_http.header import ResponseHeader, RequestHeader
from lightbug_http.python.net import PythonTCPListener, PythonListenConfig, PythonNet
from lightbug_http.python import Modules
from lightbug_http.service import HTTPService
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes
from lightbug_http.error import ErrorHandler
from lightbug_http.strings import next_line, NetworkType, strHttp, CharSet


struct PythonClient:
    var pymodules: Modules
    var socket: PythonObject
    var name: String

    var host: StringLiteral
    var port: Int

    # var no_default_user_agent_header: Bool
    # var max_connections_per_host: Int
    # var max_idle_connection_duration: Duration
    # var max_connection_duration: Duration
    # var max_idemponent_call_attempts: Int

    fn __init__(inout self) raises:
        self.pymodules = Modules()
        self.socket = self.pymodules.socket.socket()
        self.host = "localhost"
        self.port = 80
        self.name = "lightbug_http_client"

    fn do(self, req: HTTPRequest) raises -> HTTPResponse:
        var uri = req.uri()
        var host = uri.host()
        if String(host) == "":
            raise Error("URI is nil")
        var is_tls = False
        if uri.is_https():
            is_tls = True
        elif not uri.is_http():
            raise Error("not supported: URI is not HTTP or HTTPS")

        _ = self.socket.connect((self.host, self.port))
        _ = self.socket.send(PythonObject(req.body_raw))

        let res = self.socket.recv(1024).decode()
        _ = self.socket.close()

        return HTTPResponse(res.__str__()._buffer)
