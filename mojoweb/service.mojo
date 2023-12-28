from mojoweb.http import Request, Response


trait Service(CollectionElement):
    fn func(self, req: Request) raises -> Response:
        ...
