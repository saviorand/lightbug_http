import testing
from lightbug_http.utils import ByteReader
from lightbug_http.header import Headers, Header


fn test_byte_reader() raises:
    # var headers = "HTTP/1.1 200 OK\r\nServer: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Encoding: gzip\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n"
    var headers = "GET /redirect HTTP/1.1\r\nconnection: keep-alive\r\ncontent-length: 0\r\nhost: 127.0.0.1:8080\r\n\r\n"
    var reader = ByteReader(headers.as_bytes())
    var header = Headers()
    var properties = header.parse_raw(reader)
    protocol, status_code, status_text = properties[0], properties[1], properties[2]
    testing.assert_equal(protocol, "HTTP/1.1")
    testing.assert_equal(status_code, "200")
    testing.assert_equal(status_text, "OK")
    testing.assert_equal(header["Server"], "example.com")
    testing.assert_equal(header["Content-Type"], "text/html")
    testing.assert_equal(header["Content-Encoding"], "gzip")
    testing.assert_equal(header["Content-Length"], "1234")
    testing.assert_equal(header["Connection"], "close")
    testing.assert_equal(header["Trailer"], "end-of-message")

