from sys import exit


fn panic[T: Stringable](message: T, code: Int = 1):
    """Panics the program with the given message and exit code.

    Args:
        message: The message to panic with.
        code: The exit code to panic with.
    """
    print("panic:", str(message))
    exit(code)
