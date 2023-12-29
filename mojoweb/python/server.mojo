from mojoweb.server import Server, DefaultConcurrency
from mojoweb.net import Listener
from mojoweb.python.net import PythonTCPListener
from mojoweb.handler import RequestHandler
from mojoweb.io.sync import Duration
from mojoweb.error import ErrorHandler


struct PythonServer(Server):
    var handler: RequestHandler
    var error_handler: ErrorHandler
    # var __py: Modules
    # var socket: PythonObject
    # var host_name: PythonObject
    # var host_addr: StringLiteral
    # var service: Service
    # var port: Int

    # TODO: header_received
    # TODO: continue_handler

    var name: String
    var max_concurrent_connections: Int
    var read_buffer_size: Int
    var write_buffer_size: Int

    var read_timeout: Duration
    var write_timeout: Duration
    var idle_timeout: Duration

    var max_connections_per_ip: Int
    var max_requests_per_connection: Int
    var max_keep_alive_duration: Duration
    var max_idle_worker_duration: Duration
    var tcp_keep_alive_period: Duration

    var max_request_body_size: Int
    var disable_keep_alive: Bool
    var tcp_keep_alive: Bool
    var reduce_memory_usage: Bool

    var get_only: Bool
    var disable_pre_parse_multipart_form: Bool
    var disable_header_names_normalization: Bool
    var sleep_when_concurrency_limits_exceeded: Duration

    var no_default_server_header: Bool
    var no_default_date: Bool
    var no_default_content_type: Bool

    var close_on_shutdown: Bool
    var stream_request_body: Bool

    # TODO: support multiple listeners
    var ln: DynamicVector[PythonTCPListener]

    fn __init__(
        inout self, addr: String, handler: RequestHandler, error_handler: ErrorHandler
    ):
        self.handler = handler
        self.error_handler = error_handler

        self.name = "mojoweb"
        self.max_concurrent_connections = 1000
        self.read_buffer_size = 4096
        self.write_buffer_size = 4096

        # self.port = port
        # self.host_addr = host_addr StringLiteral
        # self.service = service
        # self.__py = Modules()
        # self.host_name = self.__py.socket.gethostbyname(
        #     self.__py.socket.gethostname(),
        # )
        # self.socket = None
        # self.__spinup_socket()
        # self.__bind_pySocket()

        self.read_timeout = Duration(5)
        self.write_timeout = Duration(5)
        self.idle_timeout = Duration(60)

        self.max_connections_per_ip = 0
        self.max_requests_per_connection = 0
        self.max_keep_alive_duration = Duration(0)
        self.max_idle_worker_duration = Duration(0)
        self.tcp_keep_alive_period = Duration(0)

        self.max_request_body_size = 0
        self.disable_keep_alive = False
        self.tcp_keep_alive = False
        self.reduce_memory_usage = False

        self.get_only = False
        self.disable_pre_parse_multipart_form = False
        self.disable_header_names_normalization = False
        self.sleep_when_concurrency_limits_exceeded = Duration(0)

        self.no_default_server_header = False
        self.no_default_date = False
        self.no_default_content_type = False

        self.close_on_shutdown = False
        self.stream_request_body = False

        self.ln = DynamicVector[PythonTCPListener]()

    fn get_concurrency(self) -> Int:
        var concurrency = self.max_concurrent_connections
        if concurrency <= 0:
            concurrency = DefaultConcurrency
        return concurrency

    fn listen_and_serve(self, address: String, handler: RequestHandler) raises -> None:
        ...
        # TODO: implement
        # _ = self.socket.listen()
        # let connection: Connection = self.__accept_connection()
        # connection.print_log_connect_message()

        # let st: Float64 = time.now()
        # let raw_request = connection.recieve_data()
        # let response: Response = self.__handle_request(
        #     connection=connection,
        #     raw_request=raw_request,
        # )

        # connection.send_response(response)
        # connection.close()

        # # go back to listening for requests
        # self.serve()

    fn serve(self, ln: Listener, handler: RequestHandler) raises -> None:
        ...
        # max_number_of_workers := self.max_concurrent_connections

        # fn __handle_request(self, raw_request: String, connection: Connection) raises -> Response:
        #     """Private function that makes generates a Response object given a Request object."""
        #     if not raw_request:
        #         return Response.empty_error(error_str=EMPTY_REQUEST_MESSAGE)

        #     try:
        #         let request = Request(body=raw_request)
        #         let response: Response = self.service.func(req=request)
        #         return response
        #     except Error:
        #         return Response.error(error_str=str(Error))
