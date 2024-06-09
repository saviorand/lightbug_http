import requests
import time

npacket = 1000 # nr of packets to send in for loop

# URL of the server
url = "http://localhost:8080"

# Send the data as a POST request to the server
# response = requests.post(url, data=data)
headers = {'Content-Type': 'application/octet-stream'}

nbyte = 128

# for i in range(4):
for i in range(4):
    nbyte = 10*nbyte
    data = bytes([0x0A] * nbyte)


    tic = time.perf_counter()
    for i in range(npacket):
        # print( f"packet {i}")
        response = requests.post(url, data=data, headers=headers)
        try:
            # Get the response body as bytes
            response_bytes = response.content

        except Exception as e:
            print("Error parsing server response:", e)

    toc = time.perf_counter()

    dt = toc-tic
    packet_rate = npacket/dt
    bit_rate = packet_rate*nbyte*8

    print("=======================")
    print(f"packet size {nbyte} Bytes:")
    print("=========================")
    print(f"Sent and received {npacket} packets in {toc - tic:0.4f} seconds")
    print(f"Packet rate {packet_rate/1000:.2f} kilo packets/s")
    print(f"Bit rate {bit_rate/1e6:.1f}  Mbps")
