import testing
from time import sleep
from random import random_ui64
from lightbug_http.python.server import PythonServer
from lightbug_http.python.client import PythonClient
from lightbug_http.http import HTTPRequest
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.python.net import PythonNet, PythonConnection
from lightbug_http.tests.utils import FakeResponder, getRequest
from algorithm import parallelize


# TODO: this test should run with a running server for now, we should parallelize them or make a fake server
fn test_client() raises:
    let client = PythonClient()
    let res = client.do(
        HTTPRequest(
            URI("0.0.0.0:8080"),
            String("Hello world!")._buffer,
            RequestHeader(getRequest),
        )
    )
    testing.assert_equal(
        String(res.body_raw),
        "HTTP/1.1 200 OK\r\nServer: M\r\nDate: Content-Length: 13\r\n\r\nHello world!",
    )
