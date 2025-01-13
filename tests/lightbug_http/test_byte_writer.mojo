import testing
from lightbug_http.utils import ByteWriter
from lightbug_http.io.bytes import Bytes


def test_write_byte():
    var w = ByteWriter()
    w.write_byte(0x01)
    testing.assert_equal(w.consume(), Bytes(0x01))
    w.write_byte(2)
    testing.assert_equal(w.consume(), Bytes(2))


def test_consuming_write():
    var w = ByteWriter()
    var my_string: String = "World"
    w.consuming_write("Hello ")
    w.consuming_write(my_string^)
    testing.assert_equal(w.consume(), Bytes(72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100))

    var my_bytes = Bytes(72, 101, 108, 108, 111, 32)
    w.consuming_write(my_bytes^)
    w.consuming_write(Bytes(87, 111, 114, 108, 10))
    testing.assert_equal(w.consume(), Bytes(72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100))


def test_write():
    var w = ByteWriter()
    w.write("Hello", ", ")
    w.write_bytes("World!".as_bytes())
    testing.assert_equal(w.consume(), Bytes(72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33))
