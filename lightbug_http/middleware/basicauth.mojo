from lightbug_http.middleware.helpers import Unauthorized

## BasicAuth middleware requires basic authentication to access the route.
@value
struct BasicAuthMiddleware(Middleware):
    var next: Middleware
    var username: String
    var password: String

    fn set_next(self, next: Middleware):
        self.next = next

    fn __init__(inout self, username: String, password: String):
        self.username = username
        self.password = password

    fn call(self, context: Context) -> HTTPResponse:
        var request = context.request
        var auth = request.headers["Authorization"]
        if auth == f"Basic {username}:{password}":
            context.params["username"] = username
            return next.call(context)
        else:
            return Unauthorized("Requires Basic Authentication")
