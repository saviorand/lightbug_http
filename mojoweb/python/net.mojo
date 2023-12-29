from mojoweb.python import Modules
from mojoweb.io.bytes import Bytes
from mojoweb.net import Net, Addr, Listener
from mojoweb.http import Request, Response
from mojoweb.service import Service
from mojoweb.net import Connection

@value
struct PythonListener(Listener):
    var value: String

    fn __init__(inout self, value: String):
        self.value = value

struct PythonConnection(Connection):
    # var conn: PythonObject
    # var addr: PythonObject
    # var __py: PythonObject
    fn __init__(inout self, laddr: Addr, raddr: Addr):
        ...
        # fn __init__(inout self, conn_addr: PythonObject, py: PythonObject) raises -> None:
        #         self.conn = conn_addr[0]
        #         self.addr = conn_addr[1]
        #         self.__py = py
    fn read(self, buf: Bytes) raises -> Int:
        ...
        #     fn recieve_data(
        #     self, size: Int = 1024, encoding: StringLiteral = "utf-8"
        # ) raises -> String:
        #     let data = self.conn.recv(size).decode(encoding)
        #     return str(data)

    fn write(self, buf: Bytes) raises -> Int:
        ...
        # let response_bytes = response.to_bytes(py_builtins=self.__py)
        # _ = self.conn.sendall(response_bytes)

    fn close(self) raises:
        ...
        # _ = self.conn.close()

    fn local_addr(self) -> Addr:
        ...

    fn remote_addr(self) -> Addr:
        ...


struct PythonNet(Net):
    var __py: Modules
    var socket: PythonObject
    var host_name: PythonObject
    var host_addr: StringLiteral
    var service: Service
    var port: Int

    fn __init__(inout self, service: Service, port: Int, host_addr: StringLiteral) raises -> None:
        self.port = port
        self.host_addr = host_addr
        self.service = service
        self.__py = Modules()
        self.host_name = self.__py.socket.gethostbyname(
            self.__py.socket.gethostname(),
        )
        self.socket = None
        self.__spinup_socket()
        self.__bind_pySocket()

    fn __bind_pySocket(self) raises -> None:
        """Private funciton that binds the initialized python socket to the given host and port. this runs in __init__()"""
        _ = self.socket.bind((self.host_addr, self.port))

    fn __close_socket(self) raises -> None:
        _ = self.socket.close()

    fn __spinup_socket(inout self) raises -> None:
        self.socket = self.__py.socket.socket(
            self.__py.socket.AF_INET,
            self.__py.socket.SOCK_STREAM,
        )

    @always_inline
    fn __print_start(self) raises -> None:
        print("Server is listening on " + self.full_addr() + " ...\n")

    @always_inline
    fn __accept_connection(self) raises -> Connection:
        let conn_addr = self.socket.accept()
        return Connection(conn_addr=conn_addr, py=self.__py.builtins)

    @always_inline
    fn full_addr(self) raises -> String:
        return str(self.host_addr) 
                + "/" + self.port 

    fn listen_and_serve(self, addr: Addr) raises -> None:
        _ = self.socket.listen()
        let connection: Connection = self.__accept_connection()
        connection.print_log_connect_message()

        let st: Float64 = time.now()
        let raw_request = connection.recieve_data()
        let response: Response = self.__handle_request(
            connection=connection,
            raw_request=raw_request,
        )

        connection.send_response(response)
        connection.close()

        # go back to listening for requests
        self.serve()

    fn serve(self, listener: PythonListener) raises -> None:
        ...

    fn listen(self, addr: String) -> PythonListener:
        ...
    
    fn __handle_request(self, raw_request: String, connection: Connection) raises -> Response:
        """Private function that makes generates a Response object given a Request object."""
        if not raw_request:
            return Response.empty_error(error_str=EMPTY_REQUEST_MESSAGE)

        try:
            let request = Request(body=raw_request)
            let response: Response = self.service.func(req=request)
            return response
        except Error:
            return Response.error(error_str=str(Error))
