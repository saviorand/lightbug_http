import testing
from tests.utils import (
    default_server_conn_string,
)
from lightbug_http.sys.client import MojoClient
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.uri import URI
from lightbug_http.header import Header, Headers
from lightbug_http.io.bytes import bytes


def test_client():
    var mojo_client = MojoClient()
    test_mojo_client_lightbug_external_req(mojo_client)


fn test_mojo_client_lightbug_external_req(client: MojoClient) raises:
    var req = HTTPRequest(
        uri=URI.parse("http://httpbin.org/status/200")[URI],
        headers=Headers(
            Header("Connection", "keep-alive"),
            Header("Host", "httpbin.org")),
        method="GET",
    )
    
    try:
        var res = client.do(req)
        testing.assert_equal(res.status_code, 200)

    except e:
        print(e)
