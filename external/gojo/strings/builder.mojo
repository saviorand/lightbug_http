# Adapted from https://github.com/maniartech/mojo-strings/blob/master/strings/builder.mojo
# Modified to use DynamicVector[Int8] instead of DynamicVector[String]

from collections.vector import DynamicVector
import ..io
from ..builtins._bytes import Bytes


@value
struct StringBuilder(Stringable, Sized, io.Writer, io.ByteWriter, io.StringWriter):
    """
    A string builder class that allows for efficient string management and concatenation.
    This class is useful when you need to build a string by appending multiple strings
    together. It is around 10x faster than using the `+` operator to concatenate
    strings because it avoids the overhead of creating and destroying many
    intermediate strings and performs memcopy operations.

    The result is a more efficient when building larger string concatenations. It
    is generally not recommended to use this class for small concatenations such as
    a few strings like `a + b + c + d` because the overhead of creating the string
    builder and appending the strings is not worth the performance gain.

    Example:
      ```
      from strings.builder import StringBuilder

      var sb = StringBuilder()
      sb.append("mojo")
      sb.append("jojo")
      print(sb) # mojojojo
      ```
    """

    var _vector: Bytes

    fn __init__(inout self, size: Int = 4096):
        self._vector = Bytes(size)

    fn __str__(self) -> String:
        """
        Converts the string builder to a string.

        Returns:
          The string representation of the string builder. Returns an empty
          string if the string builder is empty.
        """
        # Don't need to add a null terminator because we can pass the length of the string.
        return StringRef(self._vector._vector.data.value, len(self._vector))

    fn write(inout self, src: Bytes) raises -> Int:
        """
        Appends a byte array to the builder buffer.

        Args:
          src: The byte array to append.
        """
        self._vector += src
        return len(src)

    fn write_byte(inout self, byte: Int8) raises -> Int:
        """
        Appends a byte array to the builder buffer.

        Args:
            byte: The byte array to append.
        """
        self._vector.append(byte)
        return 1

    fn write_string(inout self, src: String) raises -> Int:
        """
        Appends a string to the builder buffer.

        Args:
          src: The string to append.
        """
        var string_buffer = src.as_bytes()
        self._vector.extend(string_buffer)
        return len(string_buffer)

    fn __len__(self) -> Int:
        """
        Returns the length of the string builder.

        Returns:
          The length of the string builder.
        """
        return len(self._vector)

    fn __getitem__(self, index: Int) -> String:
        """
        Returns the string at the given index.

        Args:
          index: The index of the string to return.

        Returns:
          The string at the given index.
        """
        return self._vector[index]

    fn __setitem__(inout self, index: Int, value: Int8):
        """
        Sets the string at the given index.

        Args:
          index: The index of the string to set.
          value: The value to set.
        """
        self._vector[index] = value
