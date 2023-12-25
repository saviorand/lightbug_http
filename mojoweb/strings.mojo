from mojoweb.utils import Bytes

alias strSlash = String("/")._buffer
alias strHttp = String("http")._buffer
alias strHttps = String("https")._buffer
alias strHttp11 = String("HTTP/1.1")._buffer

alias strMethodGet = String("GET")._buffer


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
