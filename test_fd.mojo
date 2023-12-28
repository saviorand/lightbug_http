from mojoweb.io.fd import FileDescriptor
from memory.buffer import DynamicRankBuffer


fn main():
    let file_path: StringLiteral = "./test.txt"

    # Open a file for writing
    let fd = FileDescriptor(file_path)

    # Writing to the file descriptor
    let data_to_write = "Hello, Mojo! 日本人 中國的 ~=[]()%+{}@;’#!$_&-  éè  ;∞¥₤€"  # Sample data to write, with non-ASCII characters
    try:
        let num_bytes_written = fd.write(data_to_write)
        print("Written bytes:" + num_bytes_written.__str__())
    except IOError:
        print("Error writing to file: (e)")

    # fd.__del__() is automatically called when fd goes out of scope
    let fd_read = FileDescriptor(file_path)

    # Reading from the file descriptor
    # Initialize a buffer for reading; ensure it's large enough for the expected data
    try:
        let content = fd_read.read()
        print("File contents:" + content)
    except IOError:
        print("Error reading from file: (e)")
    # fd_read.__del__() is automatically called when fd_read goes out of scope
