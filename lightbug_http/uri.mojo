from utils import Variant, StringSlice
from memory import Span
from collections import Optional
from lightbug_http.io.bytes import Bytes, bytes, ByteReader, Constant
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
struct Scheme(Hashable, EqualityComparable, Representable, Stringable, Writable):
    var value: String
    alias HTTP = Self("http")
    alias HTTPS = Self("https")

    fn __hash__(self) -> UInt:
        return hash(self.value)

    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __ne__(self, other: Self) -> Bool:
        return self.value != other.value

    fn write_to[W: Writer, //](self, mut writer: W) -> None:
        writer.write("Scheme(value=", repr(self.value), ")")

    fn __repr__(self) -> String:
        return String.write(self)

    fn __str__(self) -> String:
        return self.value.upper()


fn parse_host_and_port(source: String, is_tls: Bool) raises -> (String, UInt16):
    """Parses the host and port from a given string.

    Args:
        source: The host uri to parse.
        is_tls: A boolean indicating whether the connection is secure.

    Returns:
        A tuple containing the host and port.
    """
    if source.count(":") != 1:
        var port: UInt16 = 443 if is_tls else 80
        return source, port

    var result = source.split(":")
    return result[0], UInt16(atol(result[1]))


@value
struct URI(Writable, Stringable, Representable):
    var _original_path: String
    var scheme: String
    var path: String
    var query_string: String
    var _hash: String
    var host: String
    var port: Optional[UInt16]

    var full_uri: String
    var request_uri: String

    var username: String
    var password: String

    @staticmethod
    fn parse(owned uri: String) raises -> URI:
        """Parses a URI which is defined using the following format.

        `[scheme:][//[user_info@]host][/]path[?query][#fragment]`
        """
        var reader = ByteReader(uri.as_bytes())

        # Parse the scheme, if exists.
        # Assume http if no scheme is provided, fairly safe given the context of lightbug.
        var scheme: String = "http"
        if Constant.COLON in reader:
            scheme = str(reader.read_until(Constant.COLON))
            if reader.read_bytes(3) != "://".as_bytes():
                raise Error("URI.parse: Invalid URI format, scheme should be followed by `://`. Received: " + uri)

        # Parse the user info, if exists.
        var user_info: String = ""
        if Constant.AT in reader:
            user_info = str(reader.read_until(Constant.AT))
            reader.increment(1)

        # TODOs (@thatstoasty)
        # Handle ipv4 and ipv6 literal
        # Handle string host
        # A query right after the domain is a valid uri, but it's equivalent to example.com/?query
        # so we should add the normalization of paths
        var host_and_port = reader.read_until(Constant.SLASH)
        colon = host_and_port.find(Constant.COLON)
        var host: String
        var port: Optional[UInt16] = None
        if colon != -1:
            host = str(host_and_port[:colon])
            var port_end = colon + 1
            # loop through the post colon chunk until we find a non-digit character
            for b in host_and_port[colon + 1 :]:
                if b[] < Constant.ZERO or b[] > Constant.NINE:
                    break
                port_end += 1
            port = UInt16(atol(str(host_and_port[colon + 1 : port_end])))
        else:
            host = str(host_and_port)

        # Parse the path
        var path: String = "/"
        if reader.available() and reader.peek() == Constant.SLASH:
            # Read until the query string, or the end if there is none.
            path = str(reader.read_until(Constant.QUESTION))

        # Parse query
        var query: String = ""
        if reader.available() and reader.peek() == Constant.QUESTION:
            # TODO: Handle fragments for anchors
            query = str(reader.read_bytes()[1:])

        return URI(
            _original_path=path,
            scheme=scheme,
            path=path,
            query_string=query,
            _hash="",
            host=host,
            port=port,
            full_uri=uri,
            request_uri=uri,
            username="",
            password="",
        )

    fn __str__(self) -> String:
        var result = String.write(self.scheme, "://", self.host, self.path)
        if len(self.query_string) > 0:
            result.write("?", self.query_string)
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
