from lightbug_http.client import Client
from lightbug_http.http import HTTPRequest, HTTPResponse
from lightbug_http.sys.net import create_connection
from lightbug_http.io.bytes import Bytes
from external.libc import (
    c_int,
    AF_INET,
    SOCK_STREAM,
    socket,
    connect,
    send,
    recv,
    close,
)


struct MojoClient(Client):
    var fd: c_int
    var host: StringLiteral
    var port: Int
    var name: String

    fn __init__(inout self) raises:
        self.fd = socket(AF_INET, SOCK_STREAM, 0)
        self.host = "127.0.0.1"
        self.port = 8888
        self.name = "lightbug_http_client"

    fn __init__(inout self, host: StringLiteral, port: Int) raises:
        self.fd = socket(AF_INET, SOCK_STREAM, 0)
        self.host = host
        self.port = port
        self.name = "lightbug_http_client"

    fn do(self, req: HTTPRequest) raises -> HTTPResponse:
        """
        The `do` method is responsible for sending an HTTP request to a server and receiving the corresponding response.

        It performs the following steps:
        1. Creates a connection to the server specified in the request.
        2. Sends the request body using the connection.
        3. Receives the response from the server.
        4. Closes the connection.
        5. Returns the received response as an `HTTPResponse` object.

        Note: The code assumes that the `HTTPRequest` object passed as an argument has a valid URI with a host and port specified.

        Parameters
        ----------
        req : HTTPRequest :
            An `HTTPRequest` object representing the request to be sent.

        Returns
        -------
        HTTPResponse :
            The received response.

        Raises
        ------
        Error :
            If there is a failure in sending or receiving the message.
        """
        var uri = req.uri()
        try:
            _ = uri.parse()
        except e:
            print("error parsing uri: " + e.__str__())

        var host = String(uri.host())

        if host == "":
            raise Error("URI is nil")
        var is_tls = False
        if uri.is_https():
            is_tls = True

        var host_str: String
        var port: Int

        if host.__contains__(":"):
            var host_port = host.split(":")
            host_str = host_port[0]
            port = atol(host_port[1])
        else:
            host_str = host
            if is_tls:
                port = 443
            else:
                port = 80

        var conn = create_connection(self.fd, host_str, port)

        var bytes_sent = conn.write(req.get_body())
        if bytes_sent == -1:
            raise Error("Failed to send message")

        var response: String = ""
        var new_buf = Bytes()
        while True:
            var bytes_recv = conn.read(new_buf)
            if bytes_recv == -1:
                raise Error("Failed to receive message")
            elif bytes_recv == 0:
                break
            else:
                response += String(new_buf)

        conn.close()

        return HTTPResponse(response._buffer)
