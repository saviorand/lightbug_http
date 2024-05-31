from testing import assert_equal
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
    var uri = URI("http://example.com")
    assert_equal(uri.full_uri(), "http://example.com")
    assert_equal(uri.scheme(), "http")
    assert_equal(uri.host(), "127.0.0.1")
    assert_equal(uri.path(), "/")

def test_uri_parse_http_with_port():
    var uri = URI("http://example.com:8080/index.html")
    _ = uri.parse()
    assert_equal(uri.scheme(), "http")
    assert_equal(uri.host(), "example.com:8080")
    assert_equal(uri.path(), "/index.html")
    assert_equal(uri.path_original(), "/index.html")
    assert_equal(uri.request_uri(), "/index.html")
    assert_equal(uri.http_version(), "HTTP/1.1")
    assert_equal(uri.is_http_1_0(), False)
    assert_equal(uri.is_http_1_1(), True)
    assert_equal(uri.is_https(), False)
    assert_equal(uri.is_http(), True)
    assert_equal(uri.query_string(), empty_string)

def test_uri_parse_https_with_port():
    var uri = URI("https://example.com:8080/index.html")
    _ = uri.parse()
    assert_equal(uri.scheme(), "https")
    assert_equal(uri.host(), "example.com:8080")
    assert_equal(uri.path(), "/index.html")
    assert_equal(uri.path_original(), "/index.html")
    assert_equal(uri.request_uri(), "/index.html")
    assert_equal(uri.is_https(), True)
    assert_equal(uri.is_http(), False)
    assert_equal(uri.query_string(), empty_string)

def test_uri_parse_http_with_path():
    uri = URI("http://example.com/index.html")
    _ = uri.parse()
    assert_equal(uri.scheme(), "http")
    assert_equal(uri.host(), "example.com")
    assert_equal(uri.path(), "/index.html")
    assert_equal(uri.path_original(), "/index.html")
    assert_equal(uri.request_uri(), "/index.html")
    assert_equal(uri.is_https(), False)
    assert_equal(uri.is_http(), True)
    assert_equal(uri.query_string(), empty_string)

def test_uri_parse_https_with_path():
    uri = URI("https://example.com/index.html")
    _ = uri.parse()
    assert_equal(uri.scheme(), "https")
    assert_equal(uri.host(), "example.com")
    assert_equal(uri.path(), "/index.html")
    assert_equal(uri.path_original(), "/index.html")
    assert_equal(uri.request_uri(), "/index.html")
    assert_equal(uri.is_https(), True)
    assert_equal(uri.is_http(), False)
    assert_equal(uri.query_string(), empty_string)

def test_uri_parse_http_basic():
    uri = URI("http://example.com")
    _ = uri.parse()
    assert_equal(uri.scheme(), "http")
    assert_equal(uri.host(), "example.com")
    assert_equal(uri.path(), "/")
    assert_equal(uri.path_original(), "/")
    assert_equal(uri.http_version(), "HTTP/1.1")
    assert_equal(uri.request_uri(), "/")
    assert_equal(uri.query_string(), empty_string)

def test_uri_parse_http_basic_www():
    uri = URI("http://www.example.com")
    _ = uri.parse()
    assert_equal(uri.scheme(), "http")
    assert_equal(uri.host(), "www.example.com")
    assert_equal(uri.path(), "/")
    assert_equal(uri.path_original(), "/")
    assert_equal(uri.request_uri(), "/")
    assert_equal(uri.http_version(), "HTTP/1.1")
    assert_equal(uri.query_string(), empty_string)

def test_uri_parse_http_with_query_string():
    ...

def test_uri_parse_http_with_hash():
    ...

def test_uri_parse_http_with_query_string_and_hash():
    ...


