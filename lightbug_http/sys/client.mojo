from ..libc import (
    c_int,
    AF_INET,
    SOCK_STREAM,
    socket,
    connect,
    send,
    recv,
    close,
)
from lightbug_http.strings import to_string
from lightbug_http.client import Client
from lightbug_http.net import default_buffer_size
from lightbug_http.http import HTTPRequest, HTTPResponse, encode
from lightbug_http.header import Headers, HeaderKey
from lightbug_http.sys.net import create_connection
from lightbug_http.io.bytes import Bytes
from lightbug_http.utils import ByteReader


struct MojoClient(Client):
    var host: StringLiteral
    var port: Int
    var name: String

    fn __init__(inout self) raises:
        self.host = "127.0.0.1"
        self.port = 8888
        self.name = "lightbug_http_client"

    fn __init__(inout self, host: StringLiteral, port: Int) raises:
        self.host = host
        self.port = port
        self.name = "lightbug_http_client"

    fn do(self, owned req: HTTPRequest) raises -> HTTPResponse:
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
        var uri = req.uri
        var host = uri.host

        if host == "":
            raise Error("URI is nil")
        var is_tls = False

        if uri.is_https():
            is_tls = True

        var host_str: String
        var port: Int

        if ":" in host:
            var host_port = host.split(":")
            host_str = host_port[0]
            port = atol(host_port[1])
        else:
            host_str = host
            if is_tls:
                port = 443
            else:
                port = 80

        # TODO: Actually handle persistent connections
        var conn = create_connection(socket(AF_INET, SOCK_STREAM, 0), host_str, port)
        var bytes_sent = conn.write(encode(req))
        if bytes_sent == -1:
            raise Error("Failed to send message")

        var new_buf = Bytes(capacity=default_buffer_size)
        var bytes_recv = conn.read(new_buf)

        if bytes_recv == 0:
            conn.close()
        try:
            var res = HTTPResponse.from_bytes(new_buf^)
            if res.is_redirect():
                conn.close()
                return self._handle_redirect(req^, res^)
            return res
        except e:
            conn.close()
            raise e

        return HTTPResponse(Bytes())

    fn _handle_redirect(
        self, owned original_req: HTTPRequest, owned original_response: HTTPResponse
    ) raises -> HTTPResponse:
        var new_uri: URI
        var new_location = original_response.headers[HeaderKey.LOCATION]
        if new_location.startswith("http"):
            new_uri = URI.parse_raises(new_location)
            original_req.headers[HeaderKey.HOST] = new_uri.host
        else:
            new_uri = original_req.uri
            new_uri.path = new_location
        original_req.uri = new_uri
        return self.do(original_req^)
