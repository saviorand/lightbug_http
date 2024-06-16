from tests.test_io import test_io
from tests.test_http import test_http
from tests.test_header import test_header
from tests.test_uri import test_uri
# from lightbug_http.test.test_client import test_client

fn main() raises:
    test_io()
    test_http()
    test_header()
    test_uri()
    # test_client()

