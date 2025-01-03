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


@value
struct URI(Writable, Stringable):
    var __path_original: String
    var scheme: String
    var path: String
    var query_string: String
    var __hash: String
    var host: String

    var full_uri: String
    var request_uri: String

    var username: String
    var password: String

    @staticmethod
    fn parse(uri: String) -> Variant[URI, String]:
        var u = URI(uri)
        try:
            u._parse()
        except e:
            return "Failed to parse URI: " + str(e)

        return u

    @staticmethod
    fn parse_raises(uri: String) raises -> URI:
        var u = URI(uri)
        u._parse()
        return u

    fn __init__(
        mut self,
        uri: String = "",
    ) -> None:
        self.__path_original = "/"
        self.scheme = ""
        self.path = "/"
        self.query_string = ""
        self.__hash = ""
        self.host = ""
        self.full_uri = uri
        self.request_uri = ""
        self.username = ""
        self.password = ""

    fn __str__(self) -> String:
        var s = self.scheme + "://" + self.host + self.path
        if len(self.query_string) > 0:
            s += "?" + self.query_string
        return s

    fn write_to[T: Writer](self, mut writer: T):
        writer.write(str(self))

    fn is_https(self) -> Bool:
        return self.scheme == https

    fn is_http(self) -> Bool:
        return self.scheme == http or len(self.scheme) == 0

    fn _parse(mut self) raises -> None:
        var raw_uri = self.full_uri
        var proto_str = String(strHttp11)
        var is_https = False

        var proto_end = raw_uri.find("://")
        var remainder_uri: String
        if proto_end >= 0:
            proto_str = raw_uri[:proto_end]
            if proto_str == https:
                is_https = True
            remainder_uri = raw_uri[proto_end + 3 :]
        else:
            remainder_uri = raw_uri

        self.scheme = proto_str^

        var path_start = remainder_uri.find("/")
        var host_and_port: String
        var request_uri: String
        if path_start >= 0:
            host_and_port = remainder_uri[:path_start]
            request_uri = remainder_uri[path_start:]
            self.host = host_and_port[:path_start]
        else:
            host_and_port = remainder_uri
            request_uri = strSlash
            self.host = host_and_port

        if is_https:
            self.scheme = https
        else:
            self.scheme = http

        var n = request_uri.find("?")
        if n >= 0:
            self.__path_original = request_uri[:n]
            self.query_string = request_uri[n + 1 :]
        else:
            self.__path_original = request_uri
            self.query_string = Bytes()

        self.path = self.__path_original
        self.request_uri = request_uri


fn normalise_path(path: String, path_original: String) -> String:
    # TODO: implement
    return path
