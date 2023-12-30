from mojoweb.http import Request, Response
from mojoweb.io.bytes import Bytes


trait HTTPService:
    fn func(self, req: Request) raises -> Response:
        ...


trait RawBytesService:
    fn func(self, req: Bytes) raises -> Bytes:
        ...
