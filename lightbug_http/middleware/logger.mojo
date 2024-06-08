## Logger middleware logs the request to the console.
@value
struct LoggerMiddleware(Middleware):
    var next: Middleware

    fn call(self, context: Context) -> HTTPResponse:
        var request = context.request
        #TODO: request is not printable
        # print("Request: ", request)
        var response = self.next.call(context)
        print("Response:",  response)
        return response
