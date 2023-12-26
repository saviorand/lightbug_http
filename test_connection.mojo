"""
Establish a TCP connection. 
This can be done by initiating a connection to the server's IP and port and checking for a successful handshake.
"""

"""
Send and receive data over the TCP connection. 
Send a predefined set of data to the server and verify that the server receives and processes it correctly, and vice versa.
"""

"""
Handle multiple simultaneous TCP connections. 
This involves opening several connections at once and ensuring the server can manage them without dropping or mixing up data.
"""

"""
Handle idle connections.
Establish a connection and then remain idle for longer than the server’s timeout setting to ensure the server properly closes the connection.
"""

"""
TCP Keep-Alive.
Validate that it keeps the connection active during periods of inactivity as expected.
"""

"""
Port Reusability.
After the server is stopped, ensure that the TCP port it was using can be immediately reused. Validate that the server is not leaving the port in a TIME_WAIT state.
"""
