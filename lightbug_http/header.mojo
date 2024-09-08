from utils import Span, StringSlice
from gojo.bufio import Reader
from lightbug_http.strings import (
    strHttp11,
    strHttp10,
    strSlash,
    strMethodGet,
    rChar,
    rChar_byte,
    nChar,
    nChar_byte,
    colonChar,
    colonChar_byte,
    whitespace,
    whitespace_byte,
    tab,
    tab_byte,
    h_byte,
    H_byte,
    c_byte,
    C_byte,
    u_byte,
    U_byte,
    t_byte,
    T_byte,
    s_byte,
    S_byte,
    to_string
)
from lightbug_http.io.bytes import Bytes, Byte, bytes_equal, bytes, index_byte, compare_case_insensitive, next_line, last_index_byte

alias statusOK = 200
alias CONTENT_TYPE_HEADER = String("content-type").as_bytes()
alias CONTENT_LENGTH_HEADER = String("content-length").as_bytes()
alias CONTENT_ENCODING_HEADER = String("content-encoding").as_bytes()
alias CONNECTION_HEADER = String("connection").as_bytes()
alias HOST_HEADER = String("host").as_bytes()
alias USER_AGENT_HEADER = String("user-agent").as_bytes()
alias CLOSE_HEADER = String("close").as_bytes()
alias TRANSFER_ENCODING_HEADER = String("transfer-encoding").as_bytes()
alias TRAILER_HEADER = String("trailer").as_bytes()
alias SERVER_HEADER = String("server").as_bytes()
alias IDENTITY_HEADER = String("identity").as_bytes()


@value
struct RequestHeader:
    var disable_normalization: Bool
    var no_http_1_1: Bool
    var __connection_close: Bool
    var __content_length: Int
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
        self.__method = Bytes()
        self.__request_uri = Bytes()
        self.proto = Bytes()
        self.__host = host.as_bytes()
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
        self.__content_type = content_type.as_bytes()
        return self

    fn set_content_type_bytes(inout self, content_type: Bytes) -> Self:
        self.__content_type = content_type
        return self

    fn content_type(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__content_type)

    fn set_host(inout self, host: String) -> Self:
        self.__host = host.as_bytes()
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        self.__host = host
        return self

    fn host(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__host)

    fn set_user_agent(inout self, user_agent: String) -> Self:
        self.__user_agent = user_agent.as_bytes()
        return self

    fn set_user_agent_bytes(inout self, user_agent: Bytes) -> Self:
        self.__user_agent = user_agent
        return self

    fn user_agent(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__user_agent)

    fn set_method(inout self, method: String) -> Self:
        self.__method = method.as_bytes()
        return self

    fn set_method_bytes(inout self, method: Bytes) -> Self:
        self.__method = method
        return self

    fn method(self) -> Span[UInt8, __lifetime_of(self)]:
        if len(self.__method) == 0:
            return Span[UInt8, __lifetime_of(self)](unsafe_ptr=strMethodGet.unsafe_ptr(), len=len(strMethodGet))
        return Span[UInt8, __lifetime_of(self)](self.__method)
    
    fn set_protocol(inout self, proto: String) -> Self:
        self.no_http_1_1 = False # hardcoded until HTTP/2 is supported
        self.proto = proto.as_bytes()
        return self

    fn set_protocol_bytes(inout self, proto: Bytes) -> Self:
        self.no_http_1_1 = False # hardcoded until HTTP/2 is supported
        self.proto = proto
        return self

    fn protocol_str(self) -> String:
        var protocol = self.protocol()
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8_ptr=protocol.unsafe_ptr(), len=len(protocol))

    fn protocol(self) -> Span[UInt8, __lifetime_of(self)]:
        if len(self.proto) == 0:
            return Span[UInt8, __lifetime_of(self)](unsafe_ptr=strHttp11.unsafe_ptr(), len=len(strHttp11))
        return Span[UInt8, __lifetime_of(self)](self.proto)
    
    fn content_length(self) -> Int:
        return self.__content_length

    fn set_content_length(inout self, content_length: Int) -> Self:
        self.__content_length = content_length
        return self

    fn set_content_length_bytes(inout self, owned content_length: Bytes) raises -> Self:
        self.__content_length = atol(to_string(content_length^))
        return self

    fn set_request_uri(inout self, request_uri: String) -> Self:
        self.__request_uri = request_uri.as_bytes()
        return self

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        self.__request_uri = request_uri
        return self

    fn request_uri(self) -> Span[UInt8, __lifetime_of(self)]:
        if len(self.__request_uri) <= 1:
            return Span[UInt8, __lifetime_of(self)](unsafe_ptr=strSlash.unsafe_ptr(), len=len(strSlash))
        return Span[UInt8, __lifetime_of(self)](self.__request_uri)
    
    fn request_uri_str(self) -> String:
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8=self.request_uri())

    fn set_transfer_encoding(inout self, transfer_encoding: String) -> Self:
        self.__transfer_encoding = transfer_encoding.as_bytes()
        return self
    
    fn set_transfer_encoding_bytes(inout self, transfer_encoding: Bytes) -> Self:
        self.__transfer_encoding = transfer_encoding
        return self
    
    fn transfer_encoding(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__transfer_encoding)

    fn set_trailer(inout self, trailer: String) -> Self:
        self.__trailer = trailer.as_bytes()
        return self

    fn set_trailer_bytes(inout self, trailer: Bytes) -> Self:
        self.__trailer = trailer
        return self
    
    fn trailer(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__trailer)
    
    fn trailer_str(self) -> String:
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8_ptr=self.__trailer.unsafe_ptr(), len=len(self.__trailer))

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
        
        var buf_result = r.peek(r.buffered())
        var buf = buf_result[0]
        var e = buf_result[1]
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
        
        var first_whitespace = index_byte(b, whitespace_byte)
        if first_whitespace <= 0:
            raise Error("Could not find HTTP request method in request line: " + to_string(b))
        
        # Method is the start of the first line up to the first whitespace
        _ = self.set_method_bytes(b[:first_whitespace])

        # TODO: I don't think this is handling the trailing \r\n correctly
        var last_whitespace = last_index_byte(b, whitespace_byte) + 1
        if last_whitespace < 0:
            raise Error("Could not find request target or HTTP version in request line: " + to_string(b))
        elif last_whitespace == 0:
            raise Error("Request URI is empty: " + to_string(b))
        var proto = b[last_whitespace:-1] # -1 to shave off trailing \r
        if len(proto) != len(strHttp11):
            raise Error("Invalid protocol, HTTP version not supported: " + to_string(proto))
        _ = self.set_protocol_bytes(proto)
        _ = self.set_request_uri_bytes(b[first_whitespace+1:last_whitespace-1]) # -1 shave off trailing \r
        
        return len(buf) - len(b_next)
       
    fn parse_headers(inout self, buf: Bytes) raises -> None:
        _ = self.set_content_length(-2)
        var s = headerScanner()
        s.set_b(buf)

        while s.next():
            if len(s.key()) > 0:
                self.parse_header(s.key(), s.value())
    
    fn parse_header(inout self, key: Bytes, value: Bytes) raises -> None:
        if index_byte(key, tab_byte) != -1:
            raise Error("Invalid header key: " + to_string(key))

        var key_first = key[0].__xor__(0x20)
        if key_first == h_byte or key_first == H_byte:
            if compare_case_insensitive(key, HOST_HEADER):
                _ = self.set_host_bytes(value)
                return
        elif key_first == u_byte or key_first == U_byte:
            if compare_case_insensitive(key, USER_AGENT_HEADER):
                _ = self.set_user_agent_bytes(value)
                return
        elif key_first == c_byte or key_first == C_byte:
            if compare_case_insensitive(key, CONTENT_TYPE_HEADER):
                _ = self.set_content_type_bytes(value)
                return
            if compare_case_insensitive(key, CONTENT_LENGTH_HEADER):
                if self.content_length() != -1:
                    _ = self.set_content_length_bytes(value)
                return
            if compare_case_insensitive(key, CONNECTION_HEADER):
                if compare_case_insensitive(value, CLOSE_HEADER):
                    _ = self.set_connection_close()
                else:
                    _ = self.reset_connection_close()
                return
        elif key_first == t_byte or key_first == T_byte:
            if compare_case_insensitive(key, TRANSFER_ENCODING_HEADER):
                _ = self.set_transfer_encoding_bytes(value)
                return
            if compare_case_insensitive(key, TRAILER_HEADER):
                _ = self.set_trailer_bytes(value)
                return
        if self.content_length() < 0:
            _ = self.set_content_length(0)
        return

    fn read_raw_headers(inout self, buf: Bytes) raises -> Int:
        var n = index_byte(buf, nChar_byte)
        if n == -1:
            self.raw_headers = self.raw_headers[:0]
            raise Error("Failed to find a newline in headers")
        
        if n == 0 or (n == 1 and (buf[0] == rChar_byte)):
            # empty line -> end of headers
            return n + 1
        
        n += 1
        var b = buf
        var m = n
        while True:
            b = b[m:]
            m = index_byte(b, nChar_byte)
            if m == -1:
                raise Error("Failed to find a newline in headers")
            m += 1
            n += m
            if m == 2 and (b[0] == rChar_byte) or m == 1:
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
        self.__content_type = content_type
        self.__content_encoding = content_encoding
        self.__server = server
        self.__trailer = trailer
        self.raw_headers = Bytes()
    
    fn set_status_code_bytes(inout self, owned code: Bytes) raises -> Self:
        self.__status_code = atol(to_string(code^))
        return self

    fn set_status_code(inout self, code: Int) -> Self:
        self.__status_code = code
        return self

    fn status_code(self) -> Int:
        if self.__status_code == 0:
            return statusOK
        return self.__status_code

    fn set_status_message_bytes(inout self, message: Bytes) -> Self:
        self.__status_message = message
        return self
    
    fn status_message(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__status_message)
    
    fn status_message_str(self) -> String:
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8_ptr=self.__status_message.unsafe_ptr(), len=len(self.__status_message))

    fn content_type(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__content_type)

    fn set_content_type(inout self, content_type: String) -> Self:
        self.__content_type = content_type.as_bytes()
        return self

    fn set_content_type_bytes(inout self, content_type: Bytes) -> Self:
        self.__content_type = content_type
        return self

    fn content_encoding(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__content_encoding)

    fn set_content_encoding(inout self, content_encoding: String) -> Self:
        self.__content_encoding = content_encoding.as_bytes()
        return self

    fn set_content_encoding_bytes(inout self, content_encoding: Bytes) -> Self:
        self.__content_encoding = content_encoding
        return self
    
    fn content_length(self) -> Int:
        return self.__content_length
    
    fn set_content_length(inout self, content_length: Int) -> Self:
        self.__content_length = content_length
        return self
    
    fn set_content_length_bytes(inout self, owned content_length: Bytes) raises -> Self:
        self.__content_length = atol(to_string(content_length^))
        return self

    fn server(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__server)

    fn set_server(inout self, server: String) -> Self:
        self.__server = server.as_bytes()
        return self

    fn set_server_bytes(inout self, server: Bytes) -> Self:
        self.__server = server
        return self

    fn set_protocol(inout self, proto: String) -> Self:
        self.no_http_1_1 = False # hardcoded until HTTP/2 is supported
        self.__protocol = proto.as_bytes()
        return self
    
    fn set_protocol_bytes(inout self, protocol: Bytes) -> Self:
        self.no_http_1_1 = False # hardcoded until HTTP/2 is supported
        self.__protocol = protocol
        return self

    fn protocol_str(self) -> String:
        var protocol = self.protocol()
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8_ptr=protocol.unsafe_ptr(), len=len(protocol))
    
    fn protocol(self) -> Span[UInt8, __lifetime_of(self)]:
        if len(self.__protocol) == 0:
            return Span[UInt8, __lifetime_of(self)](unsafe_ptr=strHttp11.unsafe_ptr(), len=len(strHttp11))
        return Span[UInt8, __lifetime_of(self)](self.__protocol)

    fn set_trailer(inout self, trailer: String) -> Self:
        self.__trailer = trailer.as_bytes()
        return self

    fn set_trailer_bytes(inout self, trailer: Bytes) -> Self:
        self.__trailer = trailer
        return self
    
    fn trailer(self) -> Span[UInt8, __lifetime_of(self)]:
        return Span[UInt8, __lifetime_of(self)](self.__trailer)

    fn trailer_str(self) -> String:
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8_ptr=self.__trailer.unsafe_ptr(), len=len(self.__trailer))
    
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
            raise Error("Failed to read first byte from response header")
        
        var buf_result = r.peek(r.buffered())
        var buf = buf_result[0]
        var e = buf_result[1]
        
        if e:
            raise Error("Failed to read response header: " + e.__str__())
        if len(buf) == 0:
            raise Error("Failed to read response header, empty buffer")

        var end_of_first_line = self.parse_first_line(buf)
        # TODO: Use Span instead of list here
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
        
        var first_whitespace = index_byte(b, whitespace_byte)
        if first_whitespace <= 0:
            raise Error("Could not find HTTP version in response line: " + to_string(b^))
        
        # Up to the first whitespace is the protocol
        _ = self.set_protocol_bytes(b[:first_whitespace])
        
        # From first whitespace + 1 to first whitespace + 4 is the status code (status code is always 3 digits)
        var end_of_status_code = first_whitespace + 4
        _ = self.set_status_code_bytes(b[first_whitespace + 1 : end_of_status_code])

        # Status message is from the end of the status code + 1 (next whitespace)
        # to the end of the line -1 to shave off the trailing \r.
        var status_text = b[end_of_status_code+1:-1]
        if len(status_text) > 1:
            _ = self.set_status_message_bytes(status_text)   

        return len(buf) - len(b_next)

    fn parse_headers(inout self, buf: Bytes) raises -> None:
        _ = self.set_content_length(-2)
        var s = headerScanner()
        s.set_b(buf)

        while s.next():
            if len(s.key()) > 0:
                self.parse_header(s.key(), s.value())
    
    fn parse_header(inout self, owned key: Bytes, owned value: Bytes) raises -> None:
        if index_byte(key, tab_byte) != -1:
            raise Error("Invalid header key: " + to_string(key^))
        
        var key_first = key[0].__xor__(0x20)
        if key_first == c_byte or key_first == C_byte:
            if compare_case_insensitive(key, CONTENT_TYPE_HEADER):
                _ = self.set_content_type_bytes(value)
                return
            if compare_case_insensitive(key, CONTENT_ENCODING_HEADER):
                _ = self.set_content_encoding_bytes(value)
                return
            if compare_case_insensitive(key, CONTENT_LENGTH_HEADER):
                if self.content_length() != -1:
                    _ = self.set_content_length(atol(to_string(value^)))
                return
            if compare_case_insensitive(key, CONNECTION_HEADER):
                if compare_case_insensitive(value, CLOSE_HEADER):
                    _ = self.set_connection_close()
                else:
                    _ = self.reset_connection_close()
                return
        elif key_first == s_byte or key_first == S_byte:
            if compare_case_insensitive(key, SERVER_HEADER):
                _ = self.set_server_bytes(value)
                return
        elif key_first == t_byte or key_first == T_byte:
            if compare_case_insensitive(key, TRANSFER_ENCODING_HEADER):
                if not compare_case_insensitive(value, IDENTITY_HEADER):
                    _ = self.set_content_length(-1)
                return
            if compare_case_insensitive(key, TRAILER_HEADER):
                _ = self.set_trailer_bytes(value)
    
    # TODO: Can probably use a non-owning Span here, instead of slicing a new List to pass to this function.
    fn read_raw_headers(inout self, owned buf: Bytes) raises -> Int:
        var n = index_byte(buf, nChar_byte)
        
        if n == -1:
            self.raw_headers = self.raw_headers[:0]
            raise Error("Failed to find a newline in headers")
        
        if n == 0 or (n == 1 and (buf[0] == rChar_byte)):
            # empty line -> end of headers
            return n + 1
        
        n += 1
        var m = n
        while True:
            buf = buf[m:]
            m = index_byte(buf, nChar_byte)
            if m == -1:
                raise Error("Failed to find a newline in headers")
            m += 1
            n += m
            if m == 2 and (buf[0] == rChar_byte) or m == 1:
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
        
        var b_len = len(self.__b)

        if b_len >= 2 and (self.__b[0] == rChar_byte) and (self.__b[1] == nChar_byte):
            self.set_b(self.__b[2:])
            self.set_subslice_len(2)
            return False
        
        if b_len >= 1 and (self.__b[0] == nChar_byte):
            self.set_b(self.__b[1:])
            self.set_subslice_len(self.subslice_len() + 1)
            return False
        
        var colon: Int
        if self.next_colon() >= 0:
            colon = self.next_colon()
            self.set_next_colon(-1)
        else:
            colon = index_byte(self.__b, colonChar_byte)
            var newline = index_byte(self.__b, nChar_byte)
            if newline < 0:
                raise Error("Invalid header, did not find a newline at the end of the header")
            if newline < colon:
                raise Error("Invalid header, found a newline before the colon")
        if colon < 0:
            raise Error("Invalid header, did not find a colon")
        
        var jump_to = colon + 1
        self.set_key(self.__b[:colon])

        while len(self.__b) > jump_to and (self.__b[jump_to] == whitespace_byte):
            jump_to += 1
            self.set_next_line(self.next_line() - 1)
        
        self.set_subslice_len(self.subslice_len() + jump_to)
        self.set_b(self.__b[jump_to:])

        if self.next_line() >= 0:
            jump_to = self.next_line()
            self.set_next_line(-1)
        else:
            jump_to = index_byte(self.__b, nChar_byte)
        if jump_to < 0:
            raise Error("Invalid header, did not find a newline")
        
        jump_to += 1
        self.set_value(self.__b[:jump_to-2]) # -2 to exclude the \r\n
        self.set_subslice_len(self.subslice_len() + jump_to)
        self.set_b(self.__b[jump_to:])

        if jump_to > 0 and (self.value()[jump_to-1] == rChar_byte):
            jump_to -= 1
        while jump_to > 0 and (self.value()[jump_to-1] == whitespace_byte):
            jump_to -= 1
        self.set_value(self.value()[:jump_to])
        
        return True
    
