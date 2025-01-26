from collections import Dict
from utils import Variant
from lightbug_http.io.bytes import Bytes, bytes
from lightbug_http.strings import (
    strSlash,
    strHttp11,
    strHttp10,
    strHttp,
    http,
    strHttps,
    https,
)

alias QueryMap = Dict[String, String]


struct QueryDelimiters:
    alias STRING_START = "?"
    alias ITEM = "&"
    alias ITEM_ASSIGN = "="


struct URIDelimiters:
    alias SCHEMA = "://"
    alias PATH = strSlash
    alias ROOT_PATH = strSlash


@value
struct URI(Writable, Stringable, Representable):
    var _original_path: String
    var scheme: String
    var path: String
    var query_string: String
    var queries: QueryMap
    var _hash: String
    var host: String

    var full_uri: String
    var request_uri: String

    var username: String
    var password: String

    @staticmethod
    fn parse(uri: String) raises -> URI:
        var proto_str = String(strHttp11)
        var is_https = False

        var proto_end = uri.find(URIDelimiters.SCHEMA)
        var remainder_uri: String
        if proto_end >= 0:
            proto_str = uri[:proto_end]
            if proto_str == https:
                is_https = True
            remainder_uri = uri[proto_end + 3 :]
        else:
            remainder_uri = uri

        var path_start = remainder_uri.find(URIDelimiters.PATH)
        var host_and_port: String
        var request_uri: String
        var host: String
        if path_start >= 0:
            host_and_port = remainder_uri[:path_start]
            request_uri = remainder_uri[path_start:]
            host = host_and_port[:path_start]
        else:
            host_and_port = remainder_uri
            request_uri = strSlash
            host = host_and_port

        var scheme: String
        if is_https:
            scheme = https
        else:
            scheme = http

        var n = request_uri.find(QueryDelimiters.STRING_START)
        var original_path: String
        var query_string: String
        if n >= 0:
            original_path = request_uri[:n]
            query_string = request_uri[n + 1 :]
        else:
            original_path = request_uri
            query_string = ""

        var queries = QueryMap()
        if query_string:
            var query_items = query_string.split(QueryDelimiters.ITEM)

            for item in query_items:
                var key_val = item[].split(QueryDelimiters.ITEM_ASSIGN, 1)

                if key_val[0]:
                    queries[key_val[0]] = ""
                    if len(key_val) == 2:
                        queries[key_val[0]] = key_val[1]

        return URI(
            _original_path=original_path,
            scheme=scheme,
            path=original_path,
            query_string=query_string,
            queries=queries,
            _hash="",
            host=host,
            full_uri=uri,
            request_uri=request_uri,
            username="",
            password="",
        )

    fn __str__(self) -> String:
        var result = String.write(self.scheme, URIDelimiters.SCHEMA, self.host, self.path)
        if len(self.query_string) > 0:
            result.write(QueryDelimiters.STRING_START, self.query_string)
        return result^

    fn __repr__(self) -> String:
        return String.write(self)

    fn write_to[T: Writer](self, mut writer: T):
        writer.write(
            "URI(",
            "scheme=",
            repr(self.scheme),
            ", host=",
            repr(self.host),
            ", path=",
            repr(self.path),
            ", _original_path=",
            repr(self._original_path),
            ", query_string=",
            repr(self.query_string),
            ", full_uri=",
            repr(self.full_uri),
            ", request_uri=",
            repr(self.request_uri),
            ")",
        )

    fn is_https(self) -> Bool:
        return self.scheme == https

    fn is_http(self) -> Bool:
        return self.scheme == http or len(self.scheme) == 0
