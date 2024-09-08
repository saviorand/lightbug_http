from lightbug_http.sys.server import SysServer
from lightbug_http.python.websocket import WebSocketServer, WebSocketHandshake, WebSocketPrinter, send_message, receive_message


def main():
    var handler = WebSocketPrinter()
    var ws =  WebSocketServer(handler)
    var server = SysServer[WebSocketServer[WebSocketPrinter]](ws)
    var handshake = WebSocketHandshake()
    server.listen_and_serve("0.0.0.0:8080", handshake)
