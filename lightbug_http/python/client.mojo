from lightbug_http.client import Client
from lightbug_http.http import HTTPRequest, HTTPResponse
from lightbug_http.python import Modules
from lightbug_http.io.bytes import Bytes, UnsafeString
from lightbug_http.strings import CharSet


struct PythonClient(Client):
    var pymodules: Modules
    var socket: PythonObject
    var name: String

    var host: StringLiteral
    var port: Int

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
