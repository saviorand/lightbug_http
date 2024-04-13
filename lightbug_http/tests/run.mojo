from lightbug_http.python.client import PythonClient
from lightbug_http.sys.client import MojoClient
from lightbug_http.tests.test_client import (
    test_python_client_lightbug,
    test_mojo_client_lightbug,
    test_mojo_client_lightbug_external_req,
)


fn run_tests() raises:
    run_client_tests()


fn run_client_tests() raises:
    var py_client = PythonClient()
    var mojo_client = MojoClient()
    # test_mojo_client_lightbug_external_req(mojo_client)
    test_mojo_client_lightbug(mojo_client)
    test_python_client_lightbug(py_client)


fn main():
    try:
        run_tests()
        print("Test suite passed")
    except e:
        print("Test suite failed: " + e.__str__())
