from python import Python
from time import sleep
from lightbug_http.sys.server import SysServer
from lightbug_http.python.websocket import WebSocketUpgrade, send_message, receive_message

def main():
    var server = SysServer()
    var handler = WebSocketUpgrade()
    server.listen_and_serve("0.0.0.0:8080", handler)

    var select = Python.import_module("select").select
    var ws = websocket()
    if ws:
        for _ in range(32):
            var res = select([ws.value()[0]],[],[],0)[0]
            while len(res) == 0:
                _ = send_message(ws.value(), "server waiting")
                res = select([ws.value()[0]],[],[],0)[0]
                print("\nwait\n")
                sleep(1)
            m = receive_message(ws.value())
            if m:
                _ = send_message(ws.value(),m.value())

    _ = ws^
    _ = select^
