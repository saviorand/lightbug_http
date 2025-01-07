import requests


requests.get('http://127.0.0.1:8080/redirect', headers={'connection': 'keep-alive'})