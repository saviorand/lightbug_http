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


@value
struct Request(Connection):
    var __body: VariadicList[StringLiteral]
    var __scope: Scope
    var __receive: fn () -> Coroutine[VariadicList[StringLiteral]]
    var __send: fn (message: String) -> NoneType
    var __consumed: Bool
    var __is_disconnected: Bool
    # var __form: String

    fn __init__(
        inout self,
        scope: Scope,
        send: fn (message: String) -> NoneType,
        receive: fn () -> Coroutine[VariadicList[StringLiteral]],
    ) raises -> None:
        self.__scope = scope
        self.__receive = receive
        self.__send = send
        self.__consumed = False
        self.__is_disconnected = False
        # self.__form = None

    fn __getitem__(self, key: String) -> String:
        ...

    fn __setitem__(inout self, key: String, value: String) -> NoneType:
        ...

    fn method(self) -> String:
        return self.__scope.method.value

    fn receive(self) -> fn () -> Coroutine[VariadicList[StringLiteral]]:
        return self.__receive

    # TODO: what should this return?
    async def stream(self) -> VariadicList[StringLiteral]:
        if len(self.__body) > 0:
            return self.__body
        if self.__consumed:
            raise Error("Body was consumed")
        while not self.__consumed:
            let message: VariadicList[StringLiteral] = await self.__receive()
            # TODO: does this make sense? getting by index
            if message[0] == "http.request":
                self.__setitem__("body", message[0])
                self.__consumed = True
                return self.__body
            elif message[0] == "http.disconnect":
                self.__is_disconnected = True
                return ""
            else:
                raise Error("Unexpected message type: " + message[0])

    fn body(self) -> VariadicList[StringLiteral]:
        # TODO: implement this
        # if len(self.__body) == 0:
        # let chunks = VariadicList[StringLiteral]()
        # async for chunk in self.stream():
        #     chunks.append(chunk)
        # without async
        # while True:
        #     let chunk = await self.stream()
        #     if len(chunk) == 0:
        #         break
        #     chunks[0] = chunks[0] + chunk[0]
        # self._body = b"".join(chunks)
        return self.__body


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
