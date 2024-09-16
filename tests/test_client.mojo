import testing
from tests.utils import (
    default_server_conn_string,

)
from lightbug_http.sys.client import MojoClient
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.uri import URI
from lightbug_http.header import Header
from lightbug_http.io.bytes import bytes


def test_client():
    var mojo_client = MojoClient()
    test_mojo_client_lightbug_external_req(mojo_client)


# fn test_mojo_client_lightbug(client: MojoClient) raises:
#     var res = client.do(
#         HTTPRequest(
#             uri = URI(default_server_conn_string),
#             body_bytes = bytes("Hello world!"),
#             headers = GetRequestHeaders,
#             protocol = "GET",
#             request
#         )
#     )
#     testing.assert_equal(
#         String(res.body_raw[0:112]),
#         String(
#             "HTTP/1.1 200 OK\r\nServer: lightbug_http\r\nContent-Type:"
#             " text/plain\r\nContent-Length: 12\r\nConnection: close\r\nDate: "
#         ),
#     )


fn test_mojo_client_lightbug_external_req(client: MojoClient) raises:
    var req = HTTPRequest(
        URI("http://grandinnerastoundingspell.neverssl.com/online/"),
    )
    try:
        var res = client.do(req)
        testing.assert_equal(res.status_code, 200)
    except e:
        print(e)
