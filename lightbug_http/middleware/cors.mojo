from lightbug_http.middleware.helpers import Unauthorized
from lightbug_http.io.bytes import bytes, bytes_equal

## CORS middleware adds the necessary headers to allow cross-origin requests.
@value
struct CorsMiddleware(Middleware):
    var next: Middleware
    var allow_origin: String

    fn set_next(self, next: Middleware):
        self.next = next

    fn __init__(inout self, allow_origin: String):
        self.allow_origin = allow_origin

    fn call(self, context: Context) -> HTTPResponse:
        if bytes_equal(context.request.header.method(), bytes("OPTIONS")):
            var response = self.next.call(context)
            response.headers["Access-Control-Allow-Origin"] = self.allow_origin
            response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
            response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
            return response

        # TODO: implement headers
        #  if context.request.headers["origin"] == self.allow_origin:
        #     return self.next.call(context)
        # else:
        #     return Unauthorized("CORS not allowed")

        return self.next.call(context)
