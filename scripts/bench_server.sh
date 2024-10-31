

magic run mojo build bench_server.mojo || exit 1

echo "running server..."
./bench_server&


sleep 2

echo "Running benchmark"
wrk -t1 -c1 -d10s http://0.0.0.0:8080/

kill $!
wait $! 2>/dev/null

rm bench_server