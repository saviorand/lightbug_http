from external.gojo.tests.wrapper import MojoTest
from lightbug_http.uri import URI
from lightbug_http.strings import empty_string
from lightbug_http.io.bytes import Bytes

def test_uri():
    test_uri_no_parse_defaults()
    test_uri_parse_http_with_port()
    test_uri_parse_https_with_port()
    test_uri_parse_http_with_path()
    test_uri_parse_https_with_path()
    test_uri_parse_http_basic()
    test_uri_parse_http_basic_www()
    test_uri_parse_http_with_query_string()
    test_uri_parse_http_with_hash()
    test_uri_parse_http_with_query_string_and_hash()

def test_uri_no_parse_defaults():
    var test = MojoTest("test_uri_no_parse_defaults")
    var uri = URI("http://example.com")
    test.assert_equal(String(uri.full_uri()), "http://example.com")
    test.assert_equal(String(uri.scheme()), "http")
    test.assert_equal(String(uri.path()), "/")

def test_uri_parse_http_with_port():
    var test = MojoTest("test_uri_parse_http_with_port")
    var uri = URI("http://example.com:8080/index.html")
    _ = uri.parse()
    test.assert_equal(String(uri.scheme()), "http")
    test.assert_equal(String(uri.host()), "example.com:8080")
    test.assert_equal(String(uri.path()), "/index.html")
    test.assert_equal(String(uri.path_original()), "/index.html")
    test.assert_equal(String(uri.request_uri()), "/index.html")
    test.assert_equal(String(uri.http_version()), "HTTP/1.1")
    test.assert_equal(uri.is_http_1_0(), False)
    test.assert_equal(uri.is_http_1_1(), True)
    test.assert_equal(uri.is_https(), False)
    test.assert_equal(uri.is_http(), True)
    test.assert_equal(String(uri.query_string()), String(empty_string.as_bytes_slice()))

def test_uri_parse_https_with_port():
    var test = MojoTest("test_uri_parse_https_with_port")
    var uri = URI("https://example.com:8080/index.html")
    _ = uri.parse()
    test.assert_equal(String(uri.scheme()), "https")
    test.assert_equal(String(uri.host()), "example.com:8080")
    test.assert_equal(String(uri.path()), "/index.html")
    test.assert_equal(String(uri.path_original()), "/index.html")
    test.assert_equal(String(uri.request_uri()), "/index.html")
    test.assert_equal(uri.is_https(), True)
    test.assert_equal(uri.is_http(), False)
    test.assert_equal(String(uri.query_string()), String(empty_string.as_bytes_slice()))

def test_uri_parse_http_with_path():
    var test = MojoTest("test_uri_parse_http_with_path")
    uri = URI("http://example.com/index.html")
    _ = uri.parse()
    test.assert_equal(String(uri.scheme()), "http")
    test.assert_equal(String(uri.host()), "example.com")
    test.assert_equal(String(uri.path()), "/index.html")
    test.assert_equal(String(uri.path_original()), "/index.html")
    test.assert_equal(String(uri.request_uri()), "/index.html")
    test.assert_equal(uri.is_https(), False)
    test.assert_equal(uri.is_http(), True)
    test.assert_equal(String(uri.query_string()), String(empty_string.as_bytes_slice()))

def test_uri_parse_https_with_path():
    var test = MojoTest("test_uri_parse_https_with_path")
    uri = URI("https://example.com/index.html")
    _ = uri.parse()
    test.assert_equal(String(uri.scheme()), "https")
    test.assert_equal(String(uri.host()), "example.com")
    test.assert_equal(String(uri.path()), "/index.html")
    test.assert_equal(String(uri.path_original()), "/index.html")
    test.assert_equal(String(uri.request_uri()), "/index.html")
    test.assert_equal(uri.is_https(), True)
    test.assert_equal(uri.is_http(), False)
    test.assert_equal(String(uri.query_string()), String(empty_string.as_bytes_slice()))

def test_uri_parse_http_basic():
    var test = MojoTest("test_uri_parse_http_basic")
    uri = URI("http://example.com")
    _ = uri.parse()
    test.assert_equal(String(uri.scheme()), "http")
    test.assert_equal(String(uri.host()), "example.com")
    test.assert_equal(String(uri.path()), "/")
    test.assert_equal(String(uri.path_original()), "/")
    test.assert_equal(String(uri.http_version()), "HTTP/1.1")
    test.assert_equal(String(uri.request_uri()), "/")
    test.assert_equal(String(uri.query_string()), String(empty_string.as_bytes_slice()))

def test_uri_parse_http_basic_www():
    var test = MojoTest("test_uri_parse_http_basic_www")
    uri = URI("http://www.example.com")
    _ = uri.parse()
    test.assert_equal(String(uri.scheme()), "http")
    test.assert_equal(String(uri.host()), "www.example.com")
    test.assert_equal(String(uri.path()), "/")
    test.assert_equal(String(uri.path_original()), "/")
    test.assert_equal(String(uri.request_uri()), "/")
    test.assert_equal(String(uri.http_version()), "HTTP/1.1")
    test.assert_equal(String(uri.query_string()), String(empty_string.as_bytes_slice()))

def test_uri_parse_http_with_query_string():
    ...

def test_uri_parse_http_with_hash():
    ...

def test_uri_parse_http_with_query_string_and_hash():
    ...


