import benchmark
from benchmark import Unit
from lightbug_http.io.bytes import Bytes
from lightbug_http.python.net import PythonNet
from lightbug_http.python.server import PythonServer
from lightbug_http.service import Printer
from lightbug_http.strings import NetworkType
from lightbug_http.tests.utils import TestStruct, FakeResponder


fn lightbug_benchmark_server() raises -> None:
    var server = PythonServer()
    var __net = PythonNet()
    let handler = FakeResponder()
    let listener = __net.listen("tcp4", "0.0.0.0:8080")
    server.serve(listener, handler)


fn lightbug_benchmark_misc() -> None:
    let direct_set_report = benchmark.run[init_test_and_set_a_direct](max_iters=1)

    let recreating_set_report = benchmark.run[init_test_and_set_a_copy](max_iters=1)

    print("Direct set: ")
    direct_set_report.print(Unit.ms)
    print("Recreating set: ")
    recreating_set_report.print(Unit.ms)


fn init_test_and_set_a_copy() -> None:
    let test = TestStruct("a", "b")
    let newtest = test.set_a_copy("c")


fn init_test_and_set_a_direct() -> None:
    var test = TestStruct("a", "b")
    let newtest = test.set_a_direct("c")
