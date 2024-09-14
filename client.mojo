from lightbug_http import *
from lightbug_http.sys.client import MojoClient

fn test_request(inout client: MojoClient) raises -> None:
    var uri = URI("http://httpbin.org/status/404")
    try:
        uri.parse()
    except e:
        print("error parsing uri: " + e.__str__())


    var request = HTTPRequest(uri)
    var response = client.do(request)

    # print status code
    print("Response:", response.header.status_code())

    # print parsed headers (only some are parsed for now)
    print("Content-Type:", to_string(response.header.content_type()))
    print("Content-Length", response.header.content_length())
    print("Server:", to_string(response.header.server()))

    print("Is connection set to connection-close? ", response.header.connection_close())

    # print body
    print(to_string(response.get_body_bytes()))


fn main() raises -> None:
    var client = MojoClient()
    test_request(client)