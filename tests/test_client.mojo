from external.gojo.tests.wrapper import MojoTest
from external.morrow import Morrow
from tests.utils import (
    default_server_conn_string,
    getRequest,
)
from lightbug_http.python.client import PythonClient
from lightbug_http.sys.client import MojoClient
from lightbug_http.http import HTTPRequest, encode
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from lightbug_http.io.bytes import bytes


def test_client():
    var mojo_client = MojoClient()
    # test_mojo_client_lightbug(mojo_client)
    test_mojo_client_lightbug_external_req(mojo_client)
    
    # var py_client = PythonClient()
    # test_python_client_lightbug(py_client) - this is broken for now due to issue with passing a tuple to self.socket.connect()


fn test_mojo_client_lightbug(client: MojoClient) raises:
    var test = MojoTest("test_mojo_client_lightbug")
    var res = client.do(
        HTTPRequest(
            URI(default_server_conn_string),
            bytes("Hello world!"),
            RequestHeader(getRequest),
        )
    )
    test.assert_equal(
        String(res.body_raw[0:112]),
        String(
            "HTTP/1.1 200 OK\r\nServer: lightbug_http\r\nContent-Type:"
            " text/plain\r\nContent-Length: 12\r\nConnection: close\r\nDate: "
        ),
    )


fn test_mojo_client_lightbug_external_req(client: MojoClient) raises:
    var test = MojoTest("test_mojo_client_lightbug_external_req")
    var req = HTTPRequest(
        URI("http://grandinnerastoundingspell.neverssl.com/online/"),
    )
    try:
        var res = client.do(req)
        test.assert_equal(res.header.status_code(), 200)
    except e:
        print(e)


fn test_python_client_lightbug(client: PythonClient) raises:
    var test = MojoTest("test_python_client_lightbug")
    var res = client.do(
        HTTPRequest(
            URI(default_server_conn_string),
            bytes("Hello world!"),
            RequestHeader(getRequest),
        )
    )
    test.assert_equal(
        String(res.body_raw[0:112]),
        String(
            "HTTP/1.1 200 OK\r\nServer: lightbug_http\r\nContent-Type:"
            " text/plain\r\nContent-Length: 12\r\nConnection: close\r\nDate: "
        ),
    )
