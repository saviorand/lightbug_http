from utils import StringSlice
import testing
from lightbug_http.uri import URI
from lightbug_http.strings import empty_string, to_string
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

def test_uri_no_parse_defaults():
    var uri = URI("http://example.com")
    var full_uri = List[UInt8, True](uri.full_uri())
    full_uri.append(0) # TODO: remove this once Mojo strings are more ergonomic
    testing.assert_equal(String(full_uri), "http://example.com")

    var scheme = List[UInt8, True](uri.scheme())
    scheme.append(0)
    testing.assert_equal(String(scheme), "http")
    testing.assert_equal(uri.path(), "/")

def test_uri_parse_http_with_port():
    var uri = URI("http://example.com:8080/index.html")
    _ = uri.parse()
    testing.assert_equal(to_string(uri.scheme()), "http")
    testing.assert_equal(to_string(uri.host()), "example.com:8080")
    testing.assert_equal(uri.path(), "/index.html")
    testing.assert_equal(to_string(uri.path_original()), "/index.html")
    testing.assert_equal(to_string(uri.request_uri()), "/index.html")
    testing.assert_equal(to_string(uri.http_version()), "HTTP/1.1")
    testing.assert_equal(uri.is_http_1_0(), False)
    testing.assert_equal(uri.is_http_1_1(), True)
    testing.assert_equal(uri.is_https(), False)
    testing.assert_equal(uri.is_http(), True)
    testing.assert_equal(to_string(uri.query_string()), empty_string)

def test_uri_parse_https_with_port():
    var uri = URI("https://example.com:8080/index.html")
    _ = uri.parse()
    testing.assert_equal(to_string(uri.scheme()), "https")
    testing.assert_equal(to_string(uri.host()), "example.com:8080")
    testing.assert_equal(uri.path(), "/index.html")
    testing.assert_equal(to_string(uri.path_original()), "/index.html")
    testing.assert_equal(to_string(uri.request_uri()), "/index.html")
    testing.assert_equal(uri.is_https(), True)
    testing.assert_equal(uri.is_http(), False)
    testing.assert_equal(to_string(uri.query_string()), empty_string)

def test_uri_parse_http_with_path():
    uri = URI("http://example.com/index.html")
    _ = uri.parse()
    testing.assert_equal(to_string(uri.scheme()), "http")
    testing.assert_equal(to_string(uri.host()), "example.com")
    testing.assert_equal(uri.path(), "/index.html")
    testing.assert_equal(to_string(uri.path_original()), "/index.html")
    testing.assert_equal(to_string(uri.request_uri()), "/index.html")
    testing.assert_equal(uri.is_https(), False)
    testing.assert_equal(uri.is_http(), True)
    testing.assert_equal(to_string(uri.query_string()), empty_string)

def test_uri_parse_https_with_path():
    uri = URI("https://example.com/index.html")
    _ = uri.parse()
    testing.assert_equal(to_string(uri.scheme()), "https")
    testing.assert_equal(to_string(uri.host()), "example.com")
    testing.assert_equal(uri.path(), "/index.html")
    testing.assert_equal(to_string(uri.path_original()), "/index.html")
    testing.assert_equal(to_string(uri.request_uri()), "/index.html")
    testing.assert_equal(uri.is_https(), True)
    testing.assert_equal(uri.is_http(), False)
    testing.assert_equal(to_string(uri.query_string()), empty_string)

def test_uri_parse_http_basic():
    uri = URI("http://example.com")
    _ = uri.parse()
    testing.assert_equal(to_string(uri.scheme()), "http")
    testing.assert_equal(to_string(uri.host()), "example.com")
    testing.assert_equal(uri.path(), "/")
    testing.assert_equal(to_string(uri.path_original()), "/")
    testing.assert_equal(to_string(uri.http_version()), "HTTP/1.1")
    testing.assert_equal(to_string(uri.request_uri()), "/")
    testing.assert_equal(to_string(uri.query_string()), empty_string)

def test_uri_parse_http_basic_www():
    uri = URI("http://www.example.com")
    _ = uri.parse()
    testing.assert_equal(to_string(uri.scheme()), "http")
    testing.assert_equal(to_string(uri.host()), "www.example.com")
    testing.assert_equal(uri.path(), "/")
    testing.assert_equal(to_string(uri.path_original()), "/")
    testing.assert_equal(to_string(uri.request_uri()), "/")
    testing.assert_equal(to_string(uri.http_version()), "HTTP/1.1")
    testing.assert_equal(to_string(uri.query_string()), empty_string)

def test_uri_parse_http_with_query_string():
    ...

def test_uri_parse_http_with_hash():
    ...
