from lightbug_http.http import HTTPRequest, HTTPResponse


trait Client:
    fn __init__(inout self):
        ...

    fn get(inout self, request: HTTPRequest) -> HTTPResponse:
        ...
