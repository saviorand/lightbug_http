from lightbug_http.http import HTTPRequest
from lightbug_http.uri import URI
from lightbug_http.sys.client import MojoClient

fn test_request_simple_url(inout client: MojoClient) raises -> None:
    """
    Test making a simple GET request without parameters.
    Validate that we get a 200 OK response.
    """
    var uri = URI("http://httpbin.org/")
    var request = HTTPRequest(uri)
    var response = client.do(request)

    # print status code
    print("Response:", response.header.status_code())

    # print various parsed headers
    print("Header", response.header.content_length())

    # print body
    # print(String(response.get_body()))


fn main() raises -> None:
    var client = MojoClient()
    print("Testing URL request")
    test_request_simple_url(client)
    print("Done")