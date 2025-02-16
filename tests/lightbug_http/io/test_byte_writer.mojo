import testing
from lightbug_http.io.bytes import Bytes, ByteWriter
from lightbug_http.strings import to_string

def test_write_byte():
    var w = ByteWriter()
    w.write_byte(0x01)
    testing.assert_equal(to_string(w^.consume()), to_string(Bytes(0x01)))

    w = ByteWriter()
    w.write_byte(2)
    testing.assert_equal(to_string(w^.consume()), to_string(Bytes(2)))


def test_consuming_write():
    var w = ByteWriter()
    var my_string: String = "World"
    w.consuming_write("Hello ")
    w.consuming_write(my_string^)
    
    var result = w^.consume()
    
    testing.assert_equal(to_string(result), "Hello World")


def test_write():
    var w = ByteWriter()
    w.write("Hello", ", ")
    w.write_bytes("World!".as_bytes())
    testing.assert_equal(to_string(w^.consume()), to_string(Bytes(72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33)))
