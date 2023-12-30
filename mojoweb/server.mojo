from mojoweb.error import ErrorHandler
from mojoweb.service import HTTPService
from mojoweb.net import Listener
from mojoweb.io.sync import Duration

alias DefaultConcurrency: Int = 256 * 1024


trait ServerTrait:
    fn __init__(
        inout self, addr: String, service: HTTPService, error_handler: ErrorHandler
    ):
        ...

    fn get_concurrency(self) -> Int:
        ...

    fn listen_and_serve(self, address: String, handler: HTTPService) raises -> None:
        ...

    fn serve(self, ln: Listener, handler: HTTPService) raises -> None:
        ...
