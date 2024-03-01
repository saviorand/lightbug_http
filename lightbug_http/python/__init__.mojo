from python import Python, PythonObject


@value
struct Modules:
    var builtins: PythonObject
    var socket: PythonObject

    fn __init__(inout self) raises -> None:
        self.builtins = self.__load_builtins()
        self.socket = self.__load_socket()

    @staticmethod
    fn __load_socket() raises -> PythonObject:
        var socket = Python.import_module("socket")
        return socket

    @staticmethod
    fn __load_builtins() raises -> PythonObject:
        var builtins = Python.import_module("builtins")
        return builtins
