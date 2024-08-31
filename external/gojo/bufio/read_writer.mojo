from .reader import Reader
from .writer import Writer


# buffered input and output
struct ReadWriter[R: io.Reader, W: io.Writer]():
    """ReadWriter has both a buffered reader and writer."""

    var reader: Reader[R]
    var writer: Writer[W]

    fn __init__(inout self, owned reader: R, owned writer: W):
        self.reader = Reader(reader^)
        self.writer = Writer(writer^)
