## HTTPHandler is an interface for handling HTTP requests in the RouterMiddleware.
## It is a leaf node in the middleware chain.
trait HTTPHandler(CollectionElement):
    fn handle(self, context: Context) -> HTTPResponse:
        ...


## Router middleware routes requests to different middleware based on the path.
@value
struct RouterMiddleware[HTTPHandlerType: HTTPHandler](Middleware):
    var next: Middleware
    var routes: Dict[String, HTTPHandlerType]

    fn __init__(inout self):
        self.routes = Dict[String, HTTPHandlerType]()

    fn add(self, method: String, route: String, handler: HTTPHandlerType):
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
