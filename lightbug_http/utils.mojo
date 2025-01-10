from memory import memcpy, Span
from lightbug_http.io.bytes import Bytes, Byte
from lightbug_http.strings import BytesConstant
from lightbug_http.net import default_buffer_size


@always_inline
fn is_newline(b: Byte) -> Bool:
    return b == BytesConstant.nChar or b == BytesConstant.rChar


@always_inline
fn is_space(b: Byte) -> Bool:
    return b == BytesConstant.whitespace


struct ByteWriter(Writer):
    var _inner: Bytes

    fn __init__(out self, capacity: Int = default_buffer_size):
        self._inner = Bytes(capacity=capacity)
    
    @always_inline
    fn write_bytes(mut self, bytes: Span[Byte]) -> None:
        """Writes the contents of `bytes` into the internal buffer.

        Args:
            bytes: The bytes to write.
        """
        self._inner.extend(bytes)
    
    fn write[*Ts: Writable](mut self, *args: *Ts) -> None:
        """Write data to the `Writer`.

        Parameters:
            Ts: The types of data to write.

        Args:
            args: The data to write.
        """
        @parameter
        fn write_arg[T: Writable](arg: T):
            arg.write_to(self)

        args.each[write_arg]()

    @always_inline
    fn consuming_write(mut self, owned b: Bytes):
        self._inner.extend(b^)

    @always_inline
    fn consuming_write(mut self, owned s: String):
        # kind of cursed but seems to work?
        _ = s._buffer.pop()
        self._inner.extend(s._buffer^)
        s._buffer = s._buffer_type()

    @always_inline
    fn write_byte(mut self, b: Byte):
        self._inner.append(b)

    fn consume(mut self) -> Bytes:
        var ret = self._inner^
        self._inner = Bytes()
        return ret^


alias EndOfReaderError = "No more bytes to read."
alias OutOfBoundsError = "Tried to read past the end of the ByteReader."


struct ByteReader[origin: Origin]:
    var _inner: Span[Byte, origin]
    var read_pos: Int

    fn __init__(out self, ref b: Span[Byte, origin]):
        self._inner = b
        self.read_pos = 0
    
    @always_inline
    fn available(self) -> Bool:
        return self.read_pos < len(self._inner)
    
    fn __len__(self) -> Int:
        return len(self._inner) - self.read_pos

    fn peek(self) raises -> Byte:
        if not self.available():
            raise EndOfReaderError
        return self._inner[self.read_pos]
    
    fn read_bytes(mut self, n: Int = -1) raises -> Span[Byte, origin]:
        var count = n
        var start = self.read_pos
        if n == -1:
            count = len(self)

        if start+ count > len(self._inner):
            raise OutOfBoundsError
        
        self.read_pos += count
        return self._inner[start : start + count]

    fn read_until(mut self, char: Byte) -> Span[Byte, origin]:
        var start = self.read_pos
        for i in range(start, len(self._inner)):
            if self._inner[i] == char:
                break
            self.increment()

        return self._inner[start : self.read_pos]

    @always_inline
    fn read_word(mut self) -> Span[Byte, origin]:
        return self.read_until(BytesConstant.whitespace)

    fn read_line(mut self) -> Span[Byte, origin]:
        var start = self.read_pos
        for i in range(start, len(self._inner)):
            if is_newline(self._inner[i]):
                break
            self.increment()
    
        # If we are at the end of the buffer, there is no newline to check for.
        var ret = self._inner[start : self.read_pos]
        if not self.available():
            return ret
        
        if self._inner[self.read_pos] == BytesConstant.rChar:
            self.increment(2)
        else:
            self.increment()
        return ret

    @always_inline
    fn skip_whitespace(mut self):
        for i in range(self.read_pos, len(self._inner)):
            if not is_space(self._inner[i]):
                break
            self.increment()

    @always_inline
    fn skip_carriage_return(mut self):
        for i in range(self.read_pos, len(self._inner)):
            if self._inner[i] != BytesConstant.rChar:
                break
            self.increment(2)

    @always_inline
    fn increment(mut self, v: Int = 1):
        self.read_pos += v

    @always_inline
    fn consume(owned self, bytes_len: Int = -1) -> Bytes:
        return self^._inner[self.read_pos : self.read_pos + len(self) + 1]


struct LogLevel():
    alias FATAL = 0
    alias ERROR = 1
    alias WARN = 2
    alias INFO = 3
    alias DEBUG = 4


@value
struct Logger():
    var level: Int

    fn __init__(out self, level: Int = LogLevel.INFO):
        self.level = level

    fn _log_message(self, message: String, level: Int):
        if self.level >= level:
            if level < LogLevel.WARN:
                print(message, file=2)
            else:
                print(message)

    fn info[*Ts: Writable](self, *messages: *Ts):
        var msg = String.write("\033[36mINFO\033[0m  - ")
        @parameter
        fn write_message[T: Writable](message: T):
            msg.write(message, " ")
        messages.each[write_message]()
        self._log_message(msg, LogLevel.INFO)

    fn warn[*Ts: Writable](self, *messages: *Ts):
        var msg = String.write("\033[33mWARN\033[0m  - ")
        @parameter
        fn write_message[T: Writable](message: T):
            msg.write(message, " ")
        messages.each[write_message]()
        self._log_message(msg, LogLevel.WARN)

    fn error[*Ts: Writable](self, *messages: *Ts):
        var msg = String.write("\033[31mERROR\033[0m - ")
        @parameter
        fn write_message[T: Writable](message: T):
            msg.write(message, " ")
        messages.each[write_message]()
        self._log_message(msg, LogLevel.ERROR)

    fn debug[*Ts: Writable](self, *messages: *Ts):
        var msg = String.write("\033[34mDEBUG\033[0m - ")
        @parameter
        fn write_message[T: Writable](message: T):
            msg.write(message, " ")
        messages.each[write_message]()
        self._log_message(msg, LogLevel.DEBUG)

    fn fatal[*Ts: Writable](self, *messages: *Ts):
        var msg = String.write("\033[35mFATAL\033[0m - ")
        @parameter
        fn write_message[T: Writable](message: T):
            msg.write(message, " ")
        messages.each[write_message]()
        self._log_message(msg, LogLevel.FATAL)


alias logger = Logger(LogLevel.DEBUG)
# alias logger = Logger()
