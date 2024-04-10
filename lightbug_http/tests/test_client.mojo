import testing
from lightbug_http.python.client import PythonClient
from lightbug_http.sys.client import MojoClient
from lightbug_http.http import HTTPRequest
from lightbug_http.uri import URI
from lightbug_http.header import RequestHeader
from external.morrow import Morrow
from lightbug_http.tests.utils import (
    default_server_conn_string,
    getRequest,
)

fn test_mojo_client_lightbug(client: MojoClient) raises:
    var res = client.do(
        HTTPRequest(
            URI(default_server_conn_string),
            String("Hello world!")._buffer,
            RequestHeader(getRequest),
        )
    )
    testing.assert_equal(
        String(res.body_raw[0:112]),
        String(
            "HTTP/1.1 200 OK\r\nServer: lightbug_http\r\nContent-Type:"
            " text/plain\r\nContent-Length: 12\r\nConnection: close\r\nDate: "
        ),
    )

fn test_python_client_lightbug(client: PythonClient) raises:
    var res = client.do(
        HTTPRequest(
            URI(default_server_conn_string),
            String("Hello world!")._buffer,
            RequestHeader(getRequest),
        )
    )
    testing.assert_equal(
        String(res.body_raw[0:112]),
        String(
            "HTTP/1.1 200 OK\r\nServer: lightbug_http\r\nContent-Type:"
            " text/plain\r\nContent-Length: 12\r\nConnection: close\r\nDate: "
        ),
    )


fn test_request_simple_url(inout client: PythonClient) raises -> None:
    """
    Test making a simple GET request without parameters.
    Validate that we get a 200 OK response.
    """
    var uri = URI("http", "localhost", "/123")
    var response = client.do(HTTPRequest(uri))
    testing.assert_equal(response.header.status_code(), 200)


fn test_request_simple_url_with_parameters(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a simple GET request with query parameters.
    Validate that we get a 200 OK response and that server can parse the query parameters.
    """
    # This test is a WIP
    var uri = URI("http", "localhost", "/123")
    # uri.add_query_parameter("foo", "bar")
    # uri.add_query_parameter("baz", "qux")
    var response = client.do(HTTPRequest(uri))
    testing.assert_equal(response.header.status_code(), 200)


fn test_request_simple_url_with_headers(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a simple GET request with headers.
    Validate that we get a 200 OK response and that server can parse the headers.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.header.add("foo", "bar")
    var response = client.do(request)
    testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_plain_text(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a POST request with PLAIN TEXT body.
    Validate that request is properly received and the server can parse the body.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "Hello World"
    # var response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_json(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a POST request with JSON body.
    Validate that the request is properly received and the server can parse the JSON.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "{\"foo\": \"bar\"}"
    # var response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_form(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a POST request with a FORM body.
    Validate that the request is properly received and the server can parse the form.
    Include URL encoded strings in test cases.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # var response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_file(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a POST request with a FILE body.
    Validate that the request is properly received and the server can parse the body.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # var response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_post_stream(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a POST request with a stream body.
    Validate that the request is properly received and the server can parse the body.
    Try stream only, stream then body, and body then stream.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # var response = client.post(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_put(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a PUT request.
    Validate that the PUT request is properly received and the server can parse the body.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # var response = client.put(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_patch(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a PATCH request.
    Validate that the PATCH request is properly received and the server can parse the body.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # var response = client.patch(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_options(inout client: PythonClient) raises -> None:
    """
    WIP: Test making an OPTIONS request.
    Validate that the OPTIONS request is properly received and the server can parse the body.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # var response = client.options(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_delete(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a DELETE request.
    Validate that the DELETE request is properly received and the server can parse the body.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # request.body = "foo=bar&baz=qux"
    # var response = client.delete(request)
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_head(inout client: PythonClient) raises -> None:
    """
    WIP: Test making a HEAD request.
    Validate that the HEAD request is properly received and the server can parse the body.
    """
    var uri = URI("http", "localhost", "/123")
    var request = HTTPRequest(uri)
    # var response = client.head(request)
    # testing.assert_equal(response.header.status_code(), 200)
