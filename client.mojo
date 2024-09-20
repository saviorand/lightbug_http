from lightbug_http import *
from lightbug_http.sys.client import MojoClient


fn test_request(inout client: MojoClient) raises -> None:
    var uri = URI.parse_raises("http://httpbin.org/status/404")

    var request = HTTPRequest(uri)
    var response = client.do(request^)

    # print status code
    print("Response:", response.status_code)

    # print parsed headers (only some are parsed for now)
    print("Content-Type:", response.headers["Content-Type"])
    print("Content-Length", response.headers["Content-Length"])
    print("Server:", to_string(response.headers["Server"]))

    print(
        "Is connection set to connection-close? ", response.connection_close()
    )

    # print body
    print(to_string(response.body_raw))


fn main() raises -> None:
    var client = MojoClient()
    test_request(client)
