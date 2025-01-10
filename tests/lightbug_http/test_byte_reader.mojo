import testing
from lightbug_http.utils import ByteReader
from lightbug_http.io.bytes import Bytes

alias example = "Hello, World!"

def test_peek():
    var r = ByteReader(example.as_bytes())
    testing.assert_equal(r.peek(), 72)

    r.read_pos = 999
    testing.assert_equal(r.peek(), 0)


def test_read_until():
    var r = ByteReader(example.as_bytes())
    testing.assert_equal(r.read_pos, 0)
    testing.assert_equal(Bytes(r.read_until(ord(","))), Bytes(72, 101, 108, 108, 111))
    testing.assert_equal(r.read_pos, 5)


def test_read_word():
    var r = ByteReader(example.as_bytes())
    testing.assert_equal(r.read_pos, 0)
    testing.assert_equal(Bytes(r.read_word()), Bytes(72, 101, 108, 108, 111, 44))
    testing.assert_equal(r.read_pos, 6)


def test_read_line():
    # No newline, go to end of line
    var r = ByteReader(example.as_bytes())
    testing.assert_equal(r.read_pos, 0)
    testing.assert_equal(Bytes(r.read_line()), Bytes(72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33))
    testing.assert_equal(r.read_pos, 14)

    # Newline, go to end of line. Should cover carriage return and newline
    var r2 = ByteReader("Hello\r\nWorld\n!".as_bytes())
    testing.assert_equal(r2.read_pos, 0)
    testing.assert_equal(Bytes(r2.read_line()), Bytes(72, 101, 108, 108, 111))
    testing.assert_equal(r2.read_pos, 7)
    testing.assert_equal(Bytes(r2.read_line()), Bytes(87, 111, 114, 108, 100))
    testing.assert_equal(r2.read_pos, 13)


def test_skip_whitespace():
    ...


def test_skip_newlines():
    ...


def test_increment():
    ...


def test_bytes():
    ...
