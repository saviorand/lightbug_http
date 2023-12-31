import testing
from lightbug_http.client import Client
from lightbug_http.uri import URI
from lightbug_http.http import HTTPRequest, HTTPResponse


fn test_request_with_cookies[T: Client](inout client: T) raises -> None:
    """
    WIP: Test making a simple GET request with cookies.
    Validate that the cookies are parsed correctly.
    """
    let uri = URI("http", "localhost", "/123")
    # let cookies = [Cookie("foo", "bar")]
    # let response = client.get(HTTPRequest(uri, cookies=cookies))
    # testing.assert_equal(response.header.status_code(), 200)


fn test_request_with_invalid_cookies[T: Client](inout client: T) raises -> None:
    """
    WIP:  We should be able to parse invalid or non-spec conformant cookies, such as the ones set by Okta (see below).
    From Starlette (https://github.com/encode/starlette/blob/master/tests/test_requests.py).
    """
    let uri = URI("http", "localhost", "/123")
    # let cookies = [
    #     Cookie("importantCookie", "importantValue"),
    #     Cookie("okta-oauth-redirect-params", '{"responseType":"code","state":"somestate","nonce":"somenonce","scopes":["openid","profile","email","phone"],"urls":{"issuer":"https://subdomain.okta.com/oauth2/authServer","authorizeUrl":"https://subdomain.okta.com/oauth2/authServer/v1/authorize","userinfoUrl":"https://subdomain.okta.com/oauth2/authServer/v1/userinfo"}}'),
    #     Cookie("provider-oauth-nonce", "validAsciiblabla"),
    #     Cookie("sessionCookie", "importantSessionValue"),
    # ]
    # let response = client.get(HTTPRequest(uri, cookies=cookies))
    # testing.assert_equal(response.header.status_code(), 200)
