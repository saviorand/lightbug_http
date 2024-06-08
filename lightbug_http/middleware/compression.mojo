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

    # TODO: implement compression
    # Should return Bytes instead of String but we don't have Bytes type yet
    fn compress(self, body: String) -> String:
        #TODO: implement compression
        return body

