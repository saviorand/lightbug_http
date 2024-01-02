import testing
from lightbug_http.python.server import PythonServer
from lightbug_http.python.client import PythonClient
from lightbug_http.http import HTTPRequest
from lightbug_http.uri import URI
from lightbug_http.python.net import PythonNet, PythonConnection
from lightbug_http.tests.utils import FakeResponder


fn test_client() raises:
    var server = PythonServer()
    var __net = PythonNet()
    let handler = FakeResponder()
    let client = PythonClient()
    let listener = __net.listen("tcp4", "0.0.0.0:8080")
    server.serve(listener, handler)
    let res = client.do(HTTPRequest(URI("0.0.0.0:8080")))
    print(res.body_raw)


fn main():
    try:
        test_client()
    except:
        print("test failed")
