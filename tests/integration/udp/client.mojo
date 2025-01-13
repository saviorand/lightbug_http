from lightbug_http.net import dial_udp, UDPAddr
from utils import StringSlice


fn main() raises:
    # Create UDP Connection
    alias host = "127.0.0.1"
    alias port = 12000
    var udp = dial_udp(host, port)

    # Send 10 test messages
    for i in range(10):
        _ = udp.write_to(str(i).as_bytes(), host, port)

        try:
            response, _, _ = udp.read_from(16)
            print("Response received:", StringSlice(unsafe_from_utf8=response))
        except e:
            if str(e) != str("EOF"):
                raise e
