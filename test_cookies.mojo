import testing

"""
Handle cookies.
Validate that the cookies are parsed correctly.
"""

"""
We should be able to parse invalid or non-spec conformant cookies, such as the ones set by Okta (see below).

From Starlette (https://github.com/encode/starlette/blob/master/tests/test_requests.py)
tough_cookie = (
    "provider-oauth-nonce=validAsciiblabla; "
    'okta-oauth-redirect-params={"responseType":"code","state":"somestate",'
    '"nonce":"somenonce","scopes":["openid","profile","email","phone"],'
    '"urls":{"issuer":"https://subdomain.okta.com/oauth2/authServer",'
    '"authorizeUrl":"https://subdomain.okta.com/oauth2/authServer/v1/authorize",'
    '"userinfoUrl":"https://subdomain.okta.com/oauth2/authServer/v1/userinfo"}}; '
    "importantCookie=importantValue; sessionCookie=importantSessionValue"
)
expected_keys = {
    "importantCookie",
    "okta-oauth-redirect-params",
    "provider-oauth-nonce",
    "sessionCookie",
}
"""
