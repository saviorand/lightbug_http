from utils import StringSlice
from memory import Span
from lightbug_http.io.bytes import Bytes, bytes, byte

alias strSlash = "/"
alias strHttp = "http"
alias http = "http"
alias strHttps = "https"
alias https = "https"
alias strHttp11 = "HTTP/1.1"
alias strHttp10 = "HTTP/1.0"

alias strMethodGet = "GET"

alias rChar = "\r"
alias nChar = "\n"
alias lineBreak = rChar + nChar
alias colonChar = ":"

alias empty_string = ""
alias whitespace = " "
alias whitespace_byte = ord(whitespace)
alias tab = "\t"
alias tab_byte = ord(tab)


struct BytesConstant:
    alias whitespace = byte(whitespace)
    alias colon = byte(colonChar)
    alias rChar = byte(rChar)
    alias nChar = byte(nChar)


@value
struct NetworkType(EqualityComparableCollectionElement):
    var value: String

    alias empty = NetworkType("")
    alias tcp = NetworkType("tcp")
    alias tcp4 = NetworkType("tcp4")
    alias tcp6 = NetworkType("tcp6")
    alias udp = NetworkType("udp")
    alias udp4 = NetworkType("udp4")
    alias udp6 = NetworkType("udp6")
    alias ip = NetworkType("ip")
    alias ip4 = NetworkType("ip4")
    alias ip6 = NetworkType("ip6")
    alias unix = NetworkType("unix")

    alias SUPPORTED_TYPES = [
        Self.tcp,
        Self.tcp4,
        Self.tcp6,
        Self.udp,
        Self.udp4,
        Self.udp6,
        Self.ip,
        Self.ip4,
        Self.ip6,
    ]
    alias TCP_TYPES = [
        Self.tcp,
        Self.tcp4,
        Self.tcp6,
    ]
    alias UDP_TYPES = [
        Self.udp,
        Self.udp4,
        Self.udp6,
    ]
    alias IP_TYPES = [
        Self.ip,
        Self.ip4,
        Self.ip6,
    ]

    fn __eq__(self, other: NetworkType) -> Bool:
        return self.value == other.value

    fn __ne__(self, other: NetworkType) -> Bool:
        return self.value != other.value


@value
struct ConnType:
    var value: String

    alias empty = ConnType("")
    alias http = ConnType("http")
    alias websocket = ConnType("websocket")


@value
struct RequestMethod:
    var value: String

    alias get = RequestMethod("GET")
    alias post = RequestMethod("POST")
    alias put = RequestMethod("PUT")
    alias delete = RequestMethod("DELETE")
    alias head = RequestMethod("HEAD")
    alias patch = RequestMethod("PATCH")
    alias options = RequestMethod("OPTIONS")


@value
struct CharSet:
    var value: String

    alias utf8 = CharSet("utf-8")


@value
struct MediaType:
    var value: String

    alias empty = MediaType("")
    alias plain = MediaType("text/plain")
    alias json = MediaType("application/json")


@value
struct Message:
    var type: String

    alias empty = Message("")
    alias http_start = Message("http.response.start")


fn to_string[T: Writable](value: T) -> String:
    return String.write(value)


fn to_string(b: Span[UInt8]) -> String:
    """Creates a String from a copy of the provided Span of bytes.

    Args:
        b: The Span of bytes to convert to a String.
    """
    return String(StringSlice(unsafe_from_utf8=b))


fn to_string(owned bytes: Bytes) -> String:
    """Creates a String from the provided List of bytes.
    If you do not transfer ownership of the List, the List will be copied.

    Args:
        bytes: The List of bytes to convert to a String.
    """
    if bytes[-1] != 0:
        bytes.append(0)
    return String(bytes^)


fn find_all(s: String, sub_str: String) -> List[Int]:
    match_idxs = List[Int]()
    var current_idx: Int = s.find(sub_str)
    while current_idx > -1:
        match_idxs.append(current_idx)
        current_idx = s.find(sub_str, start=current_idx + 1)
    return match_idxs^
