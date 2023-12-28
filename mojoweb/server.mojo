from mojoweb.handler import RequestHandler
from mojoweb.error import Error
from mojoweb.net import Listener
from mojoweb.io.sync import Duration

alias DefaultConcurrency: Int = 256 * 1024


trait Server:
    fn __init__(
        inout self, addr: String, handler: RequestHandler, error_handler: Error
    ):
        ...

    fn get_concurrency(self) -> Int:
        ...

    fn listen_and_serve(self, address: String) raises -> None:
        ...

    fn serve(self, ln: Listener) raises -> None:
        ...
