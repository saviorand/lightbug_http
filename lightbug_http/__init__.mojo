from lightbug_http.http import HTTPRequest, HTTPResponse, OK, NotFound
from lightbug_http.uri import URI
from lightbug_http.service import HTTPService, Welcome
from lightbug_http.sys.server import SysServer
from lightbug_http.strings import to_string

trait DefaultConstructible:
    fn __init__(inout self) raises:
        ...
