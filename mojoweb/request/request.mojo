from mojoweb.request.connection import Connection, Scope

# , ConnectionIterator


@value
struct HTTPConnection(Connection):
    var scope: Scope
    # var __headers: Dict[String, String]

    fn __init__(inout self, scope: Scope) raises -> None:
        self.scope = scope
        # self.__headers = Dict[String, String]()

    fn __getitem__(self, key: String) -> String:
        return self.scope.value

    # fn __iter__(self) raises -> ConnectionIterator:
    #     return ConnectionIterator(self.scope)


# trait Request(Connection):
#     fn __init__(
#         inout self,
#         charset: CharSet = CharSet.utf8,
#         content: String = "",
#     ) raises -> None:
#         ...

#     # fn __iter__(self) -> None:
#     #     pass

#     # fn __repr__(self) -> String:
#     #     pass

#     fn _to_bytes(self) raises -> DynamicVector[Int8]:
#         ...

#     @always_inline
#     fn body(self) -> String:
#         ...

#     @always_inline
#     fn status(self) -> Int:
#         ...


@value
struct MediaType:
    var value: String

    alias empty = MediaType("")
    alias plain = MediaType("text/plain")
    alias json = MediaType("application/json")


@value
struct CharSet:
    var value: String

    alias utf8 = CharSet("utf-8")


@value
struct HTTPResponse(Response):
    var __body: String
    var media_type: MediaType
    var charset: CharSet
    var status_code: Int

    fn __init__(
        inout self,
        charset: CharSet = CharSet.utf8,
        status_code: Int = 200,
        body: String = "",
        # headers: typing.Optional[typing.Mapping[str, str]] = None,
    ) raises -> None:
        self.__body = self.__body
        self.media_type = self.media_type
        self.charset = charset
        self.status_code = status_code
        # self.init_headers(headers)

    fn _to_bytes(self) raises -> DynamicVector[Int8]:
        if self.charset.value != "utf-8":
            raise Error("Only utf-8 is supported for now")
        return self.__body._buffer

    @always_inline
    fn body(self) -> String:
        return self.__body

    @always_inline
    fn status(self) -> Int:
        return self.status_code
