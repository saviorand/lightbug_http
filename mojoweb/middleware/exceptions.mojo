from mojoweb.app import ASGIApp
from mojoweb.request.request import Request
from mojoweb.response.response import Response


struct ExceptionMiddleware:
    fn __init__(inout self, app: ASGIApp, debug: Bool = False) -> None:
        self.app = app
        self.debug = debug
        self._status_handlers = None
        self._exception_handlers = self.http_exception

    async fn __call__(inout self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != String("http"):
            await self.app(scope, receive, send)
            return

        scope["mojoweb.exception_handlers"] = self._exception_handlers

        conn = Request(scope, receive, send)

        await exception_handler_wrapper(self.app, conn)

    fn http_exception(inout self, request: Request, exception: Exception) -> Response:
        return Response(
            status_code=exception.status_code,
            content=exception.detail,
        )
