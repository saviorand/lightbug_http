"""Formatting options
General
%v	the value in a default format
    when printing structs, the plus flag (%+v) adds field names

Boolean
%t	the word true or false

Integer
%d	base 10
%q	a single-quoted character literal.
%x	base 16, with lower-case letters for a-f
%X	base 16, with upper-case letters for A-F

Floating-point and complex constituents:
%f	decimal point but no exponent, e.g. 123.456

String and slice of bytes (treated equivalently with these verbs):
%s	the uninterpreted bytes of the string or slice
%q	a double-quoted string

TODO:
- Add support for more formatting options
- Switch to buffered writing to avoid multiple string concatenations
- Add support for width and precision formatting options
- Handle escaping for String's %q
"""

from utils.variant import Variant
from math import floor
from ..builtins import Byte

alias Args = Variant[String, Int, Float64, Bool, List[Byte]]


fn replace_first(s: String, old: String, new: String) -> String:
    """Replace the first occurrence of a substring in a string.

    Args:
        s: The original string
        old: The substring to be replaced
        new: The new substring

    Returns:
        The string with the first occurrence of the old substring replaced by the new one.
    """
    # Find the first occurrence of the old substring
    var index = s.find(old)

    # If the old substring is found, replace it
    if index != -1:
        return s[:index] + new + s[index + len(old) :]

    # If the old substring is not found, return the original string
    return s


fn find_first_verb(s: String, verbs: List[String]) -> String:
    """Find the first occurrence of a verb in a string.

    Args:
        s: The original string
        verbs: The list of verbs to search for.

    Returns:
        The verb to replace.
    """
    var index = -1
    var verb: String = ""

    for v in verbs:
        var i = s.find(v[])
        if i != -1 and (index == -1 or i < index):
            index = i
            verb = v[]

    return verb


alias BASE10_TO_BASE16 = List[String]("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")


fn convert_base10_to_base16(value: Int) -> String:
    """Converts a base 10 number to base 16.

    Args:
        value: Base 10 number.

    Returns:
        Base 16 number as a String.
    """

    var val: Float64 = 0.0
    var result: Float64 = value
    var base16: String = ""
    while result > 1:
        var temp = result / 16
        var floor_result = floor(temp)
        var remainder = temp - floor_result
        result = floor_result
        val = 16 * remainder

        base16 = BASE10_TO_BASE16[int(val)] + base16

    return base16


fn format_string(format: String, arg: String) -> String:
    var verb = find_first_verb(format, List[String]("%s", "%q"))
    var arg_to_place = arg
    if verb == "%q":
        arg_to_place = '"' + arg + '"'

    return replace_first(format, String("%s"), arg)


fn format_bytes(format: String, arg: List[Byte]) -> String:
    var argument = arg
    if argument[-1] != 0:
        argument.append(0)

    return format_string(format, argument)


fn format_integer(format: String, arg: Int) -> String:
    var verb = find_first_verb(format, List[String]("%x", "%X", "%d", "%q"))
    var arg_to_place = String(arg)
    if verb == "%x":
        arg_to_place = String(convert_base10_to_base16(arg)).lower()
    elif verb == "%X":
        arg_to_place = String(convert_base10_to_base16(arg)).upper()
    elif verb == "%q":
        arg_to_place = "'" + String(arg) + "'"

    return replace_first(format, verb, arg_to_place)


fn format_float(format: String, arg: Float64) -> String:
    return replace_first(format, String("%f"), arg)


fn format_boolean(format: String, arg: Bool) -> String:
    var value: String = "False"
    if arg:
        value = "True"

    return replace_first(format, String("%t"), value)


# If the number of arguments does not match the number of format specifiers
alias BadArgCount = "(BAD ARG COUNT)"


fn sprintf(formatting: String, *args: Args) -> String:
    var text = formatting
    var raw_percent_count = formatting.count("%%") * 2
    var formatter_count = formatting.count("%") - raw_percent_count

    if formatter_count != len(args):
        return BadArgCount

    for i in range(len(args)):
        var argument = args[i]
        if argument.isa[String]():
            text = format_string(text, argument[String])
        elif argument.isa[List[Byte]]():
            text = format_bytes(text, argument[List[Byte]])
        elif argument.isa[Int]():
            text = format_integer(text, argument[Int])
        elif argument.isa[Float64]():
            text = format_float(text, argument[Float64])
        elif argument.isa[Bool]():
            text = format_boolean(text, argument[Bool])

    return text


# TODO: temporary until we have arg packing.
fn sprintf_str(formatting: String, args: List[String]) raises -> String:
    var text = formatting
    var formatter_count = formatting.count("%")

    if formatter_count > len(args):
        raise Error("Not enough arguments for format string")
    elif formatter_count < len(args):
        raise Error("Too many arguments for format string")

    for i in range(len(args)):
        text = format_string(text, args[i])

    return text


fn printf(formatting: String, *args: Args) raises:
    var text = formatting
    var raw_percent_count = formatting.count("%%") * 2
    var formatter_count = formatting.count("%") - raw_percent_count

    if formatter_count > len(args):
        raise Error("Not enough arguments for format string")
    elif formatter_count < len(args):
        raise Error("Too many arguments for format string")

    for i in range(len(args)):
        var argument = args[i]
        if argument.isa[String]():
            text = format_string(text, argument[String])
        elif argument.isa[List[Byte]]():
            text = format_bytes(text, argument[List[Byte]])
        elif argument.isa[Int]():
            text = format_integer(text, argument[Int])
        elif argument.isa[Float64]():
            text = format_float(text, argument[Float64])
        elif argument.isa[Bool]():
            text = format_boolean(text, argument[Bool])
        else:
            raise Error("Unknown for argument #" + String(i))

    print(text)
