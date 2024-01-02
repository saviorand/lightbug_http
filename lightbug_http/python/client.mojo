from lightbug_http.http import HTTPRequest, HTTPResponse, encode
from lightbug_http.uri import URI
from lightbug_http.header import ResponseHeader, RequestHeader
from lightbug_http.python.net import PythonTCPListener, PythonListenConfig, PythonNet
from lightbug_http.python import Modules
from lightbug_http.service import HTTPService
from lightbug_http.io.sync import Duration
from lightbug_http.io.bytes import Bytes, UnsafeString
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
        self.host = "127.0.0.1"
        self.port = 8888
        self.name = "lightbug_http_client"

    fn __init__(inout self, host: StringLiteral, port: Int) raises:
        self.pymodules = Modules()
        self.socket = self.pymodules.socket.socket()
        self.host = host
        self.port = port
        self.name = "lightbug_http_client"

    fn do(self, req: HTTPRequest) raises -> HTTPResponse:
        var uri = req.uri()
        try:
            _ = uri.parse()
        except e:
            print("error parsing uri: " + e.__str__())

        let host = String(uri.host())

        if host == "":
            raise Error("URI is nil")
        var is_tls = False
        if uri.is_https():
            is_tls = True

        let host_port = host.split(":")
        let host_str = host_port[0]

        let port = atol(host_port[1])

        _ = self.socket.connect((UnsafeString(host_str), port))

        let data = self.pymodules.builtins.bytes(
            String(req.body_raw), CharSet.utf8.value
        )
        _ = self.socket.sendall(data)

        let res = self.socket.recv(1024).decode()
        _ = self.socket.close()

        return HTTPResponse(res.__str__()._buffer)
