from collections import Dict, Optional
from python import Python, PythonObject
from lightbug_http.io.bytes import Bytes, bytes
from time import sleep
from base64 import b64encode
from lightbug_http.io.bytes import bytes_equal, bytes
from lightbug_http.http import HTTPRequest, HTTPResponse, Headers
from lightbug_http.net import Connection, default_buffer_size
from lightbug_http.sys.net import SysConnection
from lightbug_http.service import WebSocketService, UpgradeLoop

# This is a "magic" GUID (Globally Unique Identifier) string that is concatenated 
# with the value of the Sec-WebSocket-Key header in order to securely conduct the websocket handshake
# https://datatracker.ietf.org/doc/html/rfc6455#section-1.3
alias MAGIC_CONSTANT = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

alias BYTE_0_TEXT: UInt8 = 1
alias BYTE_0_NO_FRAGMENT:UInt8 = 128

alias BYTE_1_FRAME_IS_MASKED:UInt8 = 128

alias BYTE_1_SIZE_ONE_BYTE:UInt8 = 125
alias BYTE_1_SIZE_TWO_BYTES:UInt8 = 126
alias BYTE_1_SIZE_EIGHT_BYTES:UInt8 = 127


@value
struct WebSocketPrinter(WebSocketService):
    fn on_message(inout self, conn: SysConnection, is_binary: Bool, data: Bytes) -> None:
        print(String(data))


@value
struct WebSocketLoop[T: WebSocketService](UpgradeLoop):
    var handler: T
    # array goes here

    fn process_data(inout self, owned conn: SysConnection, is_binary: Bool, data: Bytes) -> None:
        # select() ...
        # frame comes in, call handle_frame()
        # if nothing, return and let the main server upgrade more websockets or handle regular requests

    fn handle_frame(inout self, owned conn: SysConnection, is_binary: Bool, data: Bytes) -> None:
        # call receive_message(), get actual data, then call user func()
        
    fn can_upgrade(self) -> Bool:
        return True
    

@value
struct WebSocketHandshake(HTTPService):
    """
    Upgrades an HTTP connection to a WebSocket connection and returns the response.
    """
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:        
        if not req.header.connection_upgrade():
            raise Error("Request headers do not contain an upgrade header")

        if not bytes_equal(req.header.upgrade(), String("websocket").as_bytes()):
            raise Error("Request upgrade do not contain an upgrade to websocket")

        if not req.headers["Sec-WebSocket-Key"]:
            raise Error("No Sec-WebSocket-Key for upgrading to websocket")

        var accept = String(req.header["Sec-WebSocket-Key"]) + MAGIC_CONSTANT
        var accept_sha1 = Python.import_module("hashlib").sha1(accept).digest()
        var accept_encoded = b64encode(accept_sha1)

        var header = Headers(101, bytes("Switching Protocols"), bytes("text/plain"))

        _ = header["Upgrade"] = bytes("websocket")
        _ = header["Connection"] = bytes("Upgrade")
        _ = header["Sec-WebSocket-Accept"] = bytes(accept_encoded)

        var response = HTTPResponse(header, bytes(""))
                
        return response

fn receive_message[
    maximum_default_capacity:Int = 1<<16
](inout ws: PythonObject, b: Bytes)->Optional[String]:
    #limit to 64kb by default!
    var res = String("")
    
    try:
        if (len(b) != 0 and b[0] != BYTE_1_FRAME_IS_MASKED) == 0:
            # if client send non-masked frame, connection must be closed
            # https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_servers#format
            ws[0].close()
            raise "Not masked"

        var byte_size_of_message_size = b^BYTE_1_FRAME_IS_MASKED
        var message_size = 0
        
        if byte_size_of_message_size <= BYTE_1_SIZE_ONE_BYTE:
            # when size is <= 125, no need for more bytes
            message_size = int(byte_size_of_message_size)
            byte_size_of_message_size = 1
        elif byte_size_of_message_size == BYTE_1_SIZE_TWO_BYTES or byte_size_of_message_size  == BYTE_1_SIZE_EIGHT_BYTES:
            if byte_size_of_message_size == BYTE_1_SIZE_TWO_BYTES:
                byte_size_of_message_size = 2
            elif byte_size_of_message_size == BYTE_1_SIZE_EIGHT_BYTES:
                byte_size_of_message_size = 8
            var bytes = UInt64(0)
            # is it always big endian ?
            # next loop is basically reading 4 or 8 bytes (big endian)
            # (theses will form a number that is the message size)
            for i in range(byte_size_of_message_size):
                bytes |= (UInt64(int(read_byte(ws)))<<((int(byte_size_of_message_size)-1-i)*8))
            message_size = int(bytes)
            if bytes&(1<<63) != 0:
                # First bit should always be 0, see step 3:
                # https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_servers#decoding_payload_length
                raise "too big"
        else:
            raise "error"
        
        if byte_size_of_message_size == 0:
            raise "message size is 0"
        
        # client->server messages should always have a mask
        # https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_servers#format
        var mask = SIMD[DType.uint8,4](
            read_byte(ws),
            read_byte(ws),
            read_byte(ws),
            read_byte(ws)
        )

        # should we always use capacity ?
        # not good if it is too big ! let's limit it with parameters
        var capacity = message_size
        if capacity > maximum_default_capacity:
            capacity = maximum_default_capacity
        var bytes_message = List[UInt8](capacity = capacity)
        for i in range(message_size):
            bytes_message.append(read_byte(ws)^mask[i&3]) 
        bytes_message.append(0)

        var message = String(bytes_message^)
        print(message_size, len(message))
        return message^
    except e:
        print(e)
    return None


fn send_message(inout ws: PythonObject, message: String)->Bool:
    #return False if an error got raised
    
    try:
        var byte_array = Python.evaluate("bytearray")
        var message_part = PythonObject(message).encode('utf-8')
        var tmp_len = UInt64(len(message_part))
        
        var first_part = byte_array(2)
        first_part[0] = int(BYTE_0_NO_FRAGMENT | BYTE_0_TEXT)
        
        var bytes_for_size = 0
        if tmp_len <= int(BYTE_1_SIZE_ONE_BYTE):
            first_part[1] = tmp_len&255
            bytes_for_size = 0
        else:
            if tmp_len <= ((1<<16)-1):
                first_part[1] = int(BYTE_1_SIZE_TWO_BYTES)
                bytes_for_size = 2
            else:
                first_part[1] = int(BYTE_1_SIZE_EIGHT_BYTES)
                bytes_for_size = 8
        
        var part_two = byte_array(bytes_for_size) #0, 4 or 8 bytes
        # When len of message need 4 or 8 bytes:
        for i in range(bytes_for_size):
            part_two[i] =  (tmp_len >> (bytes_for_size-i-1)*8)&255
        
        ws[0].send(first_part+part_two+message_part)
        return True
    except e:
        print(e)
        return False
    return False

