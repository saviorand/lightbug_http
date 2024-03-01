from lightbug_http.python.client import PythonClient
from lightbug_http.tests.utils import FakeClient
from lightbug_http.tests.test_client import test_client_lightbug


fn run_tests() raises:
    run_client_tests()


fn run_client_tests() raises:
    var fake_client = FakeClient()
    var py_client = PythonClient()
    test_client_lightbug[FakeClient](fake_client)
    test_client_lightbug[PythonClient](py_client)


fn main():
    try:
        run_tests()
    except e:
        print("Test suite failed: " + e.__str__())
