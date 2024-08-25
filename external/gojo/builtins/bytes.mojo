from utils import Span

alias Byte = UInt8


fn equals[is_trivial: Bool](left: List[UInt8, is_trivial], right: List[UInt8, is_trivial]) -> Bool:
    if len(left) != len(right):
        return False
    for i in range(len(left)):
        if left[i] != right[i]:
            return False
    return True


fn has_prefix[is_trivial: Bool](bytes: List[Byte, is_trivial], prefix: List[Byte, is_trivial]) -> Bool:
    """Reports whether the List[Byte] struct begins with prefix.

    Args:
        bytes: The List[Byte] struct to search.
        prefix: The prefix to search for.

    Returns:
        True if the List[Byte] struct begins with prefix; otherwise, False.
    """
    var len_comparison = len(bytes) >= len(prefix)
    var prefix_comparison = equals(bytes[0 : len(prefix)], prefix)
    return len_comparison and prefix_comparison


fn has_suffix[is_trivial: Bool](bytes: List[Byte, is_trivial], suffix: List[Byte, is_trivial]) -> Bool:
    """Reports whether the List[Byte] struct ends with suffix.

    Args:
        bytes: The List[Byte] struct to search.
        suffix: The prefix to search for.

    Returns:
        True if the List[Byte] struct ends with suffix; otherwise, False.
    """
    var len_comparison = len(bytes) >= len(suffix)
    var suffix_comparison = equals(bytes[len(bytes) - len(suffix) : len(bytes)], suffix)
    return len_comparison and suffix_comparison


fn index_byte[is_trivial: Bool](bytes: List[Byte, is_trivial], delim: Byte) -> Int:
    """Return the index of the first occurrence of the byte delim.

    Args:
        bytes: The List[Byte] struct to search.
        delim: The byte to search for.

    Returns:
        The index of the first occurrence of the byte delim.
    """
    for i in range(len(bytes)):
        if bytes[i] == delim:
            return i

    return -1


fn index_byte(bytes: UnsafePointer[Scalar[DType.uint8]], size: Int, delim: Byte) -> Int:
    """Return the index of the first occurrence of the byte delim.

    Args:
        bytes: The DTypePointer[DType.int8] struct to search.
        size: The size of the bytes pointer.
        delim: The byte to search for.

    Returns:
        The index of the first occurrence of the byte delim.
    """
    for i in range(size):
        if UInt8(bytes[i]) == delim:
            return i

    return -1


fn index_byte(bytes: Span[UInt8], delim: Byte) -> Int:
    """Return the index of the first occurrence of the byte delim.

    Args:
        bytes: The Span to search.
        delim: The byte to search for.

    Returns:
        The index of the first occurrence of the byte delim.
    """
    for i in range(len(bytes)):
        if bytes[i] == delim:
            return i

    return -1


fn to_string[is_trivial: Bool](bytes: List[Byte, is_trivial]) -> String:
    """Makes a deepcopy of the List[Byte] supplied and converts it to a string. If it's not null terminated, it will append a null byte.

    Args:
        bytes: The List[Byte] struct to convert.

    Returns:
        The string representation of the List[Byte] struct.
    """
    var copy = List[Byte](bytes)
    if copy[-1] != 0:
        copy.append(0)
    return String(copy)
