from python import Python, PythonObject
import time
from mojoweb.service import TCPService
from mojoweb.request.request import TCPRequest
from mojoweb.response.response import TCPResponse
from mojoweb.request.connection import TCPConnection

trait Server:
    pass

struct PyModules:
    var py: PythonObject
    var socket: PythonObject

    fn __init__(inout self) raises -> None:
        self.py = self.__load_builtins_module()
        self.socket = self.__load_socket_module()

    @staticmethod
    fn __load_socket_module() raises -> PythonObject:
        let socket = Python.import_module("socket")
        return socket

    @staticmethod
    fn __load_builtins_module() raises -> PythonObject:
        let builtins = Python.import_module("builtins")
        return builtins

struct ServerStats:
    var total_requests: Int
    var total_execution_time: Float64
    var average_execution_time: Float64
    var most_recent_et: Float64

    fn __init__(inout self) -> None:
        self.total_requests = 0
        self.total_execution_time = 0
        self.average_execution_time = 0
        self.most_recent_et = 0

    fn increment_reqs(inout self) -> None:
        self.total_requests += 1

    fn update_total_et(inout self, et: Float64) -> None:
        self.total_execution_time += et

    fn update_average_et(inout self) -> None:
        self.average_execution_time = self.total_execution_time / self.total_requests

    fn update(inout self, execution_time: Float64) -> None:
        self.increment_reqs()
        self.update_total_et(et=execution_time)
        self.update_average_et()
        self.most_recent_et = execution_time

    fn avg_seconds(self) -> Float64:
        return self.average_execution_time / 1e9

    fn tot_seconds(self) -> Float64:
        return self.total_execution_time / 1e9

    fn most_recent_secs(self) -> Float64:
        return self.most_recent_et / 1e9

    fn most_recent_ms(self) -> Float64:
        return self.most_recent_et

struct TCPLite[S: TCPService](Server):
    """'Lite' wrapper for the python socket library with HTTP protocol."""
    var __modules: PyModules
    var __py_socket: PythonObject
    var host_name: PythonObject
    var host_addr: StringLiteral
    var service: S
    var port: Int
    var stats: ServerStats

    fn __init__(inout self, service: S, port: Int, host_addr: StringLiteral) raises -> None:
        self.port = port
        self.host_addr = host_addr
        self.service = service
        self.stats = ServerStats()
        self.__modules = PyModules()
        self.host_name = self.__modules.socket.gethostbyname(
            self.__modules.socket.gethostname(),
        )
        self.__py_socket = None
        self.__spinup_socket()
        self.__bind_pySocket()

    fn __bind_pySocket(self) raises -> None:
        """Private funciton that binds the initialized python socket to the given host and port. this runs in __init__()"""
        _ = self.__py_socket.bind((self.host_addr, self.port))

    fn __close_socket(self) raises -> None:
        _ = self.__py_socket.close()

    fn __spinup_socket(inout self) raises -> None:
        self.__py_socket = self.__modules.socket.socket(
            self.__modules.socket.AF_INET,
            self.__modules.socket.SOCK_STREAM,
        )

    @always_inline
    fn __print_start(self) raises -> None:
        let fire = "🔥🔥🔥"
        print(fire + " FireApi TCPLite Service " + fire + "\n")
        print("listening @ " + self.full_addr() + " ...\n")

    @always_inline
    fn __accept_connection(self) raises -> TCPConnection:
        let conn_addr = self.__py_socket.accept()
        return TCPConnection(conn_addr=conn_addr, py=self.__modules.py)

    @always_inline
    fn full_addr(self) raises -> String:
        return str(self.host_addr) 
                + "/" + self.port 
        
    @always_inline
    fn __update_metrics(inout self, et: Float64) -> None:
        """Private function that updates the metrics that enhance logging output."""
        self.stats.update(execution_time=et)

    fn serve(inout self) raises -> None:
        if not self.stats.total_requests:
            self.__print_start()

        _ = self.__py_socket.listen()
        let connection: TCPConnection = self.__accept_connection()
        connection.print_log_connect_message()

        let st: Float64 = time.now()
        let raw_request = connection.receive_data()
        let response: TCPResponse = self.__handle_request(
            connection=connection, raw_request=raw_request,
        )

        connection.send_response[TCPResponse](response)
        connection.close()

        # print additional response information
        let execution_time: Float64 = (time.now() - st)
        self.__update_metrics(et=execution_time)
        response.print_log_message(
            execution_time=self.stats.most_recent_secs(), 
            raw_request=raw_request,
            symbol="🔥" if (execution_time <= self.stats.average_execution_time) else "🥶"
        )

        # go back to listening for requests 
        self.serve()

    fn __handle_request(self, raw_request: String, connection: TCPConnection) raises -> TCPResponse:
        """Private function that makes generates a Response object given a Request object."""
        if not raw_request:
            return TCPResponse.empty_error(error_str="Something went wrong.")

        try:
            let request = TCPRequest(body=raw_request)
            let response: TCPResponse = self.service.func(req=request)
            return response
        except Error:
            return TCPResponse.error(error_str=str(Error))