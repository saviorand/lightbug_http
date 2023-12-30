from python import PythonObject
from mojoweb.python import Modules

alias Bytes = DynamicVector[Int8]


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return String(a) == String(b)


fn python_bytes_to_bytes(inout buf: Bytes, python_bytes: PythonObject) raises -> None:
    let bytes_str_repr = python_bytes.__str__()._buffer
    buf = bytes_str_repr
