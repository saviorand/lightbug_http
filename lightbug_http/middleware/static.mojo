from lightbug_http.middleware.helpers import Success

## Static middleware serves static files from a directory.
@value
struct StaticMiddleware(Middleware):
    var next: Middleware
    var path: String

    fn set_next(self, next: Middleware):
        self.next = next

    fn __init__(inout self, path: String):
        self.path = path

    fn call(self, context: Context) -> HTTPResponse:
      var path = context.request.uri().path()
      if path.endswith("/"):
            path = path + "index.html"

      try:
          var html: String
          with open(path, "r") as f:
              html = f.read()

          return Success(html, "text/html")
      except e:
            return self.next.call(context)
