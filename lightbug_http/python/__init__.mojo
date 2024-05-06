from python import Python, PythonObject


@value
struct Modules:
    var builtins: PythonObject
    var socket: PythonObject

    fn __init__(inout self) -> None:
        self.builtins = self.__load_builtins()
        self.socket = self.__load_socket()

    @staticmethod
    fn __load_socket() -> PythonObject:
        try:
            var socket = Python.import_module("socket")
            return socket
        except e:
            print("Failed to import socket module")
            return None

    @staticmethod
    fn __load_builtins() -> PythonObject:
        try:
            var builtins = Python.import_module("builtins")
            return builtins
        except e:
            print("Failed to import builtins module")
            return None
