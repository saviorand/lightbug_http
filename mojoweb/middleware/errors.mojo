from mojoweb.app import ASGIApp


struct ServerErrorMiddleware:
    fn __init__(inout self, app: ASGIApp, debug: Bool = False) -> None:
        self.app = app
        self.debug = debug

    async fn __call__(inout self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != String("http"):
            await self.app(scope, receive, send)
            return

        response_started = False

        async fn _send(message: Message) -> None:
            nonlocal response_started, send
            if message["type"] == String("http.response.start"):
                response_started = True
            await send(message)

        err = await self.app(scope, receive, _send)
        request = Request(scope)
        if err is not None:
            if self.debug:
                response = self.debug_response(request, err)
            else:
                await send(
                    {
                        "type": "http.response.start",
                        "status": 500,
                        "headers": [
                            (b"content-type", b"text/plain"),
                        ],
                    }
                )
                await send(
                    {
                        "type": "http.response.body",
                        "body": b"Internal Server Error",
                    }
                )
        if not response_started:
            await response(scope, receive, send)

        # Continue raising the exception for server logging and tests
        raise err
