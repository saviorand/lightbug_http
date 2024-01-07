import benchmark
from benchmark import Unit
from python import Python
from lightbug_http.io.bytes import Bytes
from lightbug_http.python.net import PythonNet
from lightbug_http.python.server import PythonServer
from lightbug_http.service import Printer
from lightbug_http.strings import NetworkType
from lightbug_http.tests.utils import (
    TestStruct,
    FakeResponder,
    new_fake_listener,
    new_httpx_client,
    FakeListener,
    FakeServer,
    getRequest,
)

from lightbug_http.sys.libc import __test_socket_server__, __test_socket_client__


fn lightbug_benchmark_get_1req_per_conn():
    let httpx = new_httpx_client()

    @parameter
    fn httpx_get() -> None:
        # let client = new_httpx_client()
        try:
            let response = httpx.get("http://0.0.0.0:8080")
        except e:
            print("Error making request: " + e.__str__())

    try:
        let req_report = benchmark.run[httpx_get]()
        print("Request: ")
        req_report.print(Unit.ms)
    except e:
        print("Error importing httpx: " + e.__str__())


fn main():
    # lightbug_benchmark_get_1req_per_conn()
    try:
        # __test_socket_server__()
        __test_socket_client__()
    except e:
        print("Error running test server: " + e.__str__())


fn lightbug_benchmark_server():
    let server_report = benchmark.run[run_fake_server](max_iters=1)
    print("Server: ")
    server_report.print(Unit.ms)


fn lightbug_benchmark_misc() -> None:
    let direct_set_report = benchmark.run[init_test_and_set_a_direct](max_iters=1)

    let recreating_set_report = benchmark.run[init_test_and_set_a_copy](max_iters=1)

    print("Direct set: ")
    direct_set_report.print(Unit.ms)
    print("Recreating set: ")
    recreating_set_report.print(Unit.ms)


fn run_fake_server():
    let handler = FakeResponder()
    let listener = new_fake_listener(2, getRequest)
    var server = FakeServer(listener, handler)
    server.serve()


fn init_test_and_set_a_copy() -> None:
    let test = TestStruct("a", "b")
    let newtest = test.set_a_copy("c")


fn init_test_and_set_a_direct() -> None:
    var test = TestStruct("a", "b")
    let newtest = test.set_a_direct("c")
