from external.gojo.bufio import Reader
from lightbug_http.strings import (
    strHttp11,
    strHttp10,
    strSlash,
    strMethodGet,
    rChar,
    nChar,
    colonChar,
    whitespace,
    tab
)
from lightbug_http.io.bytes import Bytes, Byte, BytesView, bytes_equal, bytes, index_byte, compare_case_insensitive, next_line, last_index_byte

alias statusOK = 200

@value
struct RequestHeader:
    var disable_normalization: Bool
    var no_http_1_1: Bool
    var __connection_close: Bool
    var __content_length: Int
    var __content_length_bytes: Bytes
    var __method: Bytes
    var __request_uri: Bytes
    var proto: Bytes
    var __host: Bytes
    var __content_type: Bytes
    var __user_agent: Bytes
    var __transfer_encoding: Bytes
    var raw_headers: Bytes
    var __trailer: Bytes

    fn __init__(inout self) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.__content_length = 0
        self.__content_length_bytes = Bytes()
        self.__method = Bytes()
        self.__request_uri = Bytes()
        self.proto = Bytes()
        self.__host = Bytes()
        self.__content_type = Bytes()
        self.__user_agent = Bytes()
        self.__transfer_encoding = Bytes()
        self.raw_headers = Bytes()
        self.__trailer = Bytes()

    fn __init__(inout self, host: String) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.__content_length = 0
        self.__content_length_bytes = Bytes()
        self.__method = Bytes()
        self.__request_uri = Bytes()
        self.proto = Bytes()
        self.__host = bytes(host)
        self.__content_type = Bytes()
        self.__user_agent = Bytes()
        self.__transfer_encoding = Bytes()
        self.raw_headers = Bytes()
        self.__trailer = Bytes()

    fn __init__(inout self, rawheaders: Bytes) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.__content_length = 0
        self.__content_length_bytes = Bytes()
        self.__method = Bytes()
        self.__request_uri = Bytes()
        self.proto = Bytes()
        self.__host = Bytes()
        self.__content_type = Bytes()
        self.__user_agent = Bytes()
        self.__transfer_encoding = Bytes()
        self.raw_headers = rawheaders
        self.__trailer = Bytes()

    fn __init__(
        inout self,
        disable_normalization: Bool,
        no_http_1_1: Bool,
        connection_close: Bool,
        content_length: Int,
        content_length_bytes: Bytes,
        method: Bytes,
        request_uri: Bytes,
        proto: Bytes,
        host: Bytes,
        content_type: Bytes,
        user_agent: Bytes,
        transfer_encoding: Bytes,
        raw_headers: Bytes,
        trailer: Bytes,
    ) -> None:
        self.disable_normalization = disable_normalization
        self.no_http_1_1 = no_http_1_1
        self.__connection_close = connection_close
        self.__content_length = content_length
        self.__content_length_bytes = content_length_bytes
        self.__method = method
        self.__request_uri = request_uri
        self.proto = proto
        self.__host = host
        self.__content_type = content_type
        self.__user_agent = user_agent
        self.__transfer_encoding = transfer_encoding
        self.raw_headers = raw_headers
        self.__trailer = trailer

    fn set_content_type(inout self, content_type: String) -> Self:
        self.__content_type = bytes(content_type)
        return self

    fn set_content_type_bytes(inout self, content_type: Bytes) -> Self:
        self.__content_type = content_type
        return self

    fn content_type(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__content_type.unsafe_ptr(), len=self.__content_type.size)

    fn set_host(inout self, host: String) -> Self:
        self.__host = bytes(host)
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        self.__host = host
        return self

    fn host(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__host.unsafe_ptr(), len=self.__host.size)

    fn set_user_agent(inout self, user_agent: String) -> Self:
        self.__user_agent = bytes(user_agent)
        return self

    fn set_user_agent_bytes(inout self, user_agent: Bytes) -> Self:
        self.__user_agent = user_agent
        return self

    fn user_agent(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__user_agent.unsafe_ptr(), len=self.__user_agent.size)

    fn set_method(inout self, method: String) -> Self:
        self.__method = bytes(method)
        return self

    fn set_method_bytes(inout self, method: Bytes) -> Self:
        self.__method = method
        return self

    fn method(self) -> BytesView:
        if len(self.__method) == 0:
            return strMethodGet.as_bytes_slice()
        return BytesView(unsafe_ptr=self.__method.unsafe_ptr(), len=self.__method.size)
    
    fn set_protocol(inout self, proto: String) -> Self:
        self.no_http_1_1 = False # hardcoded until HTTP/2 is supported
        self.proto = bytes(proto)
        return self

    fn set_protocol_bytes(inout self, proto: Bytes) -> Self:
        self.no_http_1_1 = False # hardcoded until HTTP/2 is supported
        self.proto = proto
        return self

    fn protocol_str(self) -> String:
        if len(self.proto) == 0:
            return strHttp11
        return String(self.proto)

    fn protocol(self) -> BytesView:
        if len(self.proto) == 0:
            return strHttp11.as_bytes_slice()
        return BytesView(unsafe_ptr=self.proto.unsafe_ptr(), len=self.proto.size)
    
    fn content_length(self) -> Int:
        return self.__content_length

    fn set_content_length(inout self, content_length: Int) -> Self:
        self.__content_length = content_length
        return self

    fn set_content_length_bytes(inout self, content_length: Bytes) -> Self:
        self.__content_length_bytes = content_length
        return self

    fn set_request_uri(inout self, request_uri: String) -> Self:
        self.__request_uri = request_uri.as_bytes_slice()
        return self

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        self.__request_uri = request_uri
        return self

    fn request_uri(self) -> BytesView:
        if len(self.__request_uri) <= 1:
            return BytesView(unsafe_ptr=strSlash.as_bytes_slice().unsafe_ptr(), len=2)
        return BytesView(unsafe_ptr=self.__request_uri.unsafe_ptr(), len=self.__request_uri.size)

    fn set_transfer_encoding(inout self, transfer_encoding: String) -> Self:
        self.__transfer_encoding = bytes(transfer_encoding)
        return self
    
    fn set_transfer_encoding_bytes(inout self, transfer_encoding: Bytes) -> Self:
        self.__transfer_encoding = transfer_encoding
        return self
    
    fn transfer_encoding(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__transfer_encoding.unsafe_ptr(), len=self.__transfer_encoding.size)

    fn set_trailer(inout self, trailer: String) -> Self:
        self.__trailer = bytes(trailer)
        return self

    fn set_trailer_bytes(inout self, trailer: Bytes) -> Self:
        self.__trailer = trailer
        return self
    
    fn trailer(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__trailer.unsafe_ptr(), len=self.__trailer.size)
    
    fn trailer_str(self) -> String:
        return String(self.__trailer)

    fn set_connection_close(inout self) -> Self:
        self.__connection_close = True
        return self

    fn reset_connection_close(inout self) -> Self:
        if self.__connection_close == False:
            return self
        else:
            self.__connection_close = False
            return self

    fn connection_close(self) -> Bool:
        return self.__connection_close

    fn headers(self) -> String:
        return String(self.raw_headers)

    fn parse_raw(inout self, inout r: Reader) raises -> Int:
        var first_byte = r.peek(1)
        if len(first_byte) == 0:
            raise Error("Failed to read first byte from request header")
        
        var buf: Bytes
        var e: Error
        
        buf, e = r.peek(r.buffered())
        if e:
            raise Error("Failed to read request header: " + e.__str__())
        if len(buf) == 0:
            raise Error("Failed to read request header, empty buffer")
        
        var end_of_first_line = self.parse_first_line(buf)

        var header_len = self.read_raw_headers(buf[end_of_first_line:])

        self.parse_headers(buf[end_of_first_line:])
        
        return end_of_first_line + header_len

    fn parse_first_line(inout self, buf: Bytes) raises -> Int:
        var b_next = buf
        var b = Bytes()
        while len(b) == 0:
            try:
                b, b_next = next_line(b_next)
            except e:
                raise Error("Failed to read first line from request, " + e.__str__())
        
        var first_whitespace = index_byte(b, bytes(whitespace, pop=False)[0])
        if first_whitespace <= 0:
            raise Error("Could not find HTTP request method in request line: " + String(b))
        
        _ = self.set_method_bytes(b[:first_whitespace])

        var last_whitespace = last_index_byte(b, bytes(whitespace, pop=False)[0]) + 1

        if last_whitespace < 0:
            raise Error("Could not find request target or HTTP version in request line: " + String(b))
        elif last_whitespace == 0:
            raise Error("Request URI is empty: " + String(b))
        
        var proto = b[last_whitespace :]
        if len(proto) != len(bytes(strHttp11, pop=False)):
            raise Error("Invalid protocol, HTTP version not supported: " + String(proto))
        
        _ = self.set_protocol_bytes(proto)
        _ = self.set_request_uri_bytes(b[first_whitespace+1:last_whitespace])
        
        return len(buf) - len(b_next)
       
    fn parse_headers(inout self, buf: Bytes) raises -> None:
        _ = self.set_content_length(-2)
        var s = headerScanner()
        s.set_b(buf)

        while s.next():
            if len(s.key()) > 0:
                self.parse_header(s.key(), s.value())
    
    fn parse_header(inout self, key: Bytes, value: Bytes) raises -> None:
        if index_byte(key, bytes(colonChar, pop=False)[0]) == -1 or index_byte(key, bytes(tab, pop=False)[0]) != -1:
            raise Error("Invalid header key: " + String(key))

        var key_first = key[0].__xor__(0x20)

        if key_first == bytes("h", pop=False)[0] or key_first == bytes("H", pop=False)[0]:
            if compare_case_insensitive(key, bytes("host", pop=False)):
                _ = self.set_host_bytes(bytes(value, pop=False))
                return
        elif key_first == bytes("u", pop=False)[0] or key_first == bytes("U", pop=False)[0]:
            if compare_case_insensitive(key, bytes("user-agent", pop=False)):
                _ = self.set_user_agent_bytes(bytes(value, pop=False))
                return
        elif key_first == bytes("c", pop=False)[0] or key_first == bytes("C", pop=False)[0]:
            if compare_case_insensitive(key, bytes("content-type", pop=False)):
                _ = self.set_content_type_bytes(bytes(value, pop=False))
                return
            if compare_case_insensitive(key, bytes("content-length", pop=False)):
                if self.content_length() != -1:
                    _ = self.set_content_length_bytes(bytes(value))
                return
            if compare_case_insensitive(key, bytes("connection", pop=False)):
                if compare_case_insensitive(value, bytes("close", pop=False)):
                    _ = self.set_connection_close()
                else:
                    _ = self.reset_connection_close()
                return
        elif key_first == bytes("t", pop=False)[0] or key_first == bytes("T", pop=False)[0]:
            if compare_case_insensitive(key, bytes("transfer-encoding", pop=False)):
                _ = self.set_transfer_encoding_bytes(bytes(value, pop=False))
                return
            if compare_case_insensitive(key, bytes("trailer", pop=False)):
                _ = self.set_trailer_bytes(bytes(value, pop=False))
                return
        if self.content_length() < 0:
            _ = self.set_content_length(0)
        return

    fn read_raw_headers(inout self, buf: Bytes) raises -> Int:
        var n = index_byte(buf, bytes(nChar, pop=False)[0])
        
        if n == -1:
            self.raw_headers = self.raw_headers[:0]
            raise Error("Failed to find a newline in headers")
        
        if n == 0 or (n == 1 and (buf[0] == bytes(rChar, pop=False)[0])):
            # empty line -> end of headers
            return n + 1
        
        n += 1
        var b = buf
        var m = n
        while True:
            b = b[m:]
            m = index_byte(b, bytes(nChar, pop=False)[0])
            if m == -1:
                raise Error("Failed to find a newline in headers")
            m += 1
            n += m
            if m == 2 and (b[0] == bytes(rChar, pop=False)[0]) or m == 1:
                self.raw_headers = self.raw_headers + buf[:n]
                return n



@value
struct ResponseHeader:
    var disable_normalization: Bool
    var no_http_1_1: Bool
    var __connection_close: Bool
    var __status_code: Int
    var __status_message: Bytes
    var __protocol: Bytes
    var __content_length: Int
    var __content_length_bytes: Bytes
    var __content_type: Bytes
    var __content_encoding: Bytes
    var __server: Bytes
    var __trailer: Bytes
    var raw_headers: Bytes

    fn __init__(
        inout self,
    ) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.__status_code = 200
        self.__status_message = Bytes()
        self.__protocol = Bytes()
        self.__content_length = 0
        self.__content_length_bytes = Bytes()
        self.__content_type = Bytes()
        self.__content_encoding = Bytes()
        self.__server = Bytes()
        self.__trailer = Bytes()
        self.raw_headers = Bytes()
    
    fn __init__(
        inout self,
        raw_headers: Bytes,
    ) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.__status_code = 200
        self.__status_message = Bytes()
        self.__protocol = Bytes()
        self.__content_length = 0
        self.__content_length_bytes = Bytes()
        self.__content_type = Bytes()
        self.__content_encoding = Bytes()
        self.__server = Bytes()
        self.__trailer = Bytes()
        self.raw_headers = raw_headers

    fn __init__(
        inout self,
        status_code: Int,
        status_message: Bytes,
        content_type: Bytes,
    ) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.__status_code = status_code
        self.__status_message = status_message
        self.__protocol = Bytes()
        self.__content_length = 0
        self.__content_length_bytes = Bytes()
        self.__content_type = content_type
        self.__content_encoding = Bytes()
        self.__server = Bytes()
        self.__trailer = Bytes()
        self.raw_headers = Bytes()
    
    fn __init__(
        inout self,
        status_code: Int,
        status_message: Bytes,
        content_type: Bytes,
        content_encoding: Bytes,
    ) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = False
        self.__status_code = status_code
        self.__status_message = status_message
        self.__protocol = Bytes()
        self.__content_length = 0
        self.__content_length_bytes = Bytes()
        self.__content_type = content_type
        self.__content_encoding = content_encoding
        self.__server = Bytes()
        self.__trailer = Bytes()
        self.raw_headers = Bytes()

    fn __init__(
        inout self,
        connection_close: Bool,
        status_code: Int,
        status_message: Bytes,
        content_type: Bytes,
    ) -> None:
        self.disable_normalization = False
        self.no_http_1_1 = False
        self.__connection_close = connection_close
        self.__status_code = status_code
        self.__status_message = status_message
        self.__protocol = Bytes()
        self.__content_length = 0
        self.__content_length_bytes = Bytes()
        self.__content_type = content_type
        self.__content_encoding = Bytes()
        self.__server = Bytes()
        self.__trailer = Bytes()
        self.raw_headers = Bytes()

    fn __init__(
        inout self,
        disable_normalization: Bool,
        no_http_1_1: Bool,
        connection_close: Bool,
        status_code: Int,
        status_message: Bytes,
        protocol: Bytes,
        content_length: Int,
        content_length_bytes: Bytes,
        content_type: Bytes,
        content_encoding: Bytes,
        server: Bytes,
        trailer: Bytes,
    ) -> None:
        self.disable_normalization = disable_normalization
        self.no_http_1_1 = no_http_1_1
        self.__connection_close = connection_close
        self.__status_code = status_code
        self.__status_message = status_message
        self.__protocol = protocol
        self.__content_length = content_length
        self.__content_length_bytes = content_length_bytes
        self.__content_type = content_type
        self.__content_encoding = content_encoding
        self.__server = server
        self.__trailer = trailer
        self.raw_headers = Bytes()

    fn set_status_code(inout self, code: Int) -> Self:
        self.__status_code = code
        return self

    fn status_code(self) -> Int:
        if self.__status_code == 0:
            return statusOK
        return self.__status_code

    fn set_status_message(inout self, message: Bytes) -> Self:
        self.__status_message = message
        return self
    
    fn status_message(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__status_message.unsafe_ptr(), len=self.__status_message.size)
    
    fn status_message_str(self) -> String:
        return String(self.status_message())

    fn content_type(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__content_type.unsafe_ptr(), len=self.__content_type.size)

    fn set_content_type(inout self, content_type: String) -> Self:
        self.__content_type = bytes(content_type)
        return self

    fn set_content_type_bytes(inout self, content_type: Bytes) -> Self:
        self.__content_type = content_type
        return self

    fn content_encoding(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__content_encoding.unsafe_ptr(), len=self.__content_encoding.size)

    fn set_content_encoding(inout self, content_encoding: String) -> Self:
        self.__content_encoding = bytes(content_encoding)
        return self

    fn set_content_encoding_bytes(inout self, content_encoding: Bytes) -> Self:
        self.__content_encoding = content_encoding
        return self
    
    fn content_length(self) -> Int:
        return self.__content_length
    
    fn set_content_length(inout self, content_length: Int) -> Self:
        self.__content_length = content_length
        return self
    
    fn set_content_length_bytes(inout self, content_length: Bytes) -> Self:
        self.__content_length_bytes = content_length
        return self

    fn server(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__server.unsafe_ptr(), len=self.__server.size)

    fn set_server(inout self, server: String) -> Self:
        self.__server = bytes(server)
        return self

    fn set_server_bytes(inout self, server: Bytes) -> Self:
        self.__server = server
        return self

    fn set_protocol(inout self, proto: String) -> Self:
        self.no_http_1_1 = False # hardcoded until HTTP/2 is supported
        self.__protocol = bytes(proto)
        return self
    
    fn set_protocol_bytes(inout self, protocol: Bytes) -> Self:
        self.no_http_1_1 = False # hardcoded until HTTP/2 is supported
        self.__protocol = protocol
        return self

    fn protocol_str(self) -> String:
        if len(self.__protocol) == 0:
            return strHttp11
        return String(self.__protocol)
    
    fn protocol(self) -> BytesView:
        if len(self.__protocol) == 0:
            return strHttp11.as_bytes_slice()
        return BytesView(unsafe_ptr=self.__protocol.unsafe_ptr(), len=self.__protocol.size)

    fn set_trailer(inout self, trailer: String) -> Self:
        self.__trailer = bytes(trailer)
        return self

    fn set_trailer_bytes(inout self, trailer: Bytes) -> Self:
        self.__trailer = trailer
        return self
    
    fn trailer(self) -> BytesView:
        return BytesView(unsafe_ptr=self.__trailer.unsafe_ptr(), len=self.__trailer.size)

    fn trailer_str(self) -> String:
        return String(self.trailer())
    
    fn set_connection_close(inout self) -> Self:
        self.__connection_close = True
        return self

    fn reset_connection_close(inout self) -> Self:
        if self.__connection_close == False:
            return self
        else:
            self.__connection_close = False
            return self

    fn connection_close(self) -> Bool:
        return self.__connection_close

    fn headers(self) -> String:
        return String(self.raw_headers)

    # fn parse_from_list(inout self, headers: List[String], first_line: String) raises -> None:
    #     _ = self.parse_first_line(first_line)

    #     for header in headers:
    #         var header_str = header[]
    #         var separator = header_str.find(":")
    #         if separator == -1:
    #             raise Error("Invalid header")
            
    #         var key = String(header_str)[:separator]
    #         var value = String(header_str)[separator + 1 :]

    #         if len(key) > 0:
    #             self.parse_header(key, value)

    fn parse_raw(inout self, inout r: Reader) raises -> Int:
        var first_byte = r.peek(1)
        if len(first_byte) == 0:
            raise Error("Failed to read first byte from response header")
        
        var buf: Bytes
        var e: Error
        
        buf, e = r.peek(r.buffered())
        if e:
            raise Error("Failed to read response header: " + e.__str__())
        if len(buf) == 0:
            raise Error("Failed to read response header, empty buffer")

        var end_of_first_line = self.parse_first_line(buf)

        var header_len = self.read_raw_headers(buf[end_of_first_line:])

        self.parse_headers(buf[end_of_first_line:])
        
        return end_of_first_line + header_len
    
    fn parse_first_line(inout self, buf: Bytes) raises -> Int:
        var b_next = buf
        var b = Bytes()
        while len(b) == 0:
            try:
                b, b_next = next_line(b_next)
            except e:
                raise Error("Failed to read first line from response, " + e.__str__())
        
        var first_whitespace = index_byte(b, bytes(whitespace, pop=False)[0])
        if first_whitespace <= 0:
            raise Error("Could not find HTTP version in response line: " + String(b))
            
        _ = self.set_protocol(b[:first_whitespace])
        
        var end_of_status_code = first_whitespace+5 # status code is always 3 digits, this calculation includes null terminator

        var status_code = atol(b[first_whitespace+1:end_of_status_code])
        _ = self.set_status_code(status_code)

        var status_text = b[end_of_status_code + 1 :]
        if len(status_text) > 1:
            _ = self.set_status_message(status_text)   

        return len(buf) - len(b_next)

    fn parse_headers(inout self, buf: Bytes) raises -> None:
        _ = self.set_content_length(-2)
        var s = headerScanner()
        s.set_b(buf)

        while s.next():
            if len(s.key()) > 0:
                self.parse_header(s.key(), s.value())
    
    fn parse_header(inout self, key: Bytes, value: Bytes) raises -> None:
        if index_byte(key, bytes(colonChar, pop=False)[0]) == -1 or index_byte(key, bytes(tab, pop=False)[0]) != -1:
            raise Error("Invalid header key: " + String(key))
        
        var key_first = key[0].__xor__(0x20)

        if key_first == bytes("c", pop=False)[0] or key_first == bytes("C", pop=False)[0]:
            if compare_case_insensitive(key, bytes("content-type", pop=False)):
                _ = self.set_content_type_bytes(bytes(value, pop=False))
                return
            if compare_case_insensitive(key, bytes("content-encoding", pop=False)):
                _ = self.set_content_encoding_bytes(bytes(value, pop=False))
                return
            if compare_case_insensitive(key, bytes("content-length", pop=False)):
                if self.content_length() != -1:
                    var content_length = value
                    _ = self.set_content_length(atol(content_length))
                    _ = self.set_content_length_bytes(bytes(content_length))
                return
            if compare_case_insensitive(key, bytes("connection", pop=False)):
                if compare_case_insensitive(value, bytes("close", pop=False)):
                    _ = self.set_connection_close()
                else:
                    _ = self.reset_connection_close()
                return
        elif key_first == bytes("s", pop=False)[0] or key_first == bytes("S", pop=False)[0]:
            if compare_case_insensitive(key, bytes("server", pop=False)):
                _ = self.set_server_bytes(bytes(value, pop=False))
                return
        elif key_first == bytes("t", pop=False)[0] or key_first == bytes("T", pop=False)[0]:
            if compare_case_insensitive(key, bytes("transfer-encoding", pop=False)):
                if not compare_case_insensitive(value, bytes("identity", pop=False)):
                    _ = self.set_content_length(-1)
                return
            if compare_case_insensitive(key, bytes("trailer", pop=False)):
                _ = self.set_trailer_bytes(bytes(value, pop=False))
    
    fn read_raw_headers(inout self, buf: Bytes) raises -> Int:
        var n = index_byte(buf, bytes(nChar, pop=False)[0])
        
        if n == -1:
            self.raw_headers = self.raw_headers[:0]
            raise Error("Failed to find a newline in headers")
        
        if n == 0 or (n == 1 and (buf[0] == bytes(rChar, pop=False)[0])):
            # empty line -> end of headers
            return n + 1
        
        n += 1
        var b = buf
        var m = n
        while True:
            b = b[m:]
            m = index_byte(b, bytes(nChar, pop=False)[0])
            if m == -1:
                raise Error("Failed to find a newline in headers")
            m += 1
            n += m
            if m == 2 and (b[0] == bytes(rChar, pop=False)[0]) or m == 1:
                self.raw_headers = self.raw_headers + buf[:n]
                return n

struct headerScanner:
    var __b: Bytes
    var __key: Bytes
    var __value: Bytes
    var __subslice_len: Int
    var disable_normalization: Bool
    var __next_colon: Int
    var __next_line: Int
    var __initialized: Bool

    fn __init__(inout self) -> None:
        self.__b = Bytes()
        self.__key = Bytes()
        self.__value = Bytes()
        self.__subslice_len = 0
        self.disable_normalization = False
        self.__next_colon = 0
        self.__next_line = 0
        self.__initialized = False

    fn b(self) -> Bytes:
        return self.__b

    fn set_b(inout self, b: Bytes) -> None:
        self.__b = b    

    fn key(self) -> Bytes:
        return self.__key
    
    fn set_key(inout self, key: Bytes) -> None:
        self.__key = key

    fn value(self) -> Bytes:
        return self.__value
    
    fn set_value(inout self, value: Bytes) -> None:
        self.__value = value
    
    fn subslice_len(self) -> Int:
        return self.__subslice_len
    
    fn set_subslice_len(inout self, n: Int) -> None:
        self.__subslice_len = n

    fn next_colon(self) -> Int:
        return self.__next_colon

    fn set_next_colon(inout self, n: Int) -> None:
        self.__next_colon = n
    
    fn next_line(self) -> Int:
        return self.__next_line
    
    fn set_next_line(inout self, n: Int) -> None:
        self.__next_line = n
    
    fn initialized(self) -> Bool:
        return self.__initialized

    fn set_initialized(inout self) -> None:
        self.__initialized = True
    
    fn next(inout self) raises -> Bool:
        if not self.initialized():
            self.set_next_colon(-1)
            self.set_next_line(-1)
            self.set_initialized()
        
        var b_len = len(self.b())

        if b_len >= 2 and (self.b()[0] == bytes(rChar, pop=False)[0]) and (self.b()[1] == bytes(nChar, pop=False)[0]):
            self.set_b(self.b()[2:])
            self.set_subslice_len(2)
            return False
        
        if b_len >= 1 and (self.b()[0] == bytes(nChar, pop=False)[0]):
            self.set_b(self.b()[1:])
            self.set_subslice_len(self.subslice_len() + 1)
            return False
        
        var colon: Int
        if self.next_colon() >= 0:
            colon = self.next_colon()
            self.set_next_colon(-1)
        else:
            colon = index_byte(self.b(), bytes(colonChar, pop=False)[0])
            var newline = index_byte(self.b(), bytes(nChar, pop=False)[0])
            if newline < 0:
                raise Error("Invalid header, did not find a newline at the end of the header")
            if newline < colon:
                raise Error("Invalid header, found a newline before the colon")
        if colon < 0:
            raise Error("Invalid header, did not find a colon")
        
        var jump_to = colon + 1
        self.set_key(self.b()[:jump_to])

        while len(self.b()) > jump_to and (self.b()[jump_to] == bytes(whitespace, pop=False)[0]):
            jump_to += 1
            self.set_next_line(self.next_line() - 1)
        
        self.set_subslice_len(self.subslice_len() + jump_to)
        self.set_b(self.b()[jump_to:])

        if self.next_line() >= 0:
            jump_to = self.next_line()
            self.set_next_line(-1)
        else:
            jump_to = index_byte(self.b(), bytes(nChar, pop=False)[0])
        if jump_to < 0:
            raise Error("Invalid header, did not find a newline")
        
        jump_to += 1
        self.set_value(self.b()[:jump_to])
        self.set_subslice_len(self.subslice_len() + jump_to)
        self.set_b(self.b()[jump_to:])

        if jump_to > 0 and (self.value()[jump_to-1] == bytes(rChar, pop=False)[0]):
            jump_to -= 1
        while jump_to > 0 and (self.value()[jump_to-1] == bytes(whitespace, pop=False)[0]):
            jump_to -= 1
        self.set_value(self.value()[:jump_to])
        
        return True
    
