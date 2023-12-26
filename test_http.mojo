import testing
from mojoweb.client import Client
from mojoweb.uri import URI
from mojoweb.http import Request, Response


fn test_request_simple_url[T: Client](inout client: T) raises -> None:
    """
    Test making a simple GET request without parameters.
    Validate that we get a 200 OK response.
    """
    let uri = URI("http", "localhost", "/123")
    let response = client.get(Request(uri))
    testing.assert_equal(response.header.status_code(), 200)


"""
GET request with query parameters.
Validate that we get a 200 OK response and that server can parse the query parameters.
"""

"""
GET request with multiple headers.
Validate that we get a 200 OK response and that server can parse the headers.
"""

"""
POST request with PLAIN TEXT body.
Validate that request is properly received and the server can parse the body.
"""

"""
POST request with JSON body.
Validate that the request is properly received and the server can parse the JSON.
"""

"""
POST request with a FORM body.
Validate that the request is properly received and the server can parse the form. 
Include URL encoded strings in test cases.
"""

"""
POST request with a FILE body and get a response.
Validate that the request is properly received and the server can parse the body.
"""

"""
POST request with a stream body.
Validate that the request is properly received and the server can parse the body. 
Try stream only, stream then body, and body then stream.
"""

"""
PUT, PATCH requests.
Validate that the PUT and PATCH requests is properly received and the server can parse the body.
"""

"""
OPTIONS request.
Validate that the OPTIONS request returns appropriate headers such as Allow.
"""

"""
DELETE request.
Validate that DELETE requests are processed correctly and appropriate responses are returned.
"""

"""
HEAD request to a URL and get a response
Validate that HEAD requests return correct headers without a body.
"""
