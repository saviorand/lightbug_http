import testing
from lightbug_http.python.server import PythonServer, PythonTCPListener
from lightbug_http.python.client import PythonClient
from lightbug_http.python.net import PythonListenConfig
from lightbug_http.http import HTTPRequest
from lightbug_http.net import Listener
from lightbug_http.client import Client
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.tests.utils import (
    getRequest,
    default_server_conn_string,
    defaultExpectedGetResponse,
)
from lightbug_http.sys.libc import (
    AF_INET,
    AF_INET6,
    SOCK_STREAM,
    SOL_SOCKET,
    SO_REUSEADDR,
    SHUT_RDWR,
    c_char,
    c_int,
    c_uint,
    c_void,
    socklen_t,
    sockaddr,
    sockaddr_in,
    inet_pton,
    htons,
    socket,
    setsockopt,
    send,
    bind,
    listen,
    accept,
    close,
    shutdown,
    sizeof,
    to_char_ptr,
    Pointer,
    StaticTuple,
)


fn main():
    try:
        __test_socket_server__()
    except e:
        print("Server failed: " + e.__str__())


fn __test_socket_server__() raises:
    let ip_addr = "127.0.0.1"
    let port = 8080

    let address_family = AF_INET
    var ip_buf_size = 4
    if address_family == AF_INET6:
        ip_buf_size = 16

    let ip_buf = Pointer[c_void].alloc(ip_buf_size)
    let conv_status = inet_pton(address_family, to_char_ptr(ip_addr), ip_buf)
    let raw_ip = ip_buf.bitcast[c_uint]().load()

    print("inet_pton: " + raw_ip.__str__() + " :: status: " + conv_status.__str__())

    let bin_port = htons(UInt16(port))
    print("htons: " + "\n" + bin_port.__str__())

    var ai = sockaddr_in(address_family, bin_port, raw_ip, StaticTuple[8, c_char]())
    let ai_ptr = Pointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()

    let sockfd = socket(address_family, SOCK_STREAM, 0)
    if sockfd == -1:
        print("Socket creation error")
    print("sockfd: " + "\n" + sockfd.__str__())

    var yes: Int = 1
    if (
        setsockopt(
            sockfd,
            SOL_SOCKET,
            SO_REUSEADDR,
            Pointer[Int].address_of(yes).bitcast[c_void](),
            sizeof[Int](),
        )
        == -1
    ):
        print("set socket options failed")

    if bind(sockfd, ai_ptr, sizeof[sockaddr_in]()) == -1:
        # close(sockfd)
        _ = shutdown(sockfd, SHUT_RDWR)
        print("Binding socket failed")

    if listen(sockfd, c_int(128)) == -1:
        print("Listen failed.\n on sockfd " + sockfd.__str__())

    print(
        "server: started at "
        + ip_addr
        + ":"
        + port.__str__()
        + " on sockfd "
        + sockfd.__str__()
        + "Waiting for connections..."
    )

    while True:  # Add this loop
        let their_addr_ptr = Pointer[sockaddr].alloc(1)
        var sin_size = socklen_t(sizeof[socklen_t]())
        let new_sockfd = accept(
            sockfd, their_addr_ptr, Pointer[socklen_t].address_of(sin_size)
        )
        if new_sockfd == -1:
            print("Accept failed")
            continue  # Continue listening even if accept fails

        let msg = "Hello, Mojo!"
        if send(new_sockfd, to_char_ptr(msg).bitcast[c_void](), len(msg), 0) == -1:
            print("Failed to send response")
        print("Message sent succesfully")

        # Close the connection-specific socket after handling the connection
        _ = shutdown(new_sockfd, SHUT_RDWR)
        let close_status = close(new_sockfd)
        if close_status == -1:
            print("Failed to close new_sockfd")

    # Optionally, close the main server socket if you ever exit the loop
    # close(sockfd)


fn test_python_server[C: Client](client: C, ln: PythonListenConfig) raises -> None:
    """
    Run a server listening on a port.
    Validate that the server is listening on the provided port.
    """
    ...
    # let conn = ln.accept()
    # let res = client.do(
    #     HTTPRequest(
    #         URI(default_server_conn_string),
    #         String("Hello world!")._buffer,
    #         RequestHeader(getRequest),
    #     )
    # )
    # testing.assert_equal(
    #     String(res.body_raw),
    #     defaultExpectedGetResponse,
    # )


fn test_server_busy_port() raises -> None:
    """
    Test that we get an error if we try to run a server on a port that is already in use.
    """
    ...


fn test_server_invalid_host() raises -> None:
    """
    Test that we get an error if we try to run a server on an invalid host.
    """
    ...


fn test_tls() raises -> None:
    """
    TLS Support.
    Validate that the server supports TLS.
    """
    ...
