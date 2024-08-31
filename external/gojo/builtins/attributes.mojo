from collections import InlineList


fn copy[
    T: CollectionElement, is_trivial: Bool
](inout target: List[T, is_trivial], source: List[T, is_trivial], start: Int = 0) -> Int:
    """Copies the contents of source into target at the same index.

    Args:
        target: The buffer to copy into.
        source: The buffer to copy from.
        start: The index to start copying into.

    Returns:
        The number of bytes copied.
    """
    var count = 0

    for i in range(len(source)):
        if i + start > len(target):
            target[i + start] = source[i]
        else:
            target.append(source[i])
        count += 1

    return count


fn copy(target: UnsafePointer[UInt8], source: UnsafePointer[UInt8], source_length: Int) -> Int:
    """Copies the contents of source into target at the same index.

    Args:
        target: The buffer to copy into.
        source: The buffer to copy from.
        source_length: The length of the source buffer.

    Returns:
        The number of bytes copied.
    """
    var count = 0
    for i in range(source_length):
        target[i] = source[i]
        count += 1

    return count


fn copy(
    inout target: List[UInt8, True],
    source: UnsafePointer[Scalar[DType.uint8]],
    source_start: Int,
    source_end: Int,
    target_start: Int = 0,
) -> Int:
    """Copies the contents of source into target at the same index.

    Args:
        target: The buffer to copy into.
        source: The buffer to copy from.
        source_start: The index to start copying from.
        source_end: The index to stop copying at.
        target_start: The index to start copying into.

    Returns:
        The number of bytes copied.
    """
    var count = 0

    for i in range(source_start, source_end):
        if i + target_start > len(target):
            target[i + target_start] = source[i]
        else:
            target.append(source[i])
        count += 1

    return count
