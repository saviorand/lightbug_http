import requests


# TODO: Pair with the Mojo integration server to test the client and server independently.
requests.get('http://127.0.0.1:8080/redirect', headers={'connection': 'keep-alive'})