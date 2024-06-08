from lightbug_http.http import HTTPRequest, HTTPResponse, ResponseHeader

### Helper functions to create HTTP responses
fn Success(body: String) -> HTTPResponse:
    return Success(body, String("text/plain"))

fn Success(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 200, String("Success").as_bytes(), content_type.as_bytes()),
        body.as_bytes(),
    )

fn NotFound(body: String) -> HTTPResponse:
    return NotFound(body, String("text/plain"))

fn NotFound(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 404, String("Not Found").as_bytes(), content_type.as_bytes()),
        body.as_bytes(),
    )

fn InternalServerError(body: String) -> HTTPResponse:
   return InternalServerError(body, String("text/plain"))

fn InternalServerError(body: String, content_type: String) -> HTTPResponse:
    return HTTPResponse(
        ResponseHeader(True, 500, String("Internal Server Error").as_bytes(), content_type.as_bytes()),
        body.as_bytes(),
    )

fn Unauthorized(body: String) -> HTTPResponse:
    return Unauthorized(body, String("text/plain"))

fn Unauthorized(body: String, content_type: String) -> HTTPResponse:
    var header = ResponseHeader(True, 401, String("Unauthorized").as_bytes(), content_type.as_bytes())
    # TODO: currently no way to set headers or cookies 
    # header.headers["WWW-Authenticate"] = "Basic realm=\"Login Required\""

    return HTTPResponse(
        header,
        body.as_bytes(),
    )
