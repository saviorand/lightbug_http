from lightbug_http.sys.server import SysServer
from lightbug_http.service import TechEmpowerRouter

def main():
    try:
        var server = SysServer(tcp_keep_alive=True)
        var handler = TechEmpowerRouter()
        server.listen_and_serve("0.0.0.0:8080", handler)
    except e:
        print("Error starting server: " + e.__str__())
        return