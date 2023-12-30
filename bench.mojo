import benchmark
from benchmark import Unit
from mojoweb.tests.utils import TestStruct


fn lightbug_benchmark_server() -> None:
    ...


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
