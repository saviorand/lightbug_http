## Logger middleware logs the request to the console.
@value
struct LoggerMiddleware(Middleware):
    var next: Middleware

    fn set_next(self, next: Middleware):
        self.next = next

    fn call(self, context: Context) -> HTTPResponse:
        print(f"Request: {context.request}")
        return self.next.call(context)
        print(f"Response: {context.response}")
