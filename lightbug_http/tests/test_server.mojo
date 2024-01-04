import testing
from lightbug_http.python.server import PythonServer, PythonTCPListener

"""
Run a server listening on a port.
Validate that the server is listening on the provided port.
"""


fn test_server(ln: PythonTCPListener) raises -> None:
    """
    Test making a simple GET request without parameters.
    Validate that we get a 200 OK response.
    """
    ...


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
