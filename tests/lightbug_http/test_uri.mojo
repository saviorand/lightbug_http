from utils import StringSlice
import testing
from lightbug_http.uri import URI
from lightbug_http.strings import empty_string, to_string
from lightbug_http.io.bytes import Bytes



def test_uri_no_parse_defaults():
    var uri = URI.parse("http://example.com")[URI]
    testing.assert_equal(uri.full_uri, "http://example.com")

    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.path, "/")


def test_uri_parse_http_with_port():
    var uri = URI.parse("http://example.com:8080/index.html")[URI]
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "example.com:8080")
    testing.assert_equal(uri.path, "/index.html")
    testing.assert_equal(uri.__path_original, "/index.html")
    testing.assert_equal(uri.request_uri, "/index.html")
    testing.assert_equal(uri.is_https(), False)
    testing.assert_equal(uri.is_http(), True)
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_https_with_port():
    var uri = URI.parse("https://example.com:8080/index.html")[URI]
    testing.assert_equal(uri.scheme, "https")
    testing.assert_equal(uri.host, "example.com:8080")
    testing.assert_equal(uri.path, "/index.html")
    testing.assert_equal(uri.__path_original, "/index.html")
    testing.assert_equal(uri.request_uri, "/index.html")
    testing.assert_equal(uri.is_https(), True)
    testing.assert_equal(uri.is_http(), False)
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_http_with_path():
    var uri = URI.parse("http://example.com/index.html")[URI]
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/index.html")
    testing.assert_equal(uri.__path_original, "/index.html")
    testing.assert_equal(uri.request_uri, "/index.html")
    testing.assert_equal(uri.is_https(), False)
    testing.assert_equal(uri.is_http(), True)
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_https_with_path():
    var uri = URI.parse("https://example.com/index.html")[URI]
    testing.assert_equal(uri.scheme, "https")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/index.html")
    testing.assert_equal(uri.__path_original, "/index.html")
    testing.assert_equal(uri.request_uri, "/index.html")
    testing.assert_equal(uri.is_https(), True)
    testing.assert_equal(uri.is_http(), False)
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_http_basic():
    var uri = URI.parse("http://example.com")[URI]
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/")
    testing.assert_equal(uri.__path_original, "/")
    testing.assert_equal(uri.request_uri, "/")
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_http_basic_www():
    var uri = URI.parse("http://www.example.com")[URI]
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "www.example.com")
    testing.assert_equal(uri.path, "/")
    testing.assert_equal(uri.__path_original, "/")
    testing.assert_equal(uri.request_uri, "/")
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_http_with_query_string():
    ...


def test_uri_parse_http_with_hash():
    ...
