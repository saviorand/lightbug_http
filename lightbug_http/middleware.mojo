from lightbug_http.http import *
from lightbug_http.service import HTTPService


## Context is a container for the request and response data.
## It is passed to each middleware in the chain.
## It also contains a dictionary of parameters that can be shared between middleware.
@value
struct Context:
    var request: HTTPRequest
    var params: Dict[String, String]

    fn __init__(inout self, request: HTTPRequest):
        self.request = request
        self.params = Dict[String, String]()


## Middleware is an interface for processing HTTP requests.
## Each middleware in the chain can modify the request and response.
trait Middleware:
    fn set_next(self, next: Middleware):
        ...
    fn call(self, context: Context) -> HTTPResponse:
        ...

## MiddlewareChain is a chain of middleware that processes the request.
@value
struct MiddlewareChain(HTTPService):
    var root: Middleware

    fn add(self, middleware: Middleware):
        if self.root == nil:
            self.root = middleware
        else:
            var current = self.root
            while current.next != nil:
                current = current.next
            current.set_next(middleware)

    fn func(self, request: HTTPRequest) raises -> HTTPResponse:
        var context = Context(request)
        return self.root.call(context)


# Middleware implementations

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


## Compression middleware compresses the response body.
@value
struct CompressionMiddleware(Middleware):
    var next: Middleware

    fn set_next(self, next: Middleware):
        self.next = next

    fn call(self, context: Context) -> HTTPResponse:
        var response = self.next.call(context)
        response.body = self.compress(response.body)
        return response

    fn compress(self, body: Bytes) -> Bytes:
        #TODO: implement compression
        return body


## Logger middleware logs the request to the console.
@value
struct LoggerMiddleware(Middleware):
    var next: Middleware

    fn set_next(self, next: Middleware):
        self.next = next

    fn call(self, context: Context) -> HTTPResponse:
        print(f"Request: {context.request}")
        return self.next.call(context)


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


## BasicAuth middleware requires basic authentication to access the route.
@value
struct BasicAuthMiddleware(Middleware):
    var next: Middleware
    var username: String
    var password: String

    fn set_next(self, next: Middleware):
        self.next = next

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


## Static middleware serves static files from a directory.
@value
struct StaticMiddleware(Middleware):
    var next: Middleware
    var path: String

    fn set_next(self, next: Middleware):
        self.next = next

    fn __init__(self, path: String):
        self.path = path

    fn call(self, context: Context) -> HTTPResponse:
      var path = context.request.uri().path()
      if path.endswith("/"):
            path = path + "index.html"

      try:
          var html: String
          with open(file, "r") as f:
              html = f.read()

          return Success(html, "text/html")
      except e:
            return self.next.call(context)




## HTTPHandler is an interface for handling HTTP requests in the RouterMiddleware.
## It is a leaf node in the middleware chain.
trait HTTPHandler:
    fn handle(self, context: Context) -> HTTPResponse:
        ...


## Router middleware routes requests to different middleware based on the path.
@value
struct RouterMiddleware(Middleware):
    var next: Middleware
    var routes: Dict[String, HTTPHandler]

    fn __init__(inout self):
        self.routes = Dict[String, HTTPHandler]()

    fn set_next(self, next: Middleware):
        self.next = next

    fn add(self, method: String, route: String, handler: HTTPHandler):
        self.routes[method + ":" + route] = handler

    fn call(self, context: Context) -> HTTPResponse:
        # TODO: create a more advanced router
        var method = context.request.header.method()
        var route = context.request.uri().path()
        var handler = self.routes.find(method + ":" + route)
        if handler:
            return handler.value().handle(context)
        else:
            return next.call(context)


## NotFound middleware returns a 404 response if no other middleware handles the request. It is a leaf node and always add at the end of the middleware chain
@value
struct NotFoundMiddleware(Middleware):
    fn call(self, context: Context) -> HTTPResponse:
        return NotFound("Not Found")



### Helper functions to create HTTP responses
fn Success(body: String) -> HTTPResponse:
    return Success(body, String("text/plain"))

fn Success(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 200, String("Success").as_bytes(), content_type.as_bytes()),
        body.as_bytes(),
    )

fn NotFound(body: String) -> HTTPResponse:
    return NotFound(body, String("text/plain"))

fn NotFound(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 404, String("Not Found").as_bytes(), content_type.as_bytes()),
        body.as_bytes(),
    )

fn InternalServerError(body: String) -> HTTPResponse:
   return InternalServerErrorResponse(body, String("text/plain"))

fn InternalServerError(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 500, String("Internal Server Error").as_bytes(), content_type.as_bytes()),
        body.as_bytes(),
    )

fn Unauthorized(body: String) -> HTTPResponse:
    return UnauthorizedResponse(body, String("text/plain"))

fn Unauthorized(body: String, content_type: String) -> HTTPResponse:
    var header = ResponseHeader(True, 401, String("Unauthorized").as_bytes(), content_type.as_bytes())
    header.headers["WWW-Authenticate"] = "Basic realm=\"Login Required\""

    return HTTPResponse(
        header,
        body.as_bytes(),
    )
