from lightbug_http.middleware.helpers import Unauthorized

## BasicAuth middleware requires basic authentication to access the route.
@value
struct BasicAuthMiddleware(Middleware):
    var next: Middleware
    var username: String
    var password: String

    fn __init__(inout self, username: String, password: String):
        self.username = username
        self.password = password

    fn call(self, context: Context) -> HTTPResponse:
        var request = context.request
        #TODO: request object should have a way to get headers
        # var auth = request.headers["Authorization"]
        var auth = "Basic " + self.username + ":" + self.password
        if auth == "Basic " + self.username + ":" + self.password:
            context.params["username"] = username
            return next.call(context)
        else:
            return Unauthorized("Requires Basic Authentication")
