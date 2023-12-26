import testing
from mojoweb.client import Client
from mojoweb.uri import URI
from mojoweb.http import Request, Response


fn test_request_simple_url[T: Client](inout client: T) raises -> None:
    """We should be able to make a simple GET request without parameters and get a response.
    Validate that the response is a 200 OK.
    """
    let uri = URI("http", "localhost", "/123")
    let response = client.get(Request(uri))
    testing.assert_equal(response.header.status_code(), 200)


"""
We should be able to make a simple GET request with query parameters and get a response.
Validate that the response is a 200 OK and the server can parse the query parameters.
"""

"""
We should be able to make a simple GET request with multiple headers and get a response.
Validate that the response is a 200 OK and the server can parse the headers.
"""

"""
We should be able to make a POST request with PLAIN TEXT body and get a response.
Validate that a request with JSON body is properly received and the server can parse the JSON.
"""

"""
We should be able to make a POST request with a JSON body and get a response.
Validate that a request with JSON body is properly received and the server can parse the JSON.
"""

"""
We should be able to make a POST request with a FORM body and get a response.
Validate that a request with a form body is properly received and the server can parse the form. Include URL encoded strings in test cases.
"""

"""
We should be able to make a POST request with a FILE body and get a response.
Validate that a request with multipart/form-data for a file upload is properly received and the server can parse the data.
"""

"""
We should be able to make a POST request with a body stream and get a response.
Validate that a request with a body stream is properly received and the server can parse the data. Try stream only, stream then body, and body then stream.
"""

"""
We should be able to make a PUT request to a URL and get a response.
Validate that PUT requests are properly processed, including handling of the request body.
"""

"""
We should be able to make a OPTIONS request to a URL and get a response.
Validate that OPTIONS requests return appropriate headers such as Allow.
"""

"""
We should be able to make a PATCH request to a URL and get a response
Validate that PATCH requests are correctly handled, particularly the partial update logic.
"""

"""
We should be able to make a DELETE request to a URL and get a response.
Verify that DELETE requests are processed correctly and appropriate responses are returned.
"""

"""
We should be able to make a HEAD request to a URL and get a response
Validate that HEAD requests return correct headers without a body.
"""
