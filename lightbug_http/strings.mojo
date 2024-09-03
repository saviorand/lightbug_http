from utils import Span
from lightbug_http.io.bytes import Bytes

alias strSlash = "/"
alias strHttp = "http"
alias http = "http"
alias strHttps = "https"
alias https = "https"
alias strHttp11 = "HTTP/1.1"
alias strHttp10 = "HTTP/1.0"

alias strMethodGet = "GET"

alias rChar = "\r"
alias rChar_byte = ord(rChar)
alias nChar = "\n"
alias nChar_byte = ord(nChar)
alias colonChar = ":"
alias colonChar_byte = ord(colonChar)

alias h_byte = ord("h")
alias H_byte = ord("H")
alias c_byte = ord("c")
alias C_byte = ord("C")
alias u_byte = ord("u")
alias U_byte = ord("U")
alias t_byte = ord("t")
alias T_byte = ord("T")
alias s_byte = ord("s")
alias S_byte = ord("S")

alias empty_string = ""
alias whitespace = " "
alias whitespace_byte = ord(whitespace)
alias tab = "\t"
alias tab_byte = ord(tab)

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


fn to_string(b: Span[UInt8]) -> String:
    """Creates a String from a copy of the provided Span of bytes.

    Args:
        b: The Span of bytes to convert to a String.
    """
    var bytes = List[UInt8, True](b)
    bytes.append(0)
    return String(bytes^)


fn to_string(owned bytes: List[UInt8, True]) -> String:
    """Creates a String from the provided List of bytes.
    If you do not transfer ownership of the List, the List will be copied.
    
    Args:
        bytes: The List of bytes to convert to a String.
    """
    if bytes[-1] != 0:
        bytes.append(0)
    return String(bytes^)