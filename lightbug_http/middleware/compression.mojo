from lightbug_http.io.bytes import bytes

alias Bytes = List[Int8]

@value
struct CompressionMiddleware(Middleware):
    var next: Middleware

    fn call(self, context: Context) -> HTTPResponse:
        var response = self.next.call(context)
        response.body = self.compress(response.body)
        return response

    # TODO: implement compression
    fn compress(self, body: String) -> Bytes:
        #TODO: implement compression
        return bytes(body)

