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


fn test_python_server[C: Client](client: C, ln: PythonListenConfig) raises -> None:
    """
    Run a server listening on a port.
    Validate that the server is listening on the provided port.
    """
    ...
    # var conn = ln.accept()
    # var res = client.do(
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
