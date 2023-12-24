alias Bytes = DynamicVector[Int8]

# Time in nanoseconds
alias Duration = Int


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return String(a) == String(b)


trait Addr:
    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...


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
