fn exit(code: Int):
    """Exits the program with the given exit code via libc.
    TODO: Using this in the meantime until Mojo has a built in way to panic/exit.
    """
    var status = external_call["exit", Int, Int](code)


fn panic[T: Stringable](message: T, code: Int = 1):
    """Panics the program with the given message and exit code.

    Args:
        message: The message to panic with.
        code: The exit code to panic with.
    """
    print("panic:", message)
    exit(code)
