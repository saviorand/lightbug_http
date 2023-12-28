struct Connection:
    var conn: PythonObject
    var addr: PythonObject
    var __py: PythonObject

    fn __init__(inout self, conn_addr: PythonObject, py: PythonObject) raises -> None:
        self.conn = conn_addr[0]
        self.addr = conn_addr[1]
        self.__py = py

    fn recieve_data(
        self, size: Int = 1024, encoding: StringLiteral = "utf-8"
    ) raises -> String:
        let data = self.conn.recv(size).decode(encoding)
        return str(data)

    fn send_response(self, response: Response) raises -> None:
        let response_bytes = response.to_bytes(py_builtins=self.__py)
        _ = self.conn.sendall(response_bytes)

    fn close(self) raises -> None:
        _ = self.conn.close()

    fn log_connect_message(self) raises -> String:
        let host_name = str(self.addr[0])
        let port = str(self.addr[1])
        return "Connection from " + host_name + "/" + port

    fn print_log_connect_message(self) raises -> None:
        print(self.log_connect_message())
