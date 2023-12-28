alias Bytes = DynamicVector[Int8]


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return String(a) == String(b)
