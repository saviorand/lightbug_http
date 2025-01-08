from small_time.small_time import now
from lightbug_http.uri import URI
from lightbug_http.utils import ByteReader, ByteWriter
from lightbug_http.io.bytes import Bytes, bytes, Byte, byte
from lightbug_http.strings import (
    strHttp11,
    strHttp,
    strSlash,
    whitespace,
    rChar,
    nChar,
    lineBreak,
    to_string,
)
from collections import Optional
from utils import StringSlice
from lightbug_http.net import TCPConnection, default_buffer_size


struct StatusCode:
    alias OK = 200
    alias MOVED_PERMANENTLY = 301
    alias FOUND = 302
    alias TEMPORARY_REDIRECT = 307
    alias PERMANENT_REDIRECT = 308
    alias NOT_FOUND = 404
    alias INTERNAL_ERROR = 500


@value
struct HTTPResponse(Writable, Stringable):
    var headers: Headers
    var cookies: ResponseCookieJar
    var body_raw: Bytes

    var status_code: Int
    var status_text: String
    var protocol: String

    @staticmethod
    fn from_bytes(b: Span[Byte]) raises -> HTTPResponse:
        var reader = ByteReader(b)
        var headers = Headers()
        var cookies = ResponseCookieJar()
        var protocol: String
        var status_code: String
        var status_text: String

        try:
            var properties = headers.parse_raw(reader)
            protocol, status_code, status_text = properties[0], properties[1], properties[2]
            cookies.from_headers(properties[3])
            reader.skip_newlines()
        except e:
            raise Error("Failed to parse response headers: " + str(e))
    
        var response = HTTPResponse(
            Bytes(),
            headers=headers,
            cookies=cookies,
            protocol=protocol,
            status_code=int(status_code),
            status_text=status_text,
        )
        try:
            response.read_body(reader)
            return response
        except e:
            logger.error(e)
            raise Error("Failed to read request body: ")

    @staticmethod
    fn from_bytes(b: Span[Byte], conn: TCPConnection) raises -> HTTPResponse:
        var reader = ByteReader(b)
        var headers = Headers()
        var cookies = ResponseCookieJar()
        var protocol: String
        var status_code: String
        var status_text: String

        try:
            var properties = headers.parse_raw(reader)
            protocol, status_code, status_text = properties[0], properties[1], properties[2]
            cookies.from_headers(properties[3])
            reader.skip_newlines()
        except e:
            raise Error("Failed to parse response headers: " + e.__str__())
    
        var response = HTTPResponse(
            Bytes(),
            headers=headers,
            cookies=cookies,
            protocol=protocol,
            status_code=int(status_code),
            status_text=status_text,
        )

        var transfer_encoding = response.headers.get(HeaderKey.TRANSFER_ENCODING)
        if transfer_encoding and transfer_encoding.value() == "chunked":
            var b = reader.bytes()

            var buff = Bytes(capacity=default_buffer_size)
            try:
                while conn.read(buff) > 0:
                    b += buff

                    if buff[-5] == byte('0') and buff[-4] == byte('\r')
                        and buff[-3] == byte('\n')
                        and buff[-2] == byte('\r')
                        and buff[-1] == byte('\n'):
                        break

                    buff.resize(0)
                response.read_chunks(b^)
                return response
            except e:
                logger.error(e)
                raise Error("Failed to read chunked response.")

        try:
            response.read_body(reader)
            return response
        except e:
            logger.error(e)
            raise Error("Failed to read request body: ")

    fn __init__(
        mut self,
        body_bytes: Span[Byte],
        headers: Headers = Headers(),
        cookies: ResponseCookieJar = ResponseCookieJar(),
        status_code: Int = 200,
        status_text: String = "OK",
        protocol: String = strHttp11,
    ):
        self.headers = headers
        self.cookies = cookies
        if HeaderKey.CONTENT_TYPE not in self.headers:
            self.headers[HeaderKey.CONTENT_TYPE] = "application/octet-stream"
        self.status_code = status_code
        self.status_text = status_text
        self.protocol = protocol
        self.body_raw = body_bytes
        if HeaderKey.CONNECTION not in self.headers:
            self.set_connection_keep_alive()
        if HeaderKey.CONTENT_LENGTH not in self.headers:
            self.set_content_length(len(body_bytes))
        if HeaderKey.DATE not in self.headers:
            try:
                var current_time = now(utc=True).__str__()
                self.headers[HeaderKey.DATE] = current_time
            except:
                pass

    fn get_body_bytes(self) -> Bytes:
        return self.body_raw

    @always_inline
    fn set_connection_close(mut self):
        self.headers[HeaderKey.CONNECTION] = "close"

    @always_inline
    fn set_connection_keep_alive(mut self):
        self.headers[HeaderKey.CONNECTION] = "keep-alive"

    fn connection_close(self) -> Bool:
        var result = self.headers.get(HeaderKey.CONNECTION)
        if not result:
            return False
        return result.value() == "close"

    @always_inline
    fn set_content_length(mut self, l: Int):
        self.headers[HeaderKey.CONTENT_LENGTH] = str(l)

    @always_inline
    fn content_length(self) -> Int:
        try:
            return int(self.headers[HeaderKey.CONTENT_LENGTH])
        except:
            return 0

    @always_inline
    fn is_redirect(self) -> Bool:
        return (
            self.status_code == StatusCode.MOVED_PERMANENTLY
            or self.status_code == StatusCode.FOUND
            or self.status_code == StatusCode.TEMPORARY_REDIRECT
            or self.status_code == StatusCode.PERMANENT_REDIRECT
        )

    @always_inline
    fn read_body(mut self, mut r: ByteReader) raises -> None:
        self.body_raw = r.bytes(self.content_length())
        self.set_content_length(len(self.body_raw))

    fn read_chunks(mut self, chunks: Bytes) raises:
        var reader = ByteReader(Span(chunks))
        while True:
            var size = atol(StringSlice(unsafe_from_utf8=reader.read_line()), 16)
            if size == 0:
                break
            var data = reader.bytes(size)
            reader.skip_newlines()
            self.set_content_length(self.content_length() + len(data))
            self.body_raw += data

    fn write_to[T: Writer](self, mut writer: T):
        writer.write(self.protocol, whitespace, self.status_code, whitespace, self.status_text, lineBreak)

        if HeaderKey.SERVER not in self.headers:
            writer.write("server: lightbug_http", lineBreak)

        writer.write(self.headers)
        writer.write(self.cookies)
        writer.write(lineBreak)
        writer.write(to_string(self.body_raw))

    fn _encoded(mut self) -> Bytes:
        """Encodes response as bytes.

        This method consumes the data in this request and it should
        no longer be considered valid.
        """
        var writer = ByteWriter()
        writer.write(self.protocol)
        writer.write(whitespace)
        writer.consuming_write(bytes(str(self.status_code)))
        writer.write(whitespace)
        writer.write(self.status_text)
        writer.write(lineBreak)
        writer.write("server: lightbug_http")
        writer.write(lineBreak)

        if HeaderKey.DATE not in self.headers:
            try:
                var current_time = now(utc=True).__str__()
                write_header(writer, HeaderKey.DATE, current_time)
            except:
                pass

        writer.write(self.headers)
        writer.write(self.cookies)
        writer.write(lineBreak)
        writer.consuming_write(self.body_raw)

        return writer.consume()

    fn __str__(self) -> String:
        return to_string(self)
