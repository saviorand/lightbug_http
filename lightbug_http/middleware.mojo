struct Context:
    var request: Request
    var params: Dict[String, AnyType]

    func __init__(request: Request):
        self.request = request
        self.params = Dict[String, AnyType]()

trait Middleware:
    var next: Middleware

    func call(context: Context) -> Response:
        ...

struct ErrorMiddleware(Middleware):
    func call(context: Context) -> Response:
        do:
            return next.call(context: context)
        catch e: Exception:
            return InternalServerError()

struct LoggerMiddleware(Middleware):
    func call(context: Context) -> Response:
        print("Request: \(context.request)")
        return next.call(context: context)

struct RouterMiddleware(Middleware):
    var routes: Dict[String, Middleware]

    func __init__():
        self.routes = Dict[String, Middleware]()

    func add(route: String, middleware: Middleware):
        routes[route] = middleware

    func call(context: Context) -> Response:
        # TODO: create a more advanced router

        var route = context.request.path
        if middleware = routes[route]:
            return middleware.call(context: context)
        else:
            return NotFound()

struct StaticMiddleware(Middleware):
    var path: String

    funct __init__(path: String):
        self.path = path

    func call(context: Context) -> Response:
        var file = File(path: path + context.request.path)
        if file.exists:
            return FileResponse(file: file)
        else:
            return next.call(context: context)

struct CorsMiddleware(Middleware):
    func call(context: Context) -> Response:
        var response = next.call(context: context)
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response

struct CompressionMiddleware(Middleware):
    func call(context: Context) -> Response:
        var response = next.call(context: context)
        response.body = compress(response.body)
        return response

struct SessionMiddleware(Middleware):
    var session: Session

    func call(context: Context) -> Response:
        var request = context.request
        var response = context.response
        var session = session.load(request)
        context.params["session"] = session
        response = next.call(context: context)
        session.save(response)
        return response

struct BasicAuthMiddleware(Middleware):
    var username: String
    var password: String

    func __init__(username: String, password: String):
        self.username = username
        self.password = password

    func call(context: Context) -> Response:
        var request = context.request
        var auth = request.headers["Authorization"]
        if auth == "Basic \(username):\(password)":
            return next.call(context: context)
        else:
            return Unauthorized()

struct MiddlewareChain:
    var middlewares: Array[Middleware]

    func __init__():
        self.middlewares = Array[Middleware]()

    func add(middleware: Middleware):
        if middlewares.count == 0:
            middlewares.append(middleware)
        else:
            var last = middlewares[middlewares.count - 1]
            last.next = middleware
            middlewares.append(middleware)

    func execute(request: Request) -> Response:
        var context = Context(request: request, response: response)
        if middlewares.count > 0:
            return middlewares[0].call(context: context)
        else:
            return NotFound()

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
