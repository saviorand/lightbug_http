from python import PythonObject
from mojoweb.response.response import TCPResponseTrait


struct TCPConnection:
    var conn: PythonObject
    var addr: PythonObject
    var __py: PythonObject

    fn __init__(inout self, conn_addr: PythonObject, py: PythonObject) raises -> None:
        self.conn = conn_addr[0]
        self.addr = conn_addr[1]
        self.__py = py

    fn receive_data(
        self, size: Int = 1024, encoding: StringLiteral = "utf-8"
    ) raises -> String:
        let data = self.conn.recv(size).decode(encoding)
        return str(data)

    fn send_response[R: TCPResponseTrait](self, response: R) raises -> None:
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


trait Connection(CollectionElement):
    fn __init__(
        inout self,
        scope: Scope,
        send: fn (message: String) -> NoneType,
        receive: fn () -> Coroutine[VariadicList[StringLiteral]],
    ) raises -> None:
        ...

    fn __getitem__(self, key: String) -> String:
        ...

    # TODO: implement __iter__ and __next__
    # fn __iter__(self) raises -> ConnectionIterator:
    #     ...

    # fn __next__(self) -> String:
    #     ...

    # fn __len__(self) -> Int:
    #     ...


@noncapturing
async fn empty_receive() raises -> NoneType:
    raise Error("Receive channel has not been set")


@noncapturing
async fn empty_send(message: String) raises -> NoneType:
    raise Error("Send channel has not been set")


# TODO: implement ConnectionIterator
# @value
# struct ConnectionIterator:
#     var __connection: Connection

#     fn __init__(inout self, connection: Connection) raises -> None:
#         self.__connection = connection

#     fn __next__(self) -> String:
#         return self.__connection.__next__()

#     fn __len__(self) -> Int:
#         return self.__connection.__len__()


@value
struct ScopeType:
    var value: String

    alias empty = ScopeType("")
    alias http = ScopeType("http")
    alias websocket = ScopeType("websocket")


@value
struct ScopeMethod:
    var value: String

    alias get = ScopeMethod("GET")
    alias post = ScopeMethod("POST")
    alias put = ScopeMethod("PUT")
    alias delete = ScopeMethod("DELETE")
    alias head = ScopeMethod("HEAD")
    alias patch = ScopeMethod("PATCH")
    alias options = ScopeMethod("OPTIONS")


@value
struct Scope:
    var type: ScopeType
    var method: ScopeMethod
    var app: String
    var url: String
    var base_url: String
    # var headers: Dict[String, String]
    var query_params: String
    # var path_params: Dict[String, String]
    # var cookies: String
    var client: Tuple[String, Int]
    # var session: Dict[String, String]
    var auth: String
    var user: String
    var state: String
