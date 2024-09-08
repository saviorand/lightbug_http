from python import Python
from time import sleep
from lightbug_http.sys.server import SysServer
from lightbug_http.service import HTTPService
from lightbug_http.io.bytes import Bytes
from lightbug_http.http import HTTPRequest, HTTPResponse, Connection, OK
from lightbug_http.python.websocket import WebSocketServer, WebSocketHandshake, WebSocketService, send_message, receive_message


@value
struct WebSocketPrinter(WebSocketService):
    fn on_message(inout self, conn: Connection, is_binary: Bool, data: Bytes) -> None:
        ...


def main():
    var handler = WebSocketPrinter()
    var ws =  WebSocketServer(handler)
    var server = SysServer[WebSocketServer[WebSocketPrinter]](ws)
    var handshake = WebSocketHandshake()
    server.listen_and_serve("0.0.0.0:8080", handshake)

    # var handler = WebSocketUpgrade()
    # server.listen_and_serve("0.0.0.0:8080", handler)

    # var select = Python.import_module("select").select
    # var ws = websocket()
    # if ws:
    #     for _ in range(32):
    #         var res = select([ws.value()[0]],[],[],0)[0]
    #         while len(res) == 0:
    #             _ = send_message(ws.value(), "server waiting")
    #             res = select([ws.value()[0]],[],[],0)[0]
    #             print("\nwait\n")
    #             sleep(1)
    #         m = receive_message(ws.value())
    #         if m:
    #             _ = send_message(ws.value(),m.value())

    # _ = ws^
    # _ = select^
