from lightbug_http.io.fd import FileDescriptor
from memory.buffer import DynamicRankBuffer


fn test_fd_basic_io():
    """
    Test basic file descriptor I/O.
    Validates that the file descriptor can be opened, written to, and read from.
    """

    var file_path: StringLiteral = "./static/test.txt"

    # Open a file for writing
    var fd = FileDescriptor(file_path)

    # Writing to the file descriptor
    var data_to_write = "Hello, Mojo! 日本人 中國的 ~=[]()%+{}@;’#!$_&-  éè  ;∞¥₤€"  # Sample data to write, with non-ASCII characters
    try:
        var num_bytes_written = fd.write(data_to_write)
        print("Written bytes:" + num_bytes_written.__str__())
    except IOError:
        print("Error writing to file: (e)")

    # fd.__del__() is automatically called when fd goes out of scope
    var fd_read = FileDescriptor(file_path)

    # Reading from the file descriptor
    # Initialize a buffer for reading; ensure it's large enough for the expected data
    try:
        var content = fd_read.read()
        print("File contents:" + content)
    except IOError:
        print("Error reading from file: (e)")
    # fd_read.__del__() is automatically called when fd_read goes out of scope
