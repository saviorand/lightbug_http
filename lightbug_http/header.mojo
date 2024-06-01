from lightbug_http.strings import (
    strHttp11,
    strHttp10,
    strSlash,
    strMethodGet,
    rChar,
    nChar,
)
from lightbug_http.io.bytes import Bytes, Byte, BytesView, bytes_equal

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
        self.__host = host._buffer
        self.__content_type = Bytes()
        self.__user_agent = Bytes()
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
        self.raw_headers = raw_headers
        self.__trailer = trailer

    fn set_content_type(inout self, content_type: String) -> Self:
        self.__content_type = content_type._buffer
        return self

    fn set_content_type_bytes(inout self, content_type: Bytes) -> Self:
        self.__content_type = content_type
        return self

    fn content_type(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__content_type.unsafe_ptr(), len=self[].__content_type.size)

    fn set_host(inout self, host: String) -> Self:
        self.__host = host._buffer
        return self

    fn set_host_bytes(inout self, host: Bytes) -> Self:
        self.__host = host
        return self

    fn host(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__host.unsafe_ptr(), len=self[].__host.size)

    fn set_user_agent(inout self, user_agent: String) -> Self:
        self.__user_agent = user_agent._buffer
        return self

    fn set_user_agent_bytes(inout self, user_agent: Bytes) -> Self:
        self.__user_agent = user_agent
        return self

    fn user_agent(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__user_agent.unsafe_ptr(), len=self[].__user_agent.size)

    fn set_method(inout self, method: String) -> Self:
        self.__method = method._buffer
        return self

    fn set_method_bytes(inout self, method: Bytes) -> Self:
        self.__method = method
        return self

    fn method(self: Reference[Self]) -> BytesView:
        if len(self[].__method) == 0:
            return strMethodGet.as_bytes_slice()
        return BytesView(unsafe_ptr=self[].__method.unsafe_ptr(), len=self[].__method.size)
    
    fn set_protocol(inout self, proto: String) -> Self:
        self.no_http_1_1 = not proto.__eq__(strHttp11)
        self.proto = proto._buffer
        return self

    fn set_protocol_bytes(inout self, proto: Bytes) -> Self:
        self.no_http_1_1 = not bytes_equal(proto, strHttp11.as_bytes_slice())
        self.proto = proto
        return self

    fn protocol(self: Reference[Self]) -> BytesView:
        if len(self[].proto) == 0:
            return strHttp11.as_bytes_slice()
        return BytesView(unsafe_ptr=self[].proto.unsafe_ptr(), len=self[].proto.size)
    
    fn content_length(self) -> Int:
        return self.__content_length

    fn set_content_length(inout self, content_length: Int) -> Self:
        self.__content_length = content_length
        return self

    fn set_content_length_bytes(inout self, content_length: Bytes) -> Self:
        self.__content_length_bytes = content_length
        return self

    fn set_request_uri(inout self, request_uri: String) -> Self:
        self.__request_uri = request_uri.as_bytes()
        return self

    fn set_request_uri_bytes(inout self, request_uri: Bytes) -> Self:
        self.__request_uri = request_uri
        return self

    fn request_uri(self: Reference[Self]) -> BytesView:
        if len(self[].__request_uri) == 0:
            return strSlash.as_bytes_slice()
        return BytesView(unsafe_ptr=self[].__request_uri.unsafe_ptr(), len=self[].__request_uri.size)

    fn set_trailer(inout self, trailer: String) -> Self:
        self.__trailer = trailer._buffer
        return self

    fn set_trailer_bytes(inout self, trailer: Bytes) -> Self:
        self.__trailer = trailer
        return self
    
    fn trailer(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__trailer.unsafe_ptr(), len=self[].__trailer.size)

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

    fn parse(inout self, request_line: String) raises -> None:
        var headers = self.raw_headers

        var n = request_line.find(" ")
        if n <= 0:
            raise Error("Cannot find HTTP request method in the request")

        var method = request_line[:n]
        var rest_of_request_line = request_line[n + 1 :]

        # Defaults to HTTP/1.1
        var proto_str = String(strHttp11)

        # Parse requestURI
        n = rest_of_request_line.rfind(" ")
        if n < 0:
            n = len(rest_of_request_line)
        elif n == 0:
            raise Error("Request URI cannot be empty")
        else:
            var proto = rest_of_request_line[n + 1 :]
            if proto != strHttp11:
                proto_str = proto

        var request_uri = rest_of_request_line[:n + 1]
        
        _ = self.set_method(method)

        if len(proto_str) != 8:
            raise Error("Invalid protocol")

        _ = self.set_protocol(proto_str)
        _ = self.set_request_uri(request_uri)

        # Now process the rest of the headers
        _ = self.set_content_length(-2)

        var s = headerScanner()
        s.b = headers
        s.disable_normalization = self.disable_normalization

        while s.next():
            # The below is based on the code from Golang's FastHTTP library
            if len(s.key) > 0:
                # Spaces between the header key and colon are not allowed.
                # See RFC 7230, Section 3.2.4.
                if s.key.find(" ") != -1 or s.key.find("\t") != -1:
                    raise Error("Invalid header key")

                if s.key[0] == "h" or s.key[0] == "H":
                    if s.key.lower() == "host":
                        _ = self.set_host(s.value)
                        continue
                elif s.key[0] == "u" or s.key[0] == "U":
                    if s.key.lower() == "user-agent":
                        _ = self.set_user_agent(s.value)
                        continue
                elif s.key[0] == "c" or s.key[0] == "C":
                    if s.key.lower() == "content-type":
                        _ = self.set_content_type(s.value)
                        continue
                    if s.key.lower() == "content-length":
                        if self.content_length() != -1:
                            var content_length = s.value
                            _ = self.set_content_length(atol(content_length))
                            _ = self.set_content_length_bytes(content_length._buffer)
                        continue
                    if s.key.lower() == "connection":
                        if s.value == "close":
                            _ = self.set_connection_close()
                        else:
                            _ = self.reset_connection_close()
                            # _ = self.appendargbytes(s.key, s.value)
                        continue
                elif s.key[0] == "t" or s.key[0] == "T":
                    if s.key.lower() == "transfer-encoding":
                        if s.value != "identity":
                            _ = self.set_content_length(-1)
                            # _ = self.setargbytes(s.key, strChunked)
                        continue
                    if s.key.lower() == "trailer":
                        _ = self.set_trailer(s.value)

                # close connection for non-http/1.1 request unless 'Connection: keep-alive' is set.
                # if self.no_http_1_1 and not self.__connection_close:
                # self.__connection_close = not has_header_value(v, strKeepAlive)


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

    fn status_message(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__status_message.unsafe_ptr(), len=self[].__status_message.size)

    fn content_type(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__content_type.unsafe_ptr(), len=self[].__content_type.size)

    fn set_content_type(inout self, content_type: String) -> Self:
        self.__content_type = content_type._buffer
        return self

    fn set_content_type_bytes(inout self, content_type: Bytes) -> Self:
        self.__content_type = content_type
        return self

    fn content_encoding(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__content_encoding.unsafe_ptr(), len=self[].__content_encoding.size)

    fn set_content_encoding(inout self, content_encoding: String) -> Self:
        self.__content_encoding = content_encoding._buffer
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

    fn server(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__server.unsafe_ptr(), len=self[].__server.size)

    fn set_server(inout self, server: String) -> Self:
        self.__server = server._buffer
        return self

    fn set_server_bytes(inout self, server: Bytes) -> Self:
        self.__server = server
        return self

    fn set_protocol(inout self, protocol: Bytes) -> Self:
        self.__protocol = protocol
        return self

    fn protocol(self: Reference[Self]) -> BytesView:
        if len(self[].__protocol) == 0:
            return strHttp11.as_bytes_slice()
        return BytesView(unsafe_ptr=self[].__protocol.unsafe_ptr(), len=self[].__protocol.size)

    fn set_trailer(inout self, trailer: String) -> Self:
        self.__trailer = trailer._buffer
        return self

    fn set_trailer_bytes(inout self, trailer: Bytes) -> Self:
        self.__trailer = trailer
        return self
    
    fn trailer(self: Reference[Self]) -> BytesView:
        return BytesView(unsafe_ptr=self[].__trailer.unsafe_ptr(), len=self[].__trailer.size)

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

    fn parse(inout self, first_line: String) raises -> None:
        var headers = self.raw_headers

        # Defaults to HTTP/1.1
        var proto_str = String(strHttp11)

        var n = first_line.find(" ")
        
        var proto = first_line[:n]
        if proto != strHttp11:
            proto_str = proto
        _ = self.set_protocol(proto_str._buffer)

        var rest_of_response_line = first_line[n + 1 :]

        var status_code = atol(rest_of_response_line[:3])
        _ = self.set_status_code(status_code)

        var message = rest_of_response_line[4:]
        if len(message) > 1:
            _ = self.set_status_message(message._buffer)
        
        _ = self.set_content_length(-2)

        var s = headerScanner()
        s.b = headers
        s.disable_normalization = self.disable_normalization

        while s.next():
            if len(s.key) > 0:
                # Spaces between header key and colon not allowed (RFC 7230, 3.2.4)
                if s.key.find(" ") != -1 or s.key.find("\t") != -1:
                    raise Error("Invalid header key")
                elif s.key[0] == "c" or s.key[0] == "C":
                    if s.key.lower() == "content-type":
                        _ = self.set_content_type(s.value)
                        continue
                    if s.key.lower() == "content-encoding":
                        _ = self.set_content_encoding(s.value)
                        continue
                    if s.key.lower() == "content-length":
                        if self.content_length() != -1:
                            var content_length = s.value
                            _ = self.set_content_length(atol(content_length))
                            _ = self.set_content_length_bytes(content_length._buffer)
                        continue
                    if s.key.lower() == "connection":
                        if s.value == "close":
                            _ = self.set_connection_close()
                        else:
                            _ = self.reset_connection_close()
                        continue
                elif s.key[0] == "s" or s.key[0] == "S":
                    if s.key.lower() == "server":
                        _ = self.set_server(s.value)
                        continue
                elif s.key[0] == "t" or s.key[0] == "T":
                    if s.key.lower() == "transfer-encoding":
                        if s.value != "identity":
                            _ = self.set_content_length(-1)
                        continue
                    if s.key.lower() == "trailer":
                        _ = self.set_trailer(s.value)


struct headerScanner:
    var b: String  # string for now until we have a better way to subset Bytes
    var key: String
    var value: String
    var err: Error
    var subslice_len: Int
    var disable_normalization: Bool
    var next_colon: Int
    var next_line: Int
    var initialized: Bool

    fn __init__(inout self) -> None:
        self.b = ""
        self.key = ""
        self.value = ""
        self.err = Error()
        self.subslice_len = 0
        self.disable_normalization = False
        self.next_colon = 0
        self.next_line = 0
        self.initialized = False
    
    fn next(inout self) -> Bool:
        if not self.initialized:
            self.initialized = True

        if self.b.startswith('\r\n\r\n'):
            self.b = self.b[2:]
            return False

        if self.b.startswith('\r\n'):
            self.b = self.b[1:]
            return False

        var n = self.b.find(':')
        var x = self.b.find('\r\n')
        if x != -1 and x < n:
            return False

        if n == -1:
            # If we don't find a colon, assume we have reached the end
            return False

        self.key = self.b[:n].strip()
        self.b = self.b[n+1:].strip()

        x = self.b.find('\r\n')
        if x == -1:
            if len(self.b) == 0:
                return False
            self.value = self.b.strip()  
            self.b = ''
        else:
            self.value = self.b[:x].strip()
            self.b = self.b[x+1:]
        
        return True
    
