from python import PythonObject

alias Bytes = DynamicVector[Int8]


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return String(a) == String(b)


fn python_bytes_to_bytes(inout buf: Bytes, python_bytes: PythonObject) raises -> None:
    buf.append(python_bytes.__int__())
