alias Bytes = DynamicVector[Int8]

# Time in nanoseconds
alias Duration = Int


fn bytes_equal(a: Bytes, b: Bytes) -> Bool:
    return String(a) == String(b)


trait Addr:
    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...
