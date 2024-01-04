from lightbug_http.http import HTTPRequest, HTTPResponse


trait Client:
    fn __init__(inout self) raises:
        ...

    fn __init__(inout self, host: StringLiteral, port: Int) raises:
        ...

    fn do(self, req: HTTPRequest) raises -> HTTPResponse:
        ...
