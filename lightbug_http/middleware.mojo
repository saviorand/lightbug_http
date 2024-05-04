from lightbug_http.http import HTTPRequest, HTTPResponse

struct Context:
    var request: Request
    var params: Dict[String, AnyType]

    fn __init__(self, request: Request):
        self.request = request
        self.params = Dict[String, AnyType]()

trait Middleware:
    var next: Middleware

    fn call(self, context: Context) -> Response:
        ...

struct ErrorMiddleware(Middleware):
    fn call(self, context: Context) -> Response:
        try:
            return next.call(context: context)
        catch e: Exception:
            return InternalServerError()

struct LoggerMiddleware(Middleware):
    fn call(self, context: Context) -> Response:
        print("Request: \(context.request)")
        return next.call(context: context)

struct StaticMiddleware(Middleware):
    var path: String

    fnt __init__(self, path: String):
        self.path = path

    fn call(self, context: Context) -> Response:
        if context.request.path == "/":
            var file = File(path: path + "index.html")
        else:
            var file = File(path: path + context.request.path)

        if file.exists:
          var html: String
          with open(file, "r") as f:
              html = f.read()
          return OK(html.as_bytes(), "text/html")
        else:
            return next.call(context: context)

struct CorsMiddleware(Middleware):
    var allow_origin: String

    fn __init__(self, allow_origin: String):
        self.allow_origin = allow_origin

    fn call(self, context: Context) -> Response:
        if context.request.method == "OPTIONS":
            var response = next.call(context: context)
            response.headers["Access-Control-Allow-Origin"] = allow_origin
            response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
            response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
            return response

        if context.request.origin == allow_origin:
            return next.call(context: context)
        else:
            return Unauthorized()

struct CompressionMiddleware(Middleware):
    fn call(self, context: Context) -> Response:
        var response = next.call(context: context)
        response.body = compress(response.body)
        return response

    fn compress(self, body: Bytes) -> Bytes:
        #TODO: implement compression
        return body


struct RouterMiddleware(Middleware):
    var routes: Dict[String, Middleware]

    fn __init__(self):
        self.routes = Dict[String, Middleware]()

    fn add(self, method: String, route: String, middleware: Middleware):
      routes[method + ":" + route] = middleware

    fn call(self, context: Context) -> Response:
        # TODO: create a more advanced router
        var method = context.request.method
        var route = context.request.path
        if middleware = routes[method + ":" + route]:
            return middleware.call(context: context)
        else:
            return next.call(context: context)

struct BasicAuthMiddleware(Middleware):
    var username: String
    var password: String

    fn __init__(self, username: String, password: String):
        self.username = username
        self.password = password

    fn call(self, context: Context) -> Response:
        var request = context.request
        var auth = request.headers["Authorization"]
        if auth == "Basic \(username):\(password)":
            context.params["username"] = username
            return next.call(context: context)
        else:
            return Unauthorized()

# always add at the end of the middleware chain
struct NotFoundMiddleware(Middleware):
    fn call(self, context: Context) -> Response:
        return NotFound()

struct MiddlewareChain(HttpService):
    var middlewares: Array[Middleware]

    fn __init__(self):
        self.middlewares = Array[Middleware]()

    fn add(self, middleware: Middleware):
        if middlewares.count == 0:
            middlewares.append(middleware)
        else:
            var last = middlewares[middlewares.count - 1]
            last.next = middleware
            middlewares.append(middleware)

    fn func(self, request: Request) -> Response:
        self.add(NotFoundMiddleware())
        var context = Context(request: request, response: response)
        return middlewares[0].call(context: context)

fn OK(body: Bytes) -> HTTPResponse:
    return OK(body, String("text/plain"))

fn OK(body: Bytes, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 200, String("OK").as_bytes(), content_type.as_bytes()),
        body,
    )

fn NotFound(body: Bytes) -> HTTPResponse:
    return NotFoundResponse(body, String("text/plain"))

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
    return HTTPResponse(
        ResponseHeader(True, 401, String("Unauthorized").as_bytes(), content_type.as_bytes()),
        body,
    )
