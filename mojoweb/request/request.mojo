from mojoweb.request.connection import Connection, Scope

# , ConnectionIterator


@value
struct TCPRequest:
    var __body: String

    fn __init__(inout self, body: String) -> None:
        self.__body = body

    @always_inline
    fn body(self) -> String:
        return self.__body

    fn to_bytes(self, py_builtins: PythonObject) raises -> PythonObject:
        let byte_string = py_builtins.bytes(self.body(), "utf-8")
        return byte_string


@value
struct Request:
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
        self.__body = VariadicList[StringLiteral]()
        self.__scope = scope
        self.__receive = receive
        self.__send = send
        self.__consumed = False
        self.__is_disconnected = False
        # self.__form = None

    fn __getitem__(self, key: String) -> String:
        return ""

    fn __setitem__(inout self, key: String, value: String) -> NoneType:
        return None

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
                # raise Error("Unexpected message type: " + message[0])
                return ""
        return self.__body

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
