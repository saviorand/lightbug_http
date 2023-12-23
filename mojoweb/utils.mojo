alias Bytes = DynamicVector[Int8]

# Time in nanoseconds
alias Duration = Int


trait Addr:
    fn network(self) -> String:
        ...

    fn string(self) -> String:
        ...
