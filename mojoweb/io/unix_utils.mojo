alias RawFd = Int32


struct EventData:
    var fd: RawFd
    var io_flag: Atomic[DType.bool]
