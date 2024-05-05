from lightbug_http.middleware.helpers import Unauthorized

## CORS middleware adds the necessary headers to allow cross-origin requests.
@value
struct CorsMiddleware(Middleware):
    var next: Middleware
    var allow_origin: String

    fn set_next(self, next: Middleware):
        self.next = next

    fn __init__(self, allow_origin: String):
        self.allow_origin = allow_origin

    fn call(self, context: Context) -> HTTPResponse:
        if context.request.header.method() == "OPTIONS":
            var response = next.call(context)
            response.headers["Access-Control-Allow-Origin"] = allow_origin
            response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
            response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
            return response

        if context.request.origin == allow_origin:
            return self.next.call(context)
        else:
            return Unauthorized("CORS not allowed")
