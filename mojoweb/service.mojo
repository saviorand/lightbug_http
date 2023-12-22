from mojoweb.response.response import TCPResponse
from mojoweb.request.request import TCPRequest


@value
trait TCPService(Copyable):
    fn func(self, req: TCPRequest) raises -> TCPResponse:
        ...
