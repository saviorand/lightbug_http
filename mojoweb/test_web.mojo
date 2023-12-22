# from mojoweb.app import App
# from mojoweb.response import JSONResponse
# from mojoweb.routing import Route

from mojoweb.service import TCPService
from mojoweb.request.request import TCPRequest
from mojoweb.response.response import TCPResponse
from mojoweb.server import TCPLite

# async def homepage(request):
#     return JSONResponse({"hello": "world"})


# routes = [Route("/", endpoint=homepage)]

# app = App(debug=True, routes=routes)


fn main() raises -> None:
    let hello_service = HelloService()

    var server = TCPLite[HelloService](
        service=hello_service,
        port=9090,  # can be whatever port you want
        host_addr="127.0.0.1",  # this is localhost port
    )

    server.serve()


@value
struct HelloService(TCPService):
    fn func(self, request: TCPRequest) raises -> TCPResponse:
        return TCPResponse(
            body="You sent the following data: " + request.body(),
        )
