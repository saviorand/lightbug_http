import testing
from lightbug_http.client import Client
from lightbug_http.uri import URI
from lightbug_http.http import HTTPRequest, HTTPResponse


fn test_request_simple_url[T: Client](inout client: T) raises -> None:
    """
    Test making a simple GET request without parameters.
    Validate that we get a 200 OK response.
    """
    let uri = URI("http", "localhost", "/123")
    let response = client.do(HTTPRequest(uri))
    testing.assert_equal(response.header.status_code(), 200)


fn test_request_simple_url_with_parameters[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a simple GET request with query parameters.
    Validate that we get a 200 OK response and that server can parse the query parameters.
    """
    # This test is a WIP
    let uri = URI("http", "localhost", "/123")
    # uri.add_query_parameter("foo", "bar")
    # uri.add_query_parameter("baz", "qux")
    let response = client.do(HTTPRequest(uri))
    testing.assert_equal(response.header.status_code(), 200)


fn test_request_simple_url_with_headers[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a simple GET request with headers.
    Validate that we get a 200 OK response and that server can parse the headers.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.header.add("foo", "bar")
    let response = client.do(request)
    testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_plain_text[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a POST request with PLAIN TEXT body.
    Validate that request is properly received and the server can parse the body.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "Hello World"
    # let response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_json[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a POST request with JSON body.
    Validate that the request is properly received and the server can parse the JSON.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "{\"foo\": \"bar\"}"
    # let response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_form[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a POST request with a FORM body.
    Validate that the request is properly received and the server can parse the form.
    Include URL encoded strings in test cases.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # let response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_file[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a POST request with a FILE body.
    Validate that the request is properly received and the server can parse the body.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # let response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_stream[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a POST request with a stream body.
    Validate that the request is properly received and the server can parse the body.
    Try stream only, stream then body, and body then stream.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # let response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_put[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a PUT request.
    Validate that the PUT request is properly received and the server can parse the body.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # let response = client.put(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_patch[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a PATCH request.
    Validate that the PATCH request is properly received and the server can parse the body.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # let response = client.patch(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_options[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making an OPTIONS request.
    Validate that the OPTIONS request is properly received and the server can parse the body.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # let response = client.options(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_delete[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a DELETE request.
    Validate that the DELETE request is properly received and the server can parse the body.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # let response = client.delete(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_head[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a HEAD request.
    Validate that the HEAD request is properly received and the server can parse the body.
    """
    let uri = URI("http", "localhost", "/123")
    let request = HTTPRequest(uri)
    # let response = client.head(request)
    # testing.assert_equal(response.header.status_code(), 200)
