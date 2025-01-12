#!/bin/bash

echo "[INFO] Building mojo binaries.."

test_server() {
    (magic run mojo build -D LB_LOG_LEVEL=DEBUG -I . --debug-level full tests/integration/integration_test_server.mojo) || exit 1

    echo "[INFO] Starting Mojo server..."
    ./integration_test_server &

    sleep 5

    echo "[INFO] Testing server with Python client"
    magic run python3 tests/integration/integration_client.py

    kill $!
    wait $! 2>/dev/null

    rm ./integration_test_server
}

kill_fastapi() {
    pids=$(ps aux | grep "fastapi dev" | grep -v grep | awk '{print $2}')
    kill $(echo $pids | head -n 1)
    kill $(echo $pids | head -n 2)
}

test_client() {
    echo "[INFO] Testing Mojo client with Python server"
    (magic run mojo build -D LB_LOG_LEVEL=DEBUG -I . --debug-level full tests/integration/integration_test_client.mojo) || exit 1

    echo "[INFO] Starting Python server..."
    magic run fastapi dev tests/integration/integration_server.py &
    sleep 5

    ./integration_test_client
    rm ./integration_test_client
    kill_fastapi
}

test_server
test_client
