#!/bin/bash

(magic run mojo build integration_test_server.mojo) || exit 1
(magic run mojo build integration_test_client.mojo) || exit 1

echo "starting server..."
./integration_test_server &

sleep 5

echo "starting test suite"
./integration_test_client

kill $!
wait $! 2>/dev/null
echo "cleaning up binaries"
rm ./integration_test_server
rm ./integration_test_client