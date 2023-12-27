trait Addr:
    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...


@value
struct TCPAddr:
    var ip: String
    var port: Int

    fn __init__(inout self):
        # TODO: do these defaults make sense?
        self.ip = "127.0.0.1"
        self.port = 80

    fn __init__(inout self, ip: String, port: Int):
        self.ip = ip
        self.port = port

    fn network(self) -> String:
        return "tcp"

    fn string(self) -> String:
        return self.ip + ":" + self.port
