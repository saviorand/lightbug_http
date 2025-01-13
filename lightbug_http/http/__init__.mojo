from .common_response import *
from .response import *
from .request import *
from .http_version import HttpVersion


trait Encodable:
    fn encode(owned self) -> Bytes:
        ...


@always_inline
fn encode[T: Encodable](owned data: T) -> Bytes:
    return data^.encode()
