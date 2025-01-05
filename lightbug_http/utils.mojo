from lightbug_http.io.bytes import Bytes, Byte
from lightbug_http.strings import BytesConstant
from lightbug_http.net import default_buffer_size
from memory import memcpy


@always_inline
fn is_newline(b: Byte) -> Bool:
    return b == BytesConstant.nChar or b == BytesConstant.rChar


@always_inline
fn is_space(b: Byte) -> Bool:
    return b == BytesConstant.whitespace


struct ByteWriter:
    var _inner: Bytes

    fn __init__(out self):
        self._inner = Bytes(capacity=default_buffer_size)

    @always_inline
    fn write(mut self, owned b: Bytes):
        self._inner.extend(b^)

    @always_inline
    fn write(mut self, mut s: String):
        # kind of cursed but seems to work?
        _ = s._buffer.pop()
        self._inner.extend(s._buffer^)
        s._buffer = s._buffer_type()

    @always_inline
    fn write(mut self, s: StringLiteral):
        var str = String(s)
        self.write(str)

    @always_inline
    fn write(mut self, b: Byte):
        self._inner.append(b)

    fn consume(mut self) -> Bytes:
        var ret = self._inner^
        self._inner = Bytes()
        return ret^


struct ByteReader:
    var _inner: Bytes
    var read_pos: Int

    fn __init__(out self, owned b: Bytes):
        self._inner = b^
        self.read_pos = 0

    fn peek(self) -> Byte:
        if self.read_pos >= len(self._inner):
            return 0
        return self._inner[self.read_pos]

    fn read_until(mut self, char: Byte) -> Bytes:
        var start = self.read_pos
        while self.peek() != char:
            self.increment()
        logger.info("start", start, "read_pos", self.read_pos, len(self._inner))
        logger.info(chr(int(self._inner[0])), chr(int(self._inner[1])), chr(int(self._inner[2])), chr(int(self._inner[3])))
        logger.info(self._inner[start : self.read_pos].__str__())
        return self._inner[start : self.read_pos]

    @always_inline
    fn read_word(mut self) -> Bytes:
        return self.read_until(BytesConstant.whitespace)

    fn read_line(mut self) -> Bytes:
        var start = self.read_pos
        while not is_newline(self.peek()):
            self.increment()
        var ret = self._inner[start : self.read_pos]
        if self.peek() == BytesConstant.rChar:
            self.increment(2)
        else:
            self.increment()
        return ret

    @always_inline
    fn skip_whitespace(mut self):
        while is_space(self.peek()):
            self.increment()

    @always_inline
    fn skip_newlines(mut self):
        while self.peek() == BytesConstant.rChar:
            self.increment(2)

    @always_inline
    fn increment(mut self, v: Int = 1):
        self.read_pos += v

    @always_inline
    fn consume(mut self, mut buffer: Bytes, bytes_len: Int = -1):
        var pos = self.read_pos
        var read_len: Int
        if bytes_len == -1:
            self.read_pos = -1
            read_len = len(self._inner) - pos
        else:
            self.read_pos += bytes_len
            read_len = bytes_len

        buffer.resize(read_len, 0)
        memcpy(buffer.data, self._inner.data + pos, read_len)


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


alias logger = Logger()
