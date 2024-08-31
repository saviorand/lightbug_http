import ..io
from ..builtins import copy


struct FileWrapper(io.ReadWriteCloser, io.ByteReader):
    """FileWrapper wraps a file handle and implements the ReadWriteCloser and ByteReader traits."""

    var handle: FileHandle
    """The file handle to read/write from/to."""

    fn __init__(inout self, path: String, mode: String) raises:
        """Create a new FileWrapper instance.

        Args:
            path: The path to the file.
            mode: The mode to open the file in.
        """
        self.handle = open(path, mode)

    fn __moveinit__(inout self, owned existing: Self):
        self.handle = existing.handle^

    fn __del__(owned self):
        var err = self.close()
        if err:
            # TODO: __del__ can't raise, but there should be some fallback.
            print(str(err))

    fn close(inout self) -> Error:
        """Close the file handle."""
        try:
            self.handle.close()
        except e:
            return e

        return Error()

    fn _read(inout self, inout dest: UnsafePointer[UInt8], capacity: Int) -> (Int, Error):
        """Read from the file handle into `dest`.
        Pretty hacky way to force the filehandle read into the defined trait, and it's unsafe since we're
        reading directly into the pointer.

        Args:
            dest: The buffer to read data into.
            capacity: The capacity of the destination buffer.

        Returns:
            The number of bytes read, or an error if one occurred.
        """
        var bytes_read: Int
        try:
            bytes_read = int(self.handle.read(ptr=dest, size=capacity))
        except e:
            return 0, e

        if bytes_read == 0:
            return bytes_read, io.EOF

        return bytes_read, Error()

    fn read(inout self, inout dest: List[UInt8, True]) -> (Int, Error):
        """Read from the file handle into `dest`.
        Pretty hacky way to force the filehandle read into the defined trait, and it's unsafe since we're
        reading directly into the pointer.

        Args:
            dest: The buffer to read data into.

        Returns:
            The number of bytes read, or an error if one occurred.
        """
        var dest_ptr = dest.unsafe_ptr().offset(dest.size)
        var bytes_read: Int
        var err: Error
        bytes_read, err = self._read(dest_ptr, dest.capacity - dest.size)
        dest.size += bytes_read

        return bytes_read, err

    fn read_all(inout self) -> (List[UInt8, True], Error):
        """Read all data from the file handle.

        Returns:
            The data read from the file handle, or an error if one occurred.
        """

        var bytes = List[UInt8, True](capacity=io.BUFFER_SIZE)
        while True:
            var temp = List[UInt8, True](capacity=io.BUFFER_SIZE)
            _ = self.read(temp)

            # If new bytes will overflow the result, resize it.
            if len(bytes) + len(temp) > bytes.capacity:
                bytes.reserve(bytes.capacity * 2)
            bytes.extend(temp)

            if len(temp) < io.BUFFER_SIZE:
                return bytes, io.EOF

    fn read_byte(inout self) -> (UInt8, Error):
        """Read a single byte from the file handle.

        Returns:
            The byte read from the file handle, or an error if one occurred.
        """
        try:
            var bytes: List[UInt8]
            var err: Error
            bytes, err = self.read_bytes(1)
            return bytes[0], Error()
        except e:
            return UInt8(0), e

    fn read_bytes(inout self, size: Int = -1) raises -> (List[UInt8], Error):
        """Read `size` bytes from the file handle.

        Args:
            size: The number of bytes to read. If -1, read all available bytes.

        Returns:
            The bytes read from the file handle, or an error if one occurred.
        """
        try:
            return self.handle.read_bytes(size), Error()
        except e:
            return List[UInt8](), e

    fn stream_until_delimiter(inout self, inout dest: List[UInt8, True], delimiter: UInt8, max_size: Int) -> Error:
        """Read from the file handle into `dest` until `delimiter` is reached.

        Args:
            dest: The buffer to read data into.
            delimiter: The byte to stop reading at.
            max_size: The maximum number of bytes to read.

        Returns:
            An error if one occurred.
        """
        var byte: UInt8
        var err = Error()
        for _ in range(max_size):
            byte, err = self.read_byte()
            if err:
                return err

            if byte == delimiter:
                return err
            dest.append(byte)
        return Error("Stream too long")

    fn seek(inout self, offset: Int, whence: Int = 0) -> (Int, Error):
        """Seek to a new position in the file handle.

        Args:
            offset: The offset to seek to.
            whence: The reference point for the offset.

        Returns:
            The new position in the file handle, or an error if one occurred.
        """
        try:
            var position = self.handle.seek(UInt64(offset), whence)
            return int(position), Error()
        except e:
            return 0, e

    fn write(inout self, src: Span[UInt8]) -> (Int, Error):
        """Write data to the file handle.

        Args:
            src: The buffer to write data from.

        Returns:
            The number of bytes written, or an error if one occurred.
        """
        if len(src) == 0:
            return 0, Error("No data to write")

        try:
            self.handle.write(src.unsafe_ptr())
            return len(src), io.EOF
        except e:
            return 0, Error(str(e))
