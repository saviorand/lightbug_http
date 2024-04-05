from lightbug_http.python.client import PythonClient
from lightbug_http.tests.test_client import test_python_client_lightbug


fn run_tests() raises:
    run_client_tests()


fn run_client_tests() raises:
    var py_client = PythonClient()
    test_python_client_lightbug(py_client)


fn main():
    try:
        run_tests()
    except e:
        print("Test suite failed: " + e.__str__())
