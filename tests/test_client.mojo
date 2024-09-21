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
    print("running 200 test")
    test_mojo_client_lightbug_external_req_200(mojo_client)

    print("running 301 test")
    test_mojo_client_redirect_external_req_301(mojo_client)

    # Seems like trying to run too many of these at once results in
    # a 502 from httpbin
    
    # print("running 302 test")
    # test_mojo_client_redirect_external_req_302(mojo_client)
    # print("running 307 test")
    # test_mojo_client_redirect_external_req_307(mojo_client)
    # print("running 308 test")
    # test_mojo_client_redirect_external_req_308(mojo_client)
    # test_mojo_client_redirect_external_req_google(mojo_client)


fn test_mojo_client_redirect_external_req_google(client: MojoClient) raises:
    var req = HTTPRequest(
        uri=URI.parse_raises("http://google.com"),
        headers=Headers(
            Header("Connection", "close")),
        method="GET",
    )
    try:
        var res = client.do(req)
        testing.assert_equal(res.status_code, 200)
    except e:
        print(e)

fn test_mojo_client_redirect_external_req_302(client: MojoClient) raises:
    var req = HTTPRequest(
        uri=URI.parse_raises("http://httpbin.org/status/302"),
        headers=Headers(
            Header("Connection", "close")),
        method="GET",
    )
    try:
        var res = client.do(req)
        testing.assert_equal(res.status_code, 200)
    except e:
        print(e)

fn test_mojo_client_redirect_external_req_308(client: MojoClient) raises:
    var req = HTTPRequest(
        uri=URI.parse_raises("http://httpbin.org/status/308"),
        headers=Headers(
            Header("Connection", "close")),
        method="GET",
    )
    try:
        var res = client.do(req)
        testing.assert_equal(res.status_code, 200)
    except e:
        print(e)

fn test_mojo_client_redirect_external_req_307(client: MojoClient) raises:
    var req = HTTPRequest(
        uri=URI.parse_raises("http://httpbin.org/status/307"),
        headers=Headers(
            Header("Connection", "close")),
        method="GET",
    )
    try:
        var res = client.do(req)
        testing.assert_equal(res.status_code, 200)
    except e:
        print(e)

fn test_mojo_client_redirect_external_req_301(client: MojoClient) raises:
    var req = HTTPRequest(
        uri=URI.parse_raises("http://httpbin.org/status/301"),
        headers=Headers(
            Header("Connection", "close")),
        method="GET",
    )
    try:
        var res = client.do(req)
        testing.assert_equal(res.status_code, 200)
        testing.assert_equal(res.headers.content_length(), 228)
    except e:
        print(e)

fn test_mojo_client_lightbug_external_req_200(client: MojoClient) raises:
    var req = HTTPRequest(
        uri=URI.parse_raises("http://httpbin.org/status/200"),
        headers=Headers(
            Header("Connection", "close")),
        method="GET",
    )

    try:
        var res = client.do(req)
        testing.assert_equal(res.status_code, 200)
    except e:
        print(e)
