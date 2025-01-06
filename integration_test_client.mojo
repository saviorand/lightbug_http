from collections import Dict
from lightbug_http import *
from lightbug_http.client import Client
from lightbug_http.utils import logger
from testing import *

fn u(s: String) raises -> URI:
    return URI.parse_raises("http://127.0.0.1:8080/" + s)

struct IntegrationTest:
    var client: Client
    var results: Dict[String, String]

    fn __init__(out self):
        self.client = Client()
        self.results = Dict[String, String]()
    
    fn mark_successful(mut self, name: String):
        self.results[name] = "✅"
    
    fn mark_failed(mut self, name: String):
        self.results[name] = "❌"

    fn test_redirect(mut self):
        alias name = "test_redirect"
        logger.info("Testing redirect...")
        var h = Headers(Header(HeaderKey.CONNECTION, 'keep-alive'))
        try:
            var res = self.client.do(HTTPRequest(u("redirect"), headers=h))
            assert_equal(res.status_code, StatusCode.OK)
            assert_equal(len(to_string(res.body_raw)), len("yay you made it"))
            assert_equal(to_string(res.body_raw), "yay you made it")
            assert_equal(res.headers[HeaderKey.CONNECTION], "keep-alive")
            self.mark_successful(name)
        except e:
            logger.error("IntegrationTest.test_redirect has run into an error.")
            logger.error(e)
            self.mark_failed(name)
            return

    fn test_close_connection(mut self):
        alias name = "test_close_connection"
        logger.info("Testing close connection...")
        var h = Headers(Header(HeaderKey.CONNECTION, 'close'))
        try:
            var res = self.client.do(HTTPRequest(u("close-connection"), headers=h))
            assert_equal(res.status_code, StatusCode.OK)
            assert_equal(to_string(res.body_raw), "connection closed")
            assert_equal(res.headers[HeaderKey.CONNECTION], "close")
            self.mark_successful(name)
        except e:
            logger.error("IntegrationTest.test_close_connection has run into an error.")
            logger.error(e)
            self.mark_failed(name)
            return

    fn test_server_error(mut self):
        alias name = "test_server_error"
        logger.info("Testing internal server error...")
        try:
            var res = self.client.do(HTTPRequest(u("error")))
            assert_equal(res.status_code, StatusCode.INTERNAL_ERROR)
            assert_equal(res.status_text, "Internal Server Error")
            self.mark_successful(name)
        except e:
            logger.error("IntegrationTest.test_server_error has run into an error.")
            logger.error(e)
            self.mark_failed(name)
            return

    fn run_tests(mut self):
        logger.info("Running Client Integration Tests...")
        self.test_redirect()
        self.test_close_connection()
        self.test_server_error()

        for test in self.results.items():
            print(test[].key + ":", test[].value)

fn main():
    var test = IntegrationTest()
    test.run_tests()
