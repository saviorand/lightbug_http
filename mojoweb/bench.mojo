import benchmark
from benchmark import Unit
from mojoweb.utils import Bytes


@value
struct Nested:
    var a: String
    var b: Int

    fn __init__(inout self, a: String, b: Int) -> None:
        self.a = a
        self.b = b

    fn set_a_direct(inout self, a: String) -> Self:
        self.a = a
        return self

    fn set_a_copy(self, a: String) -> Self:
        return Self(a, self.b)


@value
struct Test:
    var a: String
    var b: String
    var c: Bytes
    var d: Int
    var e: Nested

    fn __init__(inout self, a: String, b: String) -> None:
        self.a = a
        self.b = b
        self.c = String("c")._buffer
        self.d = 1
        self.e = Nested("a", 1)

    fn set_a_direct(inout self, a: String) -> Self:
        self.a = a
        return self

    fn set_a_copy(self, a: String) -> Self:
        return Self(a, self.b)


fn init_test_and_set_a_copy() -> None:
    let test = Test("a", "b")
    let newtest = test.set_a_copy("c")


fn init_test_and_set_a_direct() -> None:
    var test = Test("a", "b")
    let newtest = test.set_a_direct("c")


fn main() -> None:
    let direct_set_report = benchmark.run[init_test_and_set_a_direct](max_iters=1)

    let recreating_set_report = benchmark.run[init_test_and_set_a_copy](max_iters=1)

    print("Direct set: ")
    direct_set_report.print(Unit.ms)
    print("Recreating set: ")
    recreating_set_report.print(Unit.ms)
