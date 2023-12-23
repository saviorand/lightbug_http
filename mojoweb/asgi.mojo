from mojoweb.scope import Scope


@noncapturing
async fn empty_app() raises -> Tuple[Receive, Send]:
    raise Error("empty app")


@value
struct ASGIApp:
    fn __call__(
        self, scope: Scope, receive: Receive, send: Send
    ) -> RaisingCoroutine[Tuple[Receive, Send]]:
        return empty_app()


@value
struct Receive:
    pass


@value
struct Send:
    pass
