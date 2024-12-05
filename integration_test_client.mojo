from lightbug_http import *
from lightbug_http.client import Client
from testing import *

fn u(s: String) raises -> URI:
    return URI.parse_raises("http://127.0.0.1:8080/" + s)

struct IntegrationTest:
    var client: Client

    fn __init__(inout self):
        self.client = Client()

    fn test_redirect(inout self) raises:
        print("Testing redirect...")
        var h = Headers(Header(HeaderKey.CONNECTION, 'keep-alive'))
        var res = self.client.do(HTTPRequest(u("redirect"), headers=h))
        assert_equal(res.status_code, StatusCode.OK)
        assert_equal(to_string(res.body_raw), "yay you made it")
        assert_equal(res.headers[HeaderKey.CONNECTION], "keep-alive")

    fn test_close_connection(inout self) raises:
        print("Testing close connection...")
        var h = Headers(Header(HeaderKey.CONNECTION, 'close'))
        var res = self.client.do(HTTPRequest(u("close-connection"), headers=h))
        assert_equal(res.status_code, StatusCode.OK)
        assert_equal(to_string(res.body_raw), "connection closed")
        assert_equal(res.headers[HeaderKey.CONNECTION], "close")

    fn test_server_error(inout self) raises:
        print("Testing internal server error...")
        var res = self.client.do(HTTPRequest(u("error")))
        assert_equal(res.status_code, StatusCode.INTERNAL_ERROR)
        assert_equal(res.status_text, "Internal Server Error")


    fn run_tests(inout self) raises:
        self.test_redirect()
        self.test_close_connection()
        self.test_server_error()

fn main() raises:
    var test = IntegrationTest()
    test.run_tests()
