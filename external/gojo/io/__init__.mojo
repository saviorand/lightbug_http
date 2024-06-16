from .traits import (
    Reader,
    Writer,
    Seeker,
    Closer,
    ReadWriter,
    ReadCloser,
    WriteCloser,
    ReadWriteCloser,
    ReadSeeker,
    ReadSeekCloser,
    WriteSeeker,
    ReadWriteSeeker,
    ReaderFrom,
    WriterReadFrom,
    WriterTo,
    ReaderWriteTo,
    ReaderAt,
    WriterAt,
    ByteReader,
    ByteScanner,
    ByteWriter,
    RuneReader,
    RuneScanner,
    StringWriter,
    SEEK_START,
    SEEK_CURRENT,
    SEEK_END,
    ERR_SHORT_WRITE,
    ERR_NO_PROGRESS,
    ERR_SHORT_BUFFER,
    EOF,
)
from .io import write_string, read_at_least, read_full, read_all, BUFFER_SIZE


alias i1 = __mlir_type.i1
alias i1_1 = __mlir_attr.`1: i1`
alias i1_0 = __mlir_attr.`0: i1`
