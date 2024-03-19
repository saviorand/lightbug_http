import testing
from lightbug_http.io.bytes import Bytes, bytes_equal


fn test_bytes_equal() raises:
    var test1 = String("test").as_bytes()
    var test2 = String("test").as_bytes()
    var equal = bytes_equal(test1, test2)
    testing.assert_true(equal)
