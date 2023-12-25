from mojoweb.http import Request, Response


trait Client:
    fn __init__(inout self):
        ...

    fn get(inout self, request: Request) -> Response:
        ...
