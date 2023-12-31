import testing
from lightbug_http.client import Client
from lightbug_http.uri import URI
from lightbug_http.http import HTTPRequest, HTTPResponse


fn test_multiple_connections[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making multiple simultaneous connections.
    Validate that the server can handle multiple simultaneous connections without dropping or mixing up data.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # let response1 = client.get(request)
    # let response2 = client.get(request)
    # let response3 = client.get(request)
    # testing.assert_equal(response1.header.status_code(), 200)
    # testing.assert_equal(response2.header.status_code(), 200)
    # testing.assert_equal(response3.header.status_code(), 200)


fn test_idle_connections[T: Client](inout client: T) raises -> None:
    """
    WIP: Test idle connections.
    Establish a connection and then remain idle for longer than the server’s timeout setting to ensure the server properly closes the connection.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # let response = client.get(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_keep_alive[T: Client](inout client: T) raises -> None:
    """
    WIP: Test Keep-Alive.
    Validate that the server keeps the connection active during periods of inactivity as expected.
    """
    ...


fn test_keep_alive_timeout[T: Client](inout client: T) raises -> None:
    """
    WIP: Test Keep-Alive Timeout.
    Validate that the server closes the connection after the configured timeout period.
    """
    ...


fn test_port_reuse[T: Client](inout client: T) raises -> None:
    """
    WIP: Test Port Reusability.
    After the server is stopped, ensure that the TCP port it was using can be immediately reused. Validate that the server is not leaving the port in a TIME_WAIT state.
    """
    ...
