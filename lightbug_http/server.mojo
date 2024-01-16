from lightbug_http.error import ErrorHandler
from lightbug_http.service import HTTPService
from lightbug_http.net import Listener

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
