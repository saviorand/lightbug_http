import testing
from lightbug_http.python.server import PythonServer
from lightbug_http.python.client import PythonClient
from lightbug_http.http import HTTPRequest
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.python.net import PythonNet, PythonConnection
from lightbug_http.tests.utils import FakeResponder, getRequest


fn test_client() raises:
    # var server = PythonServer()
    # var __net = PythonNet()
    # let handler = FakeResponder()
    let client = PythonClient()
    # let listener = __net.listen("tcp4", "0.0.0.0:8080")
    # server.serve(listener, handler)
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


fn main():
    try:
        test_client()
    except e:
        print("test failed " + e.__str__())
