from lightbug_http.http import Request, Response
from lightbug_http.io.bytes import Bytes


trait HTTPService:
    fn func(self, req: Request) raises -> Response:
        ...


trait RawBytesService:
    fn func(self, req: Bytes) raises -> Bytes:
        ...
