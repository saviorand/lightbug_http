from lightbug_http.http import *
from lightbug_http.service import HTTPService

@value
struct Context:
    var request: HTTPRequest
    var params: Dict[String, String]

    fn __init__(inout self, request: HTTPRequest):
        self.request = request
        self.params = Dict[String, String]()

trait Middleware:
    fn call(self, context: Context) -> HTTPResponse:
        ...

struct ErrorMiddleware(Middleware):
    var next: Middleware

    fn call(inout self, context: Context) -> HTTPResponse:
        try:
            return next.call(context)
        catch e: Exception:
            return InternalServerError()

struct LoggerMiddleware(Middleware):
    var next: Middleware

    fn call(self, context: Context) -> HTTPResponse:
        print(f"Request: {context.request}")
        return next.call(context)

struct StaticMiddleware(Middleware):
    var next: Middleware
    var path: String

    fn __init__(self, path: String):
        self.path = path

    fn call(self, context: Context) -> HTTPResponse:
        if context.request.uri().path() == "/":
            var file = File(path: path + "index.html")
        else:
            var file = File(path: path + context.request.uri().path())

        if file.exists:
          var html: String
          with open(file, "r") as f:
              html = f.read()
          return OK(html.as_bytes(), "text/html")
        else:
            return next.call(context)

struct CorsMiddleware(Middleware):
    var next: Middleware
    var allow_origin: String

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
            return next.call(context)
        else:
            return Unauthorized()

struct CompressionMiddleware(Middleware):
    var next: Middleware
    fn call(self, context: Context) -> HTTPResponse:
        var response = next.call(context)
        response.body = compress(response.body)
        return response

    fn compress(self, body: Bytes) -> Bytes:
        #TODO: implement compression
        return body

struct RouterMiddleware(Middleware):
    var next: Middleware
    var routes: Dict[String, Middleware]

    fn __init__(inout self):
        self.routes = Dict[String, Middleware]()

    fn add(self, method: String, route: String, middleware: Middleware):
        self.routes[method + ":" + route] = middleware

    fn call(self, context: Context) -> HTTPResponse:
        # TODO: create a more advanced router
        var method = context.request.header.method()
        var route = context.request.uri().path()
        var middleware = self.routes.find(method + ":" + route)
        if middleware:
            return middleware.value().call(context)
        else:
            return next.call(context)

struct BasicAuthMiddleware(Middleware):
    var next: Middleware
    var username: String
    var password: String

    fn __init__(self, username: String, password: String):
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

# always add at the end of the middleware chain
struct NotFoundMiddleware(Middleware):
    fn call(self, context: Context) -> HTTPResponse:
        return NotFound(String("Not Found").as_bytes())

struct MiddlewareChain(HTTPService):
    var middlewares: List[Middleware]

    fn __init__(inout self):
        self.middlewares = Array[Middleware]()

    fn add(self, middleware: Middleware):
        if self.middlewares.count == 0:
            self.middlewares.append(middleware)
        else:
            var last = self.middlewares[middlewares.count - 1]
            last.next = middleware
            self.middlewares.append(middleware)

    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var context = Context(request)
        return self.middlewares[0].call(context)

fn OK(body: Bytes) -> HTTPResponse:
    return OK(body, String("text/plain"))

fn OK(body: Bytes, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 200, String("OK").as_bytes(), content_type.as_bytes()),
        body,
    )

fn NotFound(body: Bytes) -> HTTPResponse:
    return NotFound(body, String("text/plain"))

fn NotFound(body: Bytes, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 404, String("Not Found").as_bytes(), content_type.as_bytes()),
        body,
    )

fn InternalServerError(body: Bytes) -> HTTPResponse:
   return InternalServerErrorResponse(body, String("text/plain"))

fn InternalServerError(body: Bytes, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 500, String("Internal Server Error").as_bytes(), content_type.as_bytes()),
        body,
    )

fn Unauthorized(body: Bytes) -> HTTPResponse:
    return UnauthorizedResponse(body, String("text/plain"))

fn Unauthorized(body: Bytes, content_type: String) -> HTTPResponse:
    var header = ResponseHeader(True, 401, String("Unauthorized").as_bytes(), content_type.as_bytes())
    header.headers["WWW-Authenticate"] = "Basic realm=\"Login Required\""

    return HTTPResponse(
        header,
        body,
    )
