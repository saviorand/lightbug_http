from .reader import Reader
from .writer import Writer
from .read_writer import ReadWriter
from .scan import Scanner, scan_words, scan_bytes, scan_lines, scan_runes


alias MIN_READ_BUFFER_SIZE = 16
alias MAX_CONSECUTIVE_EMPTY_READS = 100

alias ERR_INVALID_UNREAD_BYTE = "bufio: invalid use of unread_byte"
alias ERR_INVALID_UNREAD_RUNE = "bufio: invalid use of unread_rune"
alias ERR_BUFFER_FULL = "bufio: buffer full"
alias ERR_NEGATIVE_COUNT = "bufio: negative count"
alias ERR_NEGATIVE_READ = "bufio: reader returned negative count from Read"
alias ERR_NEGATIVE_WRITE = "bufio: writer returned negative count from write"
