"""Almost all of the actual implementation in this module was written by @mzaks (https://github.com/mzaks)!
This would not be possible without his help.
"""

from ...builtins import Rune
from algorithm.functional import vectorize
from memory.unsafe import DTypePointer
from sys.info import simdwidthof
from bit import countl_zero


# The default lowest and highest continuation byte.
alias locb = 0b10000000
alias hicb = 0b10111111
alias RUNE_SELF = 0x80  # Characters below RuneSelf are represented as themselves in a single byte


# acceptRange gives the range of valid values for the second byte in a UTF-8
# sequence.
@value
struct AcceptRange(CollectionElement):
    var lo: UInt8  # lowest value for second byte.
    var hi: UInt8  # highest value for second byte.


# ACCEPT_RANGES has size 16 to avoid bounds checks in the code that uses it.
alias ACCEPT_RANGES = List[AcceptRange](
    AcceptRange(locb, hicb),
    AcceptRange(0xA0, hicb),
    AcceptRange(locb, 0x9F),
    AcceptRange(0x90, hicb),
    AcceptRange(locb, 0x8F),
)

# These names of these constants are chosen to give nice alignment in the
# table below. The first nibble is an index into acceptRanges or F for
# special one-byte cases. The second nibble is the Rune length or the
# Status for the special one-byte case.
alias xx = 0xF1  # invalid: size 1
alias as1 = 0xF0  # ASCII: size 1
alias s1 = 0x02  # accept 0, size 2
alias s2 = 0x13  # accept 1, size 3
alias s3 = 0x03  # accept 0, size 3
alias s4 = 0x23  # accept 2, size 3
alias s5 = 0x34  # accept 3, size 4
alias s6 = 0x04  # accept 0, size 4
alias s7 = 0x44  # accept 4, size 4


# first is information about the first byte in a UTF-8 sequence.
var first = List[UInt8](
    #   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,  # 0x00-0x0F
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,  # 0x10-0x1F
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,  # 0x20-0x2F
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,  # 0x30-0x3F
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,  # 0x40-0x4F
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,  # 0x50-0x5F
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,  # 0x60-0x6F
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,
    as1,  # 0x70-0x7F
    #   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,  # 0x80-0x8F
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,  # 0x90-0x9F
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,  # 0xA0-0xAF
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,  # 0xB0-0xBF
    xx,
    xx,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,  # 0xC0-0xCF
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,
    s1,  # 0xD0-0xDF
    s2,
    s3,
    s3,
    s3,
    s3,
    s3,
    s3,
    s3,
    s3,
    s3,
    s3,
    s3,
    s3,
    s4,
    s3,
    s3,  # 0xE0-0xEF
    s5,
    s6,
    s6,
    s6,
    s7,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,
    xx,  # 0xF0-0xFF
)


alias simd_width_u8 = simdwidthof[DType.uint8]()


fn rune_count_in_string(s: String) -> Int:
    """Count the number of runes in a string.

    Args:
        s: The string to count runes in.

    Returns:
        The number of runes in the string.
    """
    var p = DTypePointer[DType.uint8](s.unsafe_uint8_ptr())
    var string_byte_length = len(s)
    var result = 0

    @parameter
    fn count[simd_width: Int](offset: Int):
        result += int(((p.load[width=simd_width](offset) >> 6) != 0b10).reduce_add())

    vectorize[count, simd_width_u8](string_byte_length)
    return result
