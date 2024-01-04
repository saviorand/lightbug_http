import testing
from lightbug_http.client import Client
from lightbug_http.http import HTTPRequest
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.tests.utils import getRequest, defaultExpectedGetResponse


fn test_client_lightbug[T: Client](client: T) raises:
    let res = client.do(
        HTTPRequest(
            URI("0.0.0.0:8080"),
            String("Hello world!")._buffer,
            RequestHeader(getRequest),
        )
    )
    testing.assert_equal(
        String(res.body_raw),
        defaultExpectedGetResponse,
    )
