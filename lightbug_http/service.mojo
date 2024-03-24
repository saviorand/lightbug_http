from lightbug_http.http import HTTPRequest, HTTPResponse, OK


trait HTTPService:
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        ...


@value
struct Printer(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var body = req.body_raw
        print(String(body))

        return OK(body)


@value
struct Welcome(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var html: String
        with open("static/lightbug_welcome.html", "r") as f:
            html = f.read()

        return OK(html.as_bytes(), "text/html")


@value
struct ExampleRouter(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var body = req.body_raw
        var uri = req.uri()

        if uri.path() == "/":
            print("I'm on the index path!")
        if uri.path() == "/first":
            print("I'm on /first!")
        elif uri.path() == "/second":
            print("I'm on /second!")
        elif uri.path() == "/echo":
            print(String(body))

        return OK(body)


@value
struct TechEmpowerRouter(HTTPService):
    fn func(self, req: HTTPRequest) raises -> HTTPResponse:
        var body = req.body_raw
        var uri = req.uri()

        if uri.path() == "/plaintext":
            return OK(String("Hello, World!").as_bytes(), "text/plain")
        elif uri.path() == "/json":
            return OK(
                String('{"message": "Hello, World!"}').as_bytes(), "application/json"
            )

        return OK(String("Hello world!").as_bytes(), "text/plain")
