from lightbug_http.http import HTTPRequest, HTTPResponse
from lightbug_http.io.bytes import Bytes


trait HTTPService:
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        ...
