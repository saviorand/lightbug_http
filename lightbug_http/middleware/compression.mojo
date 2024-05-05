## Compression middleware compresses the response body.
@value
struct CompressionMiddleware(Middleware):
    var next: Middleware

    fn set_next(self, next: Middleware):
        self.next = next

    fn call(self, context: Context) -> HTTPResponse:
        var response = self.next.call(context)
        response.body = self.compress(response.body)
        return response

    fn compress(self, body: Bytes) -> Bytes:
        #TODO: implement compression
        return body

