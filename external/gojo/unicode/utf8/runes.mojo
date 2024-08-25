"""Almost all of the actual implementation in this module was written by @mzaks (https://github.com/mzaks)!
This would not be possible without his help.
"""

from algorithm.functional import vectorize
from sys.info import simdwidthof


alias simd_width_u8 = simdwidthof[DType.uint8]()


fn rune_count_in_string(s: String) -> Int:
    """Count the number of runes in a string.

    Args:
        s: The string to count runes in.

    Returns:
        The number of runes in the string.
    """
    var p = UnsafePointer[Scalar[DType.uint8]](s.unsafe_ptr())
    var string_byte_length = len(s)
    var result = 0

    @parameter
    fn count[simd_width: Int](offset: Int):
        result += int(((p.load[width=simd_width](offset) >> 6) != 0b10).cast[DType.uint8]().reduce_add())

    vectorize[count, simd_width_u8](string_byte_length)
    return result
