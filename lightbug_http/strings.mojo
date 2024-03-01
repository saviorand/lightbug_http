from lightbug_http.io.bytes import Bytes

alias strSlash = String("/")._buffer
alias strHttp = String("http")._buffer
alias strHttps = String("https")._buffer
alias strHttp11 = String("HTTP/1.1")._buffer
alias strHttp10 = String("HTTP/1.0")._buffer

alias strMethodGet = String("GET")._buffer

alias rChar = String("\r")._buffer
alias nChar = String("\n")._buffer


# TODO: tuples don't work with strings in Mojo currently, to be replaced with a tuple
@value
struct TwoLines:
    var first_line: String
    var rest: String

    fn __init__(inout self, first_line: String, rest: String) -> None:
        self.first_line = first_line
        self.rest = rest


# Helper function to get the next line
fn next_line(s: String) raises -> TwoLines:
    var split = s.split("\n")
    return TwoLines(split[0].strip(), split[1]) if len(split) == 2 else TwoLines(
        split[0].strip(), String()
    )


@value
struct NetworkType:
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
