from python import Python


fn py_dt_datetime() raises -> PythonObject:
    var _datetime = Python.import_module("datetime")
    return _datetime.datetime


fn py_time() raises -> PythonObject:
    var _time = Python.import_module("time")
    return _time
