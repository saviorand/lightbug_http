import test_requests
from mojoweb.client import Client
from mojoweb.header import ResponseHeader
from mojoweb.http import Request, Response


@value
struct TestClient(Client):
    fn __init__(inout self):
        ...

    fn get(inout self, request: Request) -> Response:
        return Response(ResponseHeader(), String("Nice")._buffer)


fn main():
    var client = TestClient()
    try:
        test_requests.test_request_simple_url(client)
    except:
        print("test_request_simple_url failed")
