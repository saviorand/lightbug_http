import testing
from mojoweb.client import Client
from mojoweb.uri import URI
from mojoweb.http import Request, Response


fn test_request_simple_url[T: Client](inout client: T) raises -> None:
    """we should be able to make a simple GET request to a URL and get a response"""
    let uri = URI("http", "localhost", "/123")
    let response = client.get(Request(uri))
    testing.assert_equal(response.header.status_code(), 200)


"""we should be able to make a POST request to a URL and get a response"""
"""with JSON body"""
"""with form body"""
"""with files"""
"""with plain text body"""

"""we should be able to make a PUT request to a URL and get a response"""

"""we should be able to make a OPTIONS request to a URL and get a response"""

"""we should be able to make a PATCH request to a URL and get a response"""

"""we should be able to make a DELETE request to a URL and get a response"""

"""we should be able to make a HEAD request to a URL and get a response"""
