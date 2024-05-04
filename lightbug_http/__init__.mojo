from lightbug_http.http import HTTPRequest, HTTPResponse, OK
from lightbug_http.service import HTTPService, Welcome
from lightbug_http.sys.server import SysServer


trait DefaultConstructible:
    fn __init__(inout self) raises:
        ...
