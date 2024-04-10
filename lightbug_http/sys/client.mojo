from lightbug_http.client import Client
from lightbug_http.http import HTTPRequest, HTTPResponse
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
