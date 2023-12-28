from mojoweb.http import Request, Response


@value
trait Service(Copyable):
    fn func(self, req: Request) raises -> Response:
        ...
