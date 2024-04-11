from lightbug_http.client import Client
from lightbug_http.http import HTTPRequest, HTTPResponse
from lightbug_http.sys.net import create_connection
from lightbug_http.io.bytes import Bytes
from external.libc import (
    c_void,
    c_int,
    c_uint,
    c_char,
    sockaddr,
    sockaddr_in,
    AF_INET,
    SOCK_STREAM,
    SHUT_RDWR,
    htons,
    inet_pton,
    to_char_ptr,
    socket,
    connect,
    send,
    recv,
    shutdown,
    close,
)


struct HTTPClient(Client):
    var host: StringLiteral
    var port: Int
    var sock: c_int

    fn __init__(inout self) raises:
        self.host = "localhost"
        self.port = 80
        self.sock = socket(AF_INET, SOCK_STREAM, 0)

    fn __init__(inout self, host: StringLiteral, port: Int) raises:
        self.host = host
        self.port = port
        self.sock = socket(AF_INET, SOCK_STREAM, 0)

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

        Examples
        --------
        ```mojo
        client = HTTPClient()
        request = HTTPRequest(...)
        response = client.do(request)
        ```
        """
        # Create a connection to the server of the request
        var uri = req.uri()
        _ = uri.parse()
        var host_port = String(uri.host()).split(":")
        var host = host_port[0]
        var port = atol(host_port[1])
        var conn = create_connection(self.sock, host, port)

        # Send the request
        var bytes_sent = conn.write(req.get_body())
        if bytes_sent == -1:
            raise Error("Failed to send message")

        # Receive the response
        var response: String = ""
        var buf_2 = Bytes()
        while True:
            var bytes_recv = conn.read(buf_2)
            if bytes_recv == -1:
                raise Error("Failed to receive message")
            elif bytes_recv == 0:
                break
            else:
                response += String(buf_2)

        conn.close()

        return HTTPResponse(response._buffer)


struct MojoClient(Client):
    var fd: c_int
    var name: String

    var host: StringLiteral
    var port: Int

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

    fn close(self) raises:
        _ = shutdown(self.fd, SHUT_RDWR)
        var close_status = close(self.fd)
        if close_status == -1:
            print("Failed to close new_sockfd")

    fn do(self, req: HTTPRequest) raises -> HTTPResponse:
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

        var host_port = host.split(":")
        var host_str = host_port[0]

        var ip_buf = Pointer[c_void].alloc(4)
        var conv_status = inet_pton(AF_INET, to_char_ptr(host_str), ip_buf)
        var raw_ip = ip_buf.bitcast[c_uint]().load()

        var port = atol(host_port[1])

        var bin_port = htons(UInt16(port))

        var ai = sockaddr_in(AF_INET, bin_port, raw_ip, StaticTuple[c_char, 8]())
        var ai_ptr = Pointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()

        if connect(self.fd, ai_ptr, sizeof[sockaddr_in]()) == -1:
            _ = shutdown(self.fd, SHUT_RDWR)
            raise Error("Connection error")  # Ensure to exit if connection fails

        var bytes_sent = send(self.fd, to_char_ptr(req.body_raw), len(req.body_raw), 0)
        if bytes_sent == -1:
            print("Failed to send message")

        var buf_size = 1024
        var buf = Pointer[UInt8]().alloc(buf_size)
        var bytes_recv = recv(self.fd, buf, buf_size, 0)
        var bytes_str = String(buf.bitcast[Int8](), bytes_recv)
        _ = close(self.fd)

        return HTTPResponse(bytes_str._buffer)
