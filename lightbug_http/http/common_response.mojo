fn OK(body: String) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, "text/plain")),
        body_bytes=bytes(body),
    )


fn OK(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, content_type)),
        body_bytes=bytes(body),
    )


fn OK(body: Bytes) -> HTTPResponse:
    return HTTPResponse(
        headers=Headers(Header(HeaderKey.CONTENT_TYPE, "text/plain")),
        body_bytes=body,
    )


fn OK(body: Bytes, content_type: String) -> HTTPResponse:
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
