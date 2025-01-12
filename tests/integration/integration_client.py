import requests


# TODO: Pair with the Mojo integration server to test the client and server independently.
print("\n~~~ Testing redirect ~~~")
session = requests.Session()
response = session.get('http://127.0.0.1:8080/redirect', allow_redirects=True)
assert response.status_code == 200
assert response.text == "yay you made it"

print("\n~~~ Testing close connection ~~~")
response = session.get('http://127.0.0.1:8080/close-connection', headers={'connection': 'close'})
assert response.status_code == 200
assert response.text == "connection closed"

print("\n~~~ Testing internal server error ~~~")
response = session.get('http://127.0.0.1:8080/error', headers={'connection': 'keep-alive'})
assert response.status_code == 500
