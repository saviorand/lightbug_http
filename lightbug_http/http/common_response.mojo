from lightbug_http.io.bytes import Bytes

fn OK(body: String, content_type: String = "text/plain") -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, content_type)),
        body_bytes=bytes(body),
    )


fn OK(body: Bytes, content_type: String = "text/plain") -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, content_type)),
        body_bytes=body,
    )


fn OK(body: Bytes, content_type: String, content_encoding: String) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(
            Header(HeaderKey.CONTENT_TYPE, content_type),
            Header(HeaderKey.CONTENT_ENCODING, content_encoding),
        ),
        body_bytes=body,
    )


fn NotFound(path: String) -> HTTPResponse:
    return HTTPResponse(
        status_code=404,
        status_text="Not Found",
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, "text/plain")),
        body_bytes=bytes("path " + path + " not found"),
    )


fn InternalError() -> HTTPResponse:
    return HTTPResponse(
        bytes("Failed to process request"),
        status_code=500,
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, "text/plain")),
        status_text="Internal Server Error",
    )
