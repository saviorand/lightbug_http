from mojoweb.handler import RequestHandler
from mojoweb.error import ErrorHandler
from mojoweb.net import Listener
from mojoweb.io.sync import Duration

alias DefaultConcurrency: Int = 256 * 1024


trait Server:
    fn __init__(
        inout self, addr: String, handler: RequestHandler, error_handler: ErrorHandler
    ):
        ...

    fn get_concurrency(self) -> Int:
        ...

    fn listen_and_serve(self, address: String, handler: RequestHandler) raises -> None:
        ...

    fn serve(self, ln: Listener, handler: RequestHandler) raises -> None:
        ...
