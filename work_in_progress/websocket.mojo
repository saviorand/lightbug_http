from collections import Dict, Optional
from python import Python, PythonObject
from time import sleep

fn websocket[
    host: StringLiteral = "127.0.0.1", 
    port: Int = 8000
]()->Optional[PythonObject]:
    """
    1. Open server
    2. Upgrade first HTTP client to websocket
    3. Close server 
    4. return the websocket.
    """

    var client = PythonObject(None)
    try:
        var py_socket = Python.import_module("socket")
        var py_base64 = Python.import_module("base64")
        var py_sha1 = Python.import_module("hashlib").sha1
        var server = py_socket.socket(py_socket.AF_INET, py_socket.SOCK_STREAM)
        server.setsockopt(py_socket.SOL_SOCKET, py_socket.SO_REUSEADDR, 1)
        server.bind((host, port))
        server.listen(1)
        print("ws://"+str(host)+":"+str(port))
        
        client = server.accept()
        # Only localhost !
        if client[1][0] != '127.0.0.1': 
            print("Exit, request from: "+str(client[1][0]))
            client.close()
            server.close()
            return None
        
        # Close server
        server.close()
        
        # Get request
        var request = client[0].recv(1024).decode()
        var request_header = Dict[String,String]()
        print(request.__repr__())
        
        var end_header = int(request.find("\r\n\r\n"))
        if end_header == -1:
            raise "end_header == -1, no \\r\\n\\r\\n"
        var request_split = str(request)[:end_header].split("\r\n")
        if len(request_split) == 0: 
            raise "error: len(request_split) == 0"
        if request_split[0] != "GET / HTTP/1.1":
            raise "request_split[0] not GET / HTTP/1.1"
        _ = request_split.pop(0)

        if len(request_split) == 0: 
            raise "error: no headers"
        
        for e in request_split: 
            var header_pos = e[].find(":")
            if header_pos == -1:
                raise "header_pos == -1"
            if len(e[]) == header_pos+2:
                raise "len(e[]) == header_pos+2"
            var k = e[][:header_pos]
            var v = e[][header_pos+2:]
            request_header[k^]=v^
        
        for h in request_header:
            print(h[], request_header[h[]])
        
        #Upgrade to websocket
        if "Upgrade" not in request_header:
            raise "Not upgrade to websocket"

        if request_header["Upgrade"] != "websocket":
            raise "Not an upgrade to websocket"
        
        if "Sec-WebSocket-Key" not in request_header:
            raise "No Sec-WebSocket-Key for upgrading to websocket"
        
        var accept = PythonObject(request_header["Sec-WebSocket-Key"])
        accept += PythonObject("258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
        # it is a "magic" constant, see:
        # https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_servers#server_handshake_response
        accept = accept.encode()
        accept = py_base64.b64encode(py_sha1(accept).digest())
        
        var response = String("HTTP/1.1 101 Switching Protocols\r\n")
        response += "Upgrade: websocket\r\n"
        response += "Connection: Upgrade\r\n"
        response += "Sec-WebSocket-Accept: "
        response += str(accept.decode("utf-8")) 
        response += String("\r\n\r\n")
        
        print(response)
        
        client[0].send(PythonObject(response).encode())
        return client^

    except e:
        print(e)
    
    return None

def main():
    var select = Python.import_module("select").select
    var ws = websocket()
    if ws:
        for i in range(32):
            var res = select([ws.value()[0]],[],[],0)[0]
            while len(res) == 0:
                send_message(ws.value(), "server waiting")
                res = select([ws.value()[0]],[],[],0)[0]
                print("\nwait\n")
                sleep(1)
            m = receive_message(ws.value())
            if m:
                print(m.value())
                send_message(ws.value(),m.value())

    _ = ws^
    _ = select^

fn read_byte(inout ws: PythonObject)raises->UInt8:
    return UInt8(int(ws[0].recv(1)[0]))

fn receive_message[
    maximum_default_capacity:Int = 1<<16
](inout ws: PythonObject)->Optional[String]:
    #limit to 64kb by default!
    var res = String("")
    
    try:
        _ = read_byte(ws) #not implemented yet
        var b = read_byte(ws)
        if not b&128:
            raise "Not masked"
        var byte_size_of_message_size = b^128
        var message_size = 0
        
        if byte_size_of_message_size <= 125:
            message_size = int(byte_size_of_message_size)
            byte_size_of_message_size = 1
        elif byte_size_of_message_size == 126 or byte_size_of_message_size  == 127:
            if byte_size_of_message_size == 126:
                byte_size_of_message_size = 2
            elif byte_size_of_message_size == 127:
                byte_size_of_message_size = 8
            var bytes = UInt64(0)
            # is it always big endian ?
            for i in range(byte_size_of_message_size):
                bytes |= (UInt64(int(read_byte(ws)))<<((int(byte_size_of_message_size)-1-i)*8))
            message_size = int(bytes)
            if bytes>>56 != 0:
                raise "too big"
        else:
            raise "error"
        
        if byte_size_of_message_size == 0:
            raise "message size is 0"
        
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
        #128 is for sending all at once (no fragment)
        #1 is for text 
        first_part[0] = 128 | 1 
        var bytes_for_size = 0
        if tmp_len <= 125:
            first_part[1] = tmp_len&255
            bytes_for_size = 0
        else:
            if tmp_len <= ((1<<16)-1):
                first_part[1] = 126
                bytes_for_size = 2
            else:
                first_part[1] = 127
                bytes_for_size = 8
        
        var part_two = byte_array(bytes_for_size)
        for i in range(bytes_for_size):
            part_two[i] =  (tmp_len >> (bytes_for_size-i-1)*8)&255
        
        ws[0].send(first_part+part_two+message_part)
        return True
    except e:
        print(e)
        return False
    return False

