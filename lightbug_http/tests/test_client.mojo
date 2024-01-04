import testing
from lightbug_http.python.client import PythonClient
from lightbug_http.http import HTTPRequest
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.tests.utils import getRequest


fn test_client_lightbug() raises:
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
