import benchmark
from lightbug_http.sys.server import SysServer
from lightbug_http.service import TechEmpowerRouter
from lightbug_http.tests.utils import (
    TestStruct,
    FakeResponder,
    new_fake_listener,
    FakeServer,
    getRequest,
)
from external.libc import __test_socket_client__


fn main():
    try:
        var server = SysServer()
        var handler = TechEmpowerRouter()
        server.listen_and_serve("0.0.0.0:8080", handler)
    except e:
        print("Error starting server: " + e.__str__())
        return


fn lightbug_benchmark_get_1req_per_conn():
    var req_report = benchmark.run[__test_socket_client__](1, 10000, 0, 3, 100)
    print("Request: ")
    req_report.print(benchmark.Unit.ns)


fn lightbug_benchmark_server():
    var server_report = benchmark.run[run_fake_server](max_iters=1)
    print("Server: ")
    server_report.print(benchmark.Unit.ms)


fn lightbug_benchmark_misc() -> None:
    var direct_set_report = benchmark.run[init_test_and_set_a_direct](max_iters=1)

    var recreating_set_report = benchmark.run[init_test_and_set_a_copy](max_iters=1)

    print("Direct set: ")
    direct_set_report.print(benchmark.Unit.ms)
    print("Recreating set: ")
    recreating_set_report.print(benchmark.Unit.ms)


fn run_fake_server():
    var handler = FakeResponder()
    var listener = new_fake_listener(2, getRequest)
    var server = FakeServer(listener, handler)
    server.serve()


fn init_test_and_set_a_copy() -> None:
    var test = TestStruct("a", "b")
    var newtest = test.set_a_copy("c")


fn init_test_and_set_a_direct() -> None:
    var test = TestStruct("a", "b")
    var newtest = test.set_a_direct("c")
