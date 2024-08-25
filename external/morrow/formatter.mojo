from collections.vector import InlinedFixedVector
from utils.static_tuple import StaticTuple
from .util import rjust
from .constants import MONTH_NAMES, MONTH_ABBREVIATIONS, DAY_NAMES, DAY_ABBREVIATIONS
from .timezone import UTC_TZ

alias formatter = _Formatter()


struct _Formatter:
    var _sub_chrs: InlinedFixedVector[Int, 128]

    fn __init__(inout self):
        self._sub_chrs = InlinedFixedVector[Int, 128](0)
        for i in range(128):
            self._sub_chrs[i] = 0
        self._sub_chrs[_Y] = 4
        self._sub_chrs[_M] = 4
        self._sub_chrs[_D] = 2
        self._sub_chrs[_d] = 4
        self._sub_chrs[_H] = 2
        self._sub_chrs[_h] = 2
        self._sub_chrs[_m] = 2
        self._sub_chrs[_s] = 2
        self._sub_chrs[_S] = 6
        self._sub_chrs[_Z] = 3
        self._sub_chrs[_A] = 1
        self._sub_chrs[_a] = 1

    fn format(self, m: Morrow, fmt: String) raises -> String:
        """
        "YYYY[abc]MM" -> repalce("YYYY") + "abc" + replace("MM")
        """
        if len(fmt) == 0:
            return ""
        var ret: String = ""
        var in_bracket = False
        var start_idx = 0
        for i in range(len(fmt)):
            if fmt[i] == "[":
                if in_bracket:
                    ret += "["
                else:
                    in_bracket = True
                ret += self.replace(m, fmt[start_idx:i])
                start_idx = i + 1
            elif fmt[i] == "]":
                if in_bracket:
                    ret += fmt[start_idx:i]
                    in_bracket = False
                else:
                    ret += self.replace(m, fmt[start_idx:i])
                    ret += "]"
                start_idx = i + 1
        if in_bracket:
            ret += "["
        if start_idx < len(fmt):
            ret += self.replace(m, fmt[start_idx:])
        return ret

    fn replace(self, m: Morrow, s: String) raises -> String:
        """
        split token and replace
        """
        if len(s) == 0:
            return ""
        var ret: String = ""
        var match_chr_ord = 0
        var match_count = 0
        for i in range(len(s)):
            var c = ord(s[i])
            if 0 < c < 128 and self._sub_chrs[c] > 0:
                if c == match_chr_ord:
                    match_count += 1
                else:
                    ret += self.replace_token(m, match_chr_ord, match_count)
                    match_chr_ord = c
                    match_count = 1
                if match_count == self._sub_chrs[c]:
                    ret += self.replace_token(m, match_chr_ord, match_count)
                    match_chr_ord = 0
            else:
                if match_chr_ord > 0:
                    ret += self.replace_token(m, match_chr_ord, match_count)
                    match_chr_ord = 0
                ret += s[i]
        if match_chr_ord > 0:
            ret += self.replace_token(m, match_chr_ord, match_count)
        return ret

    fn replace_token(self, m: Morrow, token: Int, token_count: Int) raises -> String:
        if token == _Y:
            if token_count == 1:
                return "Y"
            if token_count == 2:
                return rjust(m.year, 4, "0")[2:4]
            if token_count == 4:
                return rjust(m.year, 4, "0")
        elif token == _M:
            if token_count == 1:
                return String(m.month)
            if token_count == 2:
                return rjust(m.month, 2, "0")
            if token_count == 3:
                return String(MONTH_ABBREVIATIONS[m.month])
            if token_count == 4:
                return String(MONTH_NAMES[m.month])
        elif token == _D:
            if token_count == 1:
                return String(m.day)
            if token_count == 2:
                return rjust(m.day, 2, "0")
        elif token == _H:
            if token_count == 1:
                return String(m.hour)
            if token_count == 2:
                return rjust(m.hour, 2, "0")
        elif token == _h:
            var h_12 = m.hour
            if m.hour > 12:
                h_12 -= 12
            if token_count == 1:
                return String(h_12)
            if token_count == 2:
                return rjust(h_12, 2, "0")
        elif token == _m:
            if token_count == 1:
                return String(m.minute)
            if token_count == 2:
                return rjust(m.minute, 2, "0")
        elif token == _s:
            if token_count == 1:
                return String(m.second)
            if token_count == 2:
                return rjust(m.second, 2, "0")
        elif token == _S:
            if token_count == 1:
                return String(m.microsecond // 100000)
            if token_count == 2:
                return rjust(m.microsecond // 10000, 2, "0")
            if token_count == 3:
                return rjust(m.microsecond // 1000, 3, "0")
            if token_count == 4:
                return rjust(m.microsecond // 100, 4, "0")
            if token_count == 5:
                return rjust(m.microsecond // 10, 5, "0")
            if token_count == 6:
                return rjust(m.microsecond, 6, "0")
        elif token == _d:
            if token_count == 1:
                return String(m.isoweekday())
            if token_count == 3:
                return String(DAY_ABBREVIATIONS[m.isoweekday()])
            if token_count == 4:
                return String(DAY_NAMES[m.isoweekday()])
        elif token == _Z:
            if token_count == 3:
                return UTC_TZ.name if m.tz.is_none() else m.tz.name
            var separator = "" if token_count == 1 else ":"
            if m.tz.is_none():
                return UTC_TZ.format(separator)
            else:
                return m.tz.format(separator)

        elif token == _a:
            return "am" if m.hour < 12 else "pm"
        elif token == _A:
            return "AM" if m.hour < 12 else "PM"
        return ""


alias _Y = ord("Y")
alias _M = ord("M")
alias _D = ord("D")
alias _d = ord("d")
alias _H = ord("H")
alias _h = ord("h")
alias _m = ord("m")
alias _s = ord("s")
alias _S = ord("S")
alias _X = ord("X")
alias _x = ord("x")
alias _Z = ord("Z")
alias _A = ord("A")
alias _a = ord("a")
