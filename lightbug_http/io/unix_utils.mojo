from lightbug_http.io.fd import FileDescriptor


struct EventData:
    var fd: FileDescriptor
    var io_flag: Atomic[DType.bool]
