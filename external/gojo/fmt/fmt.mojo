"""Formatting options
General
%v	the value in a default format
    when printing structs, the plus flag (%+v) adds field names

Boolean
%t	the word true or false

Integer
%d	base 10

Floating-point and complex constituents:
%f	decimal point but no exponent, e.g. 123.456

String and slice of bytes (treated equivalently with these verbs):
%s	the uninterpreted bytes of the string or slice

TODO:
- Add support for more formatting options
- Switch to buffered writing to avoid multiple string concatenations
- Add support for width and precision formatting options
"""

from utils.variant import Variant


alias Args = Variant[String, Int, Float64, Bool]


fn replace_first(s: String, old: String, new: String) -> String:
    """Replace the first occurrence of a substring in a string.

    Parameters:
    s (str): The original string
    old (str): The substring to be replaced
    new (str): The new substring

    Returns:
    String: The string with the first occurrence of the old substring replaced by the new one.
    """
    # Find the first occurrence of the old substring
    var index = s.find(old)

    # If the old substring is found, replace it
    if index != -1:
        return s[:index] + new + s[index + len(old) :]

    # If the old substring is not found, return the original string
    return s


fn format_string(s: String, arg: String) -> String:
    return replace_first(s, String("%s"), arg)


fn format_integer(s: String, arg: Int) -> String:
    return replace_first(s, String("%d"), arg)


fn format_float(s: String, arg: Float64) -> String:
    return replace_first(s, String("%f"), arg)


fn format_boolean(s: String, arg: Bool) -> String:
    var value: String = ""
    if arg:
        value = "True"
    else:
        value = "False"

    return replace_first(s, String("%t"), value)


fn sprintf(formatting: String, *args: Args) raises -> String:
    var text = formatting
    var formatter_count = formatting.count("%")

    if formatter_count > len(args):
        raise Error("Not enough arguments for format string")
    elif formatter_count < len(args):
        raise Error("Too many arguments for format string")

    for i in range(len(args)):
        var argument = args[i]
        if argument.isa[String]():
            text = format_string(text, argument.get[String]()[])
        elif argument.isa[Int]():
            text = format_integer(text, argument.get[Int]()[])
        elif argument.isa[Float64]():
            text = format_float(text, argument.get[Float64]()[])
        elif argument.isa[Bool]():
            text = format_boolean(text, argument.get[Bool]()[])
        else:
            raise Error("Unknown for argument #" + String(i))

    return text


fn printf(formatting: String, *args: Args) raises:
    var text = formatting
    var formatter_count = formatting.count("%")

    if formatter_count > len(args):
        raise Error("Not enough arguments for format string")
    elif formatter_count < len(args):
        raise Error("Too many arguments for format string")

    for i in range(len(args)):
        var argument = args[i]
        if argument.isa[String]():
            text = format_string(text, argument.get[String]()[])
        elif argument.isa[Int]():
            text = format_integer(text, argument.get[Int]()[])
        elif argument.isa[Float64]():
            text = format_float(text, argument.get[Float64]()[])
        elif argument.isa[Bool]():
            text = format_boolean(text, argument.get[Bool]()[])
        else:
            raise Error("Unknown for argument #" + String(i))

    print(text)
