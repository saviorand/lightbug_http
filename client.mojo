from lightbug_http import *
from lightbug_http.client import Client


fn test_request(inout client: Client) raises -> None:
    var uri = URI.parse_raises("http://google.com")
    var headers = Headers(Header("Host", "google.com"), Header("User-Agent", "curl/8.1.2"), Header("Accept", "*/*"))

    var request = HTTPRequest(uri, headers)
    var response = client.do(request^)

    # print status code
    print("Response:", response.status_code)

    print(response.headers)

    print(
        "Is connection set to connection-close? ", response.connection_close()
    )

    # print body
    print(to_string(response.body_raw))


fn main() -> None:
    try:
        var client = Client()
        test_request(client)
    except e:
        print(e)
