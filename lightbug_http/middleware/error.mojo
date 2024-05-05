from lightbug_http.middleware.helpers import InternalServerError

## Error handler will catch any exceptions thrown by the other
## middleware and return a 500 response.
## It should be the first middleware in the chain.
@value
struct ErrorMiddleware(Middleware):
    var next: Middleware

    fn set_next(self, next: Middleware):
        self.next = next

    fn call(inout self, context: Context) -> HTTPResponse:
        try:
            return self.next.call(context)
        except e:
            return InternalServerError(e)

