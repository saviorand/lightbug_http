import testing
from lightbug_http.python.client import PythonClient
from lightbug_http.http import HTTPRequest
from lightbug_http.net import Listener
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.tests.utils import getRequest

alias default_server_host = "localhost"
alias default_server_port = 8080
alias default_server_conn_string = "http://" + default_server_host + ":" + default_server_port.__str__()


# TODO: this test should run with a running server for now, we should parallelize them or make a fake server
fn test_python_client[T: Listener]() raises:
    let client = PythonClient()
    let res = client.do(
        HTTPRequest(
            URI(default_server_conn_string),
            String("Hello world!")._buffer,
            RequestHeader(getRequest),
        )
    )
    testing.assert_equal(
        String(res.body_raw),
        "HTTP/1.1 200 OK\r\nServer: M\r\nDate: Content-Length: 13\r\n\r\nHello world!",
    )
