import testing
from mojoweb.client import Client
from mojoweb.uri import URI
from mojoweb.http import Request, Response


fn test_request_simple_url[T: Client](inout client: T) raises -> None:
    let uri = URI("http", "localhost", "/123")
    let response = client.get(Request(uri))
    testing.assert_equal(response.header.status_code(), 200)
    print("Great success! Got status code: " + response.header.status_code().__str__())
