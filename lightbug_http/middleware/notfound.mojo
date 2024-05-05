from lightbug_http.middleware.helpers import NotFound

## NotFound middleware returns a 404 response if no other middleware handles the request. It is a leaf node and always add at the end of the middleware chain
@value
struct NotFoundMiddleware(Middleware):
    fn call(self, context: Context) -> HTTPResponse:
        return NotFound("Not Found")
