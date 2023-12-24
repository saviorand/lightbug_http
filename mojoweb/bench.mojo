import benchmark
from time import sleep
from mojoweb.uri import URI


struct Test:
    var __a: String
    var __b: String

    fn __init__(inout self, a: String, b: String) -> None:
        self.__a = a
        self.__b = b

    fn a(self) -> String:
        return self.__a

    # fn set_a_direct(inout self, a: String) -> Self:
    #     self.__a = a

    fn set_a_copy(self, a: String) -> Self:
        return Self(a, self.__b)


fn hello_world() -> None:
    print("Hello world!")


fn init_test_and_set_a_copy() -> None:
    let test = Test("a", "b")
    # let newtest = test.set_a_direct("c")
    let newtest = test.set_a_copy("c")


# fn init_test_and_set_a_direct() -> None:
#     let test = Test("a", "b")
#     let newtest = test.set_a_direct("c")


fn init_uri_and_set_scheme() -> None:
    let uri = URI(
        String("/test")._buffer,
        String("http")._buffer,
        String("?test")._buffer,
        String("#test")._buffer,
        String("example.com")._buffer,
        False,
        String("test.example.com")._buffer,
        String("test.example.com")._buffer,
        String("username")._buffer,
        String("password")._buffer,
    )
    let newuri = uri.set_scheme("http")


fn main() -> None:
    let hello_world_report = benchmark.run[hello_world](max_iters=10)
    print("hello_world:")
    print(hello_world_report.mean())

    let init_test_and_set_a_copy_report = benchmark.run[init_test_and_set_a_copy](
        max_iters=10
    )
    print("init_test_and_set_a_copy:")
    print(init_test_and_set_a_copy_report.mean())

    # let init_test_and_set_a_direct_report = benchmark.run[init_test_and_set_a_direct](
    #     max_iters=10
    # )
    # print("init_test_and_set_a_direct:")
    # print(init_test_and_set_a_direct_report.mean())

    let init_uri_and_set_scheme_report = benchmark.run[init_uri_and_set_scheme](
        max_iters=10
    )
    print("init_uri_and_set_scheme:")
    print(init_uri_and_set_scheme_report.mean())
