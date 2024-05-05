from lightbug_http.service import HTTPService
from lightbug_http.http import HTTPRequest, HTTPResponse
from lightbug_http.middleware import *

## Context is a container for the request and response data.
## It is passed to each middleware in the chain.
## It also contains a dictionary of parameters that can be shared between middleware.
@value
struct Context:
    var request: HTTPRequest
    var params: Dict[String, AnyType]

    fn __init__(inout self, request: HTTPRequest):
        self.request = request
        self.params = Dict[String, AnyType]()


## Middleware is an interface for processing HTTP requests.
## Each middleware in the chain can modify the request and response.
trait Middleware:
    fn set_next(self, next: Middleware):
        ...
    fn call(self, context: Context) -> HTTPResponse:
        ...

## MiddlewareChain is a chain of middleware that processes the request.
## The chain is a linked list of middleware objects.
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
