from collections import InlineArray
from utils import StringSlice, Span
from memory import memcpy
import ..io


struct StringBuilder[growth_factor: Float32 = 2](
    Stringable,
    Sized,
    io.Writer,
    io.StringWriter,
    io.ByteWriter,
):
    """
    A string builder class that allows for efficient string management and concatenation.
    This class is useful when you need to build a string by appending multiple strings
    together. The performance increase is not linear. Compared to string concatenation,
    I've observed around 20-30x faster for writing and rending ~4KB and up to 400x-500x
    for ~4MB. This is because it avoids the overhead of creating and destroying many
    intermediate strings and performs memcpy operations.

    The result is a more efficient when building larger string concatenations. It
    is generally not recommended to use this class for small concatenations such as
    a few strings like `a + b + c + d` because the overhead of creating the string
    builder and appending the strings is not worth the performance gain.

    Example:
    ```mojo
    from gojo.strings import StringBuilder

    var sb = StringBuilder()
    _ = sb.write_string("Hello ")
    _ = sb.write_string("World!")
    print(str(sb)) # Hello World!
    ```
    """

    var _data: UnsafePointer[UInt8]
    """The internal buffer that holds the string data."""
    var _size: Int
    """The current size of the string builder."""
    var _capacity: Int
    """The current maximum capacity of the string builder."""

    fn __init__(inout self, *, capacity: Int = 4096):
        """Creates a new string builder with the given capacity.

        Args:
            capacity: The initial capacity of the string builder. The default is 4096.
        """
        constrained[growth_factor >= 1.25]()
        self._data = UnsafePointer[UInt8]().alloc(capacity)
        self._size = 0
        self._capacity = capacity

    fn __moveinit__(inout self, owned other: Self):
        self._data = other._data
        self._size = other._size
        self._capacity = other._capacity
        other._data = UnsafePointer[UInt8]()
        other._size = 0
        other._capacity = 0

    fn __del__(owned self):
        if self._data:
            self._data.free()

    fn __len__(self) -> Int:
        """Returns the length of the string builder."""
        return self._size

    fn as_bytes_slice(ref [_]self) -> Span[UInt8, __lifetime_of(self)]:
        """Returns the internal data as a Span[UInt8]."""
        return Span[UInt8, __lifetime_of(self)](unsafe_ptr=self._data, len=self._size)

    fn as_string_slice(ref [_]self) -> StringSlice[__lifetime_of(self)]:
        """Return a StringSlice view of the data owned by the builder.

        Returns:
            The string representation of the string builder. Returns an empty string if the string builder is empty.
        """
        return StringSlice[__lifetime_of(self)](unsafe_from_utf8_ptr=self._data, len=self._size)

    fn __str__(self) -> String:
        """Converts the string builder to a string.

        Returns:
            The string representation of the string builder. Returns an empty
            string if the string builder is empty.
        """
        return self.as_string_slice()

    @deprecated(
        "StringBuilder.render() has been deprecated. Use StringBuilder.as_string_slice() or call str() instead."
    )
    fn render(ref [_]self) -> StringSlice[__lifetime_of(self)]:
        """Return a StringSlice view of the data owned by the builder.

        Returns:
            The string representation of the string builder. Returns an empty string if the string builder is empty.
        """
        return self.as_string_slice()

    fn _resize(inout self, capacity: Int) -> None:
        """Resizes the string builder buffer.

        Args:
            capacity: The new capacity of the string builder buffer.
        """
        var new_data = UnsafePointer[UInt8]().alloc(capacity)
        memcpy(new_data, self._data, self._size)
        self._data.free()
        self._data = new_data
        self._capacity = capacity

        return None

    fn _resize_if_needed(inout self, bytes_to_add: Int) -> None:
        """Resizes the buffer if the bytes to add exceeds the current capacity.

        Args:
            bytes_to_add: The number of bytes to add to the buffer.
        """
        # TODO: Handle the case where new_capacity is greater than MAX_INT. It should panic.
        if bytes_to_add > self._capacity - self._size:
            var new_capacity = int(self._capacity * 2)
            if new_capacity < self._capacity + bytes_to_add:
                new_capacity = self._capacity + bytes_to_add
            self._resize(new_capacity)

    fn write(inout self, src: Span[UInt8]) -> (Int, Error):
        """Appends a byte Span to the builder buffer.

        Args:
            src: The byte array to append.
        """
        self._resize_if_needed(len(src))
        memcpy(self._data.offset(self._size), src._data, len(src))
        self._size += len(src)

        return len(src), Error()

    fn write_string(inout self, src: String) -> (Int, Error):
        """Appends a string to the builder buffer.

        Args:
            src: The string to append.

        Returns:
            The number of bytes written to the builder buffer.
        """
        return self.write(src.as_bytes_slice())

    fn write_byte(inout self, byte: UInt8) -> (Int, Error):
        """Appends a byte to the builder buffer.

        Args:
            byte: The byte to append.

        Returns:
            The number of bytes written to the builder buffer.
        """
        self._resize_if_needed(1)
        self._data[self._size] = byte
        self._size += 1
        return 1, Error()
