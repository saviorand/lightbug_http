from lightbug_http.io.bytes import Bytes

alias strSlash = String("/").as_bytes()
alias strHttp = String("http").as_bytes()
alias http = String("http")
alias strHttps = String("https").as_bytes()
alias https = String("https")
alias strHttp11 = String("HTTP/1.1").as_bytes()
alias strHttp10 = String("HTTP/1.0").as_bytes()

alias strMethodGet = String("GET").as_bytes()

alias rChar = String("\r").as_bytes()
alias nChar = String("\n").as_bytes()


# This is temporary due to no string support in tuples in Mojo, to be removed
@value
struct TwoLines:
    var first_line: String
    var rest: String

    fn __init__(inout self, first_line: String, rest: String) -> None:
        self.first_line = first_line
        self.rest = rest


# Helper function to split a string into two lines by delimiter
fn next_line(s: String, delimiter: String = "\n") raises -> TwoLines:
    var first_newline = s.find(delimiter)
    if first_newline == -1:
        return TwoLines(s, String())
    var before_newline = s[0:first_newline]
    var after_newline = s[first_newline + 1 :]
    return TwoLines(before_newline.strip(), after_newline)


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
