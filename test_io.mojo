import testing
from mojoweb.io.bytes import Bytes, bytes_equal


fn main() raises:
    let test1 = String("test")._buffer
    let test2 = String("test")._buffer
    let equal = bytes_equal(test1, test2)
    testing.assert_true(equal)
