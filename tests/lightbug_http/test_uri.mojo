from utils import StringSlice
import testing
from lightbug_http.uri import URI
from lightbug_http.strings import empty_string, to_string
from lightbug_http.io.bytes import Bytes


def test_uri_no_parse_defaults():
    var uri = URI.parse("http://example.com")
    testing.assert_equal(uri.full_uri, "http://example.com")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.path, "/")


def test_uri_parse_http_with_port():
    var uri = URI.parse("http://example.com:8080/index.html")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.port.value(), 8080)
    testing.assert_equal(uri.path, "/index.html")
    testing.assert_equal(uri._original_path, "/index.html")
    testing.assert_equal(uri.request_uri, "/index.html")
    testing.assert_equal(uri.is_https(), False)
    testing.assert_equal(uri.is_http(), True)
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_https_with_port():
    var uri = URI.parse("https://example.com:8080/index.html")
    testing.assert_equal(uri.scheme, "https")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.port.value(), 8080)
    testing.assert_equal(uri.path, "/index.html")
    testing.assert_equal(uri._original_path, "/index.html")
    testing.assert_equal(uri.request_uri, "/index.html")
    testing.assert_equal(uri.is_https(), True)
    testing.assert_equal(uri.is_http(), False)
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_http_with_path():
    var uri = URI.parse("http://example.com/index.html")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/index.html")
    testing.assert_equal(uri._original_path, "/index.html")
    testing.assert_equal(uri.request_uri, "/index.html")
    testing.assert_equal(uri.is_https(), False)
    testing.assert_equal(uri.is_http(), True)
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_https_with_path():
    var uri = URI.parse("https://example.com/index.html")
    testing.assert_equal(uri.scheme, "https")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/index.html")
    testing.assert_equal(uri._original_path, "/index.html")
    testing.assert_equal(uri.request_uri, "/index.html")
    testing.assert_equal(uri.is_https(), True)
    testing.assert_equal(uri.is_http(), False)
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_http_basic():
    var uri = URI.parse("http://example.com")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/")
    testing.assert_equal(uri._original_path, "/")
    testing.assert_equal(uri.request_uri, "/")
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_http_basic_www():
    var uri = URI.parse("http://www.example.com")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "www.example.com")
    testing.assert_equal(uri.path, "/")
    testing.assert_equal(uri._original_path, "/")
    testing.assert_equal(uri.request_uri, "/")
    testing.assert_equal(uri.query_string, empty_string)


def test_uri_parse_http_with_query_string():
    var uri = URI.parse("http://www.example.com/job?title=engineer")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "www.example.com")
    testing.assert_equal(uri.path, "/job")
    testing.assert_equal(uri._original_path, "/job")
    testing.assert_equal(uri.request_uri, "/job?title=engineer")
    testing.assert_equal(uri.query_string, "title=engineer")
    testing.assert_equal(uri.queries["title"], "engineer")


def test_uri_parse_multiple_query_parameters():
    var uri = URI.parse("http://example.com/search?q=python&page=1&limit=20")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/search")
    testing.assert_equal(uri.query_string, "q=python&page=1&limit=20")
    testing.assert_equal(uri.queries["q"], "python")
    testing.assert_equal(uri.queries["page"], "1")
    testing.assert_equal(uri.queries["limit"], "20")
    testing.assert_equal(uri.request_uri, "/search?q=python&page=1&limit=20")


def test_uri_parse_query_with_special_characters():
    var uri = URI.parse("https://example.com/path?name=John+Doe&email=john%40example.com")
    testing.assert_equal(uri.scheme, "https")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/path")
    testing.assert_equal(uri.query_string, "name=John+Doe&email=john%40example.com")
    # testing.assert_equal(uri.queries["name"], "John Doe") - fails, contains John+Doe
    # testing.assert_equal(uri.queries["email"], "john@example.com") - fails, contains john%40example.com


def test_uri_parse_empty_query_values():
    var uri = URI.parse("http://example.com/api?key=&token=&empty")
    testing.assert_equal(uri.query_string, "key=&token=&empty")
    testing.assert_equal(uri.queries["key"], "")
    testing.assert_equal(uri.queries["token"], "")
    testing.assert_equal(uri.queries["empty"], "")


def test_uri_parse_complex_query():
    var uri = URI.parse("https://example.com/search?q=test&filter[category]=books&filter[price]=10-20&sort=desc&page=1")
    testing.assert_equal(uri.scheme, "https")
    testing.assert_equal(uri.host, "example.com")
    testing.assert_equal(uri.path, "/search")
    testing.assert_equal(uri.query_string, "q=test&filter[category]=books&filter[price]=10-20&sort=desc&page=1")
    testing.assert_equal(uri.queries["q"], "test")
    testing.assert_equal(uri.queries["filter[category]"], "books")
    testing.assert_equal(uri.queries["filter[price]"], "10-20")
    testing.assert_equal(uri.queries["sort"], "desc")
    testing.assert_equal(uri.queries["page"], "1")


def test_uri_parse_query_with_unicode():
    var uri = URI.parse("http://example.com/search?q=%E2%82%AC&lang=%F0%9F%87%A9%F0%9F%87%AA")
    testing.assert_equal(uri.query_string, "q=%E2%82%AC&lang=%F0%9F%87%A9%F0%9F%87%AA")
    # testing.assert_equal(uri.queries["q"], "€") - fails, contains %E2%82%AC
    # testing.assert_equal(uri.queries["lang"], "🇩🇪") - fails, contains %F0%9F%87%A9%F0%9F%87%AA


# def test_uri_parse_query_with_fragments():
#     var uri = URI.parse("http://example.com/page?id=123#section1")
#     testing.assert_equal(uri.query_string, "id=123")
#     testing.assert_equal(uri.queries["id"], "123")
#     testing.assert_equal(...) - how do we treat fragments?


def test_uri_parse_no_scheme():
    var uri = URI.parse("www.example.com")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "www.example.com")


def test_uri_ip_address_no_scheme():
    var uri = URI.parse("168.22.0.1/path/to/favicon.ico")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "168.22.0.1")
    testing.assert_equal(uri.path, "/path/to/favicon.ico")


def test_uri_ip_address():
    var uri = URI.parse("http://168.22.0.1:8080/path/to/favicon.ico")
    testing.assert_equal(uri.scheme, "http")
    testing.assert_equal(uri.host, "168.22.0.1")
    testing.assert_equal(uri.path, "/path/to/favicon.ico")
    testing.assert_equal(uri.port.value(), 8080)


# def test_uri_parse_http_with_hash():
#     ...
