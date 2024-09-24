from lightbug_http.sys.server import SysServer
from lightbug_http.websocket import WebSocketLoop, WebSocketHandshake, WebSocketPrinter, send_message, receive_message


def main():
    var handler = WebSocketPrinter()
    var ws =  WebSocketLoop(handler)
    var server = SysServer[WebSocketLoop[WebSocketPrinter]](ws)
    var handshake = WebSocketHandshake()
    server.listen_and_serve("0.0.0.0:8080", handshake)
