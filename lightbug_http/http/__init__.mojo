from .common_response import *
from .response import *
from .request import *


@always_inline
fn encode(owned req: HTTPRequest) -> Bytes:
    return req._encoded()


@always_inline
fn encode(owned res: HTTPResponse) -> Bytes:
    return res._encoded()
