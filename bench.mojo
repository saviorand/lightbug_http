from benchmark import *
from lightbug_http.io.bytes import bytes, Bytes
from lightbug_http.header import Headers, Header
from lightbug_http.utils import ByteReader, ByteWriter
from lightbug_http.http import HTTPRequest, HTTPResponse, encode
from lightbug_http.uri import URI
from tests.utils import (
    TestStruct,
    FakeResponder,
    new_fake_listener,
    FakeServer,
)

alias headers = bytes(
    """GET /index.html HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n"""
)
alias body = bytes(String("I am the body of an HTTP request") * 5)
alias Request = bytes(
    """GET /index.html HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Mozilla/5.0\r\nContent-Type: text/html\r\nContent-Length: 1234\r\nConnection: close\r\nTrailer: end-of-message\r\n\r\n"""
) + body
alias Response = bytes(
    "HTTP/1.1 200 OK\r\nserver: lightbug_http\r\ncontent-type:"
    " application/octet-stream\r\nconnection: keep-alive\r\ncontent-length:"
    " 13\r\ndate: 2024-06-02T13:41:50.766880+00:00\r\n\r\n"
) + body


fn main():
    run_benchmark()


fn run_benchmark():
    try:
        var config = BenchConfig(warmup_iters=100)
        config.verbose_timing = True
        config.tabular_view = True
        var m = Bench(config)
        m.bench_function[lightbug_benchmark_header_encode](
            BenchId("HeaderEncode")
        )
        m.bench_function[lightbug_benchmark_header_parse](
            BenchId("HeaderParse")
        )
        m.bench_function[lightbug_benchmark_request_encode](
            BenchId("RequestEncode")
        )
        m.bench_function[lightbug_benchmark_request_parse](
            BenchId("RequestParse")
        )
        m.bench_function[lightbug_benchmark_response_encode](
            BenchId("ResponseEncode")
        )
        m.bench_function[lightbug_benchmark_response_parse](
            BenchId("ResponseParse")
        )
        m.dump_report()
    except:
        print("failed to start benchmark")


var headers_struct = Headers(
    Header("Content-Type", "application/json"),
    Header("Content-Length", "1234"),
    Header("Connection", "close"),
    Header("Date", "some-datetime"),
    Header("SomeHeader", "SomeValue"),
)


@parameter
fn lightbug_benchmark_response_encode(inout b: Bencher):
    @always_inline
    @parameter
    fn response_encode():
        var res = HTTPResponse(body, headers=headers_struct)
        _ = encode(res^)

    b.iter[response_encode]()


@parameter
fn lightbug_benchmark_response_parse(inout b: Bencher):
    @always_inline
    @parameter
    fn response_parse():
        var res = Response
        try:
            _ = HTTPResponse.from_bytes(res^)
        except:
            pass

    b.iter[response_parse]()


@parameter
fn lightbug_benchmark_request_parse(inout b: Bencher):
    @always_inline
    @parameter
    fn request_parse():
        var r = Request
        try:
            _ = HTTPRequest.from_bytes("127.0.0.1/path", 4096, r^)
        except:
            pass

    b.iter[request_parse]()


@parameter
fn lightbug_benchmark_request_encode(inout b: Bencher):
    @always_inline
    @parameter
    fn request_encode():
        var req = HTTPRequest(
            URI.parse("http://127.0.0.1:8080/some-path")[URI],
            headers=headers_struct,
            body=body,
        )
        _ = encode(req^)

    b.iter[request_encode]()


@parameter
fn lightbug_benchmark_header_encode(inout b: Bencher):
    @always_inline
    @parameter
    fn header_encode():
        var b = ByteWriter()
        var h = headers_struct
        h.encode_to(b)

    b.iter[header_encode]()


@parameter
fn lightbug_benchmark_header_parse(inout b: Bencher):
    @always_inline
    @parameter
    fn header_parse():
        try:
            var b = headers
            var header = Headers()
            var reader = ByteReader(b^)
            _ = header.parse_raw(reader)
        except:
            print("failed")

    b.iter[header_parse]()


fn lightbug_benchmark_server():
    var server_report = benchmark.run[run_fake_server](max_iters=1)
    print("Server: ")
    server_report.print(benchmark.Unit.ms)


fn lightbug_benchmark_misc() -> None:
    var direct_set_report = benchmark.run[init_test_and_set_a_direct](
        max_iters=1
    )

    var recreating_set_report = benchmark.run[init_test_and_set_a_copy](
        max_iters=1
    )

    print("Direct set: ")
    direct_set_report.print(benchmark.Unit.ms)
    print("Recreating set: ")
    recreating_set_report.print(benchmark.Unit.ms)


var GetRequest = HTTPRequest(URI.parse("http://127.0.0.1/path")[URI])


fn run_fake_server():
    var handler = FakeResponder()
    var listener = new_fake_listener(2, encode(GetRequest))
    var server = FakeServer(listener, handler)
    server.serve()


fn init_test_and_set_a_copy() -> None:
    var test = TestStruct("a", "b")
    _ = test.set_a_copy("c")


fn init_test_and_set_a_direct() -> None:
    var test = TestStruct("a", "b")
    _ = test.set_a_direct("c")
