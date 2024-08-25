from collections import InlineArray
from .table import Interval, narrow, combining, doublewidth, ambiguous, emoji, nonprint


@value
struct Condition:
    """Condition have flag EastAsianWidth whether the current locale is CJK or not."""

    var east_asian_width: Bool
    var strict_emoji_neutral: Bool

    fn rune_width(self, r: UInt32) -> Int:
        """Returns the number of cells in r.
        See http://www.unicode.org/reports/tr11/."""
        if r < 0 or r > 0x10FFFF:
            return 0

        if not self.east_asian_width:
            if r < 0x20:
                return 0
            # nonprint
            elif (r >= 0x7F and r <= 0x9F) or r == 0xAD:
                return 0
            elif r < 0x300:
                return 1
            elif in_table(r, narrow):
                return 1
            elif in_table(r, nonprint):
                return 0
            elif in_table(r, combining):
                return 0
            elif in_table(r, doublewidth):
                return 2
            else:
                return 1
        else:
            if in_table(r, nonprint):
                return 0
            elif in_table(r, combining):
                return 0
            elif in_table(r, narrow):
                return 1
            if in_table(r, ambiguous):
                return 2
            elif in_table(r, doublewidth):
                return 2
            elif in_table(r, ambiguous) or in_table(r, emoji):
                return 2
            elif not self.strict_emoji_neutral and in_table(r, ambiguous):
                return 2
            elif not self.strict_emoji_neutral and in_table(r, emoji):
                return 2
            elif not self.strict_emoji_neutral and in_table(r, narrow):
                return 2
            else:
                return 1

    fn string_width(self, s: String) -> Int:
        """Return width as you can see."""
        var width = 0
        for r in s:
            width += self.rune_width(ord(String(r)))
        return width


fn in_tables(r: UInt32, *ts: InlineArray[Interval]) -> Bool:
    for t in ts:
        if in_table(r, t[]):
            return True
    return False


fn in_table[size: Int](r: UInt32, t: InlineArray[Interval, size]) -> Bool:
    if r < t[0].first:
        return False

    var bot = 0
    var top = len(t) - 1
    while top >= bot:
        var mid = (bot + top) >> 1

        if t[mid].last < r:
            bot = mid + 1
        elif t[mid].first > r:
            top = mid - 1
        else:
            return True

    return False


alias DEFAULT_CONDITION = Condition(east_asian_width=False, strict_emoji_neutral=True)


fn string_width(s: String) -> Int:
    """Return width as you can see.

    Args:
        s: The string to calculate the width of.

    Returns:
        The printable width of the string.
    """
    return DEFAULT_CONDITION.string_width(s)


fn rune_width(rune: UInt32) -> Int:
    """Return width as you can see.

    Args:
        rune: The rune to calculate the width of.

    Returns:
        The printable width of the rune.
    """
    return DEFAULT_CONDITION.rune_width(rune)
