from mojoweb.http import Request, Response


trait Service(Copyable):
    fn func(self, req: Request) raises -> Response:
        ...
