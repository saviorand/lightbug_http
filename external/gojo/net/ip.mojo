from utils.variant import Variant
from utils.static_tuple import StaticTuple
from sys.info import os_is_linux, os_is_macos
from ..syscall import (
    c_int,
    c_char,
    c_void,
    c_uint,
    addrinfo,
    addrinfo_unix,
    AddressFamily,
    AddressInformation,
    SocketOptions,
    SocketType,
    ProtocolFamily,
    sockaddr,
    sockaddr_in,
    htons,
    ntohs,
    inet_pton,
    inet_ntop,
    getaddrinfo,
    getaddrinfo_unix,
    gai_strerror,
)
from .address import HostPort

alias AddrInfo = Variant[addrinfo, addrinfo_unix]


fn get_addr_info(host: String) raises -> AddrInfo:
    if os_is_macos():
        var servinfo = UnsafePointer[addrinfo]().alloc(1)
        servinfo[0] = addrinfo()
        var hints = addrinfo(
            ai_family=AddressFamily.AF_INET,
            ai_socktype=SocketType.SOCK_STREAM,
            ai_flags=AddressInformation.AI_PASSIVE,
        )

        var status = getaddrinfo(
            host.unsafe_ptr(),
            UnsafePointer[UInt8](),
            UnsafePointer.address_of(hints),
            UnsafePointer.address_of(servinfo),
        )
        if status != 0:
            print("getaddrinfo failed to execute with status:", status)

        if not servinfo:
            print("servinfo is null")
            raise Error("Failed to get address info. Pointer to addrinfo is null.")

        return servinfo.take_pointee()
    elif os_is_linux():
        var servinfo = UnsafePointer[addrinfo_unix]().alloc(1)
        servinfo[0] = addrinfo_unix()
        var hints = addrinfo_unix(
            ai_family=AddressFamily.AF_INET,
            ai_socktype=SocketType.SOCK_STREAM,
            ai_flags=AddressInformation.AI_PASSIVE,
        )

        var status = getaddrinfo_unix(
            host.unsafe_ptr(),
            UnsafePointer[UInt8](),
            UnsafePointer.address_of(hints),
            UnsafePointer.address_of(servinfo),
        )
        if status != 0:
            print("getaddrinfo failed to execute with status:", status)

        if not servinfo:
            print("servinfo is null")
            raise Error("Failed to get address info. Pointer to addrinfo is null.")

        return servinfo.take_pointee()
    else:
        raise Error("Windows is not supported yet! Sorry!")


fn get_ip_address(host: String) raises -> String:
    """Get the IP address of a host."""
    # Call getaddrinfo to get the IP address of the host.
    var result = get_addr_info(host)
    var ai_addr: UnsafePointer[sockaddr]
    var address_family: Int32 = 0
    var address_length: UInt32 = 0
    if result.isa[addrinfo]():
        var addrinfo = result[addrinfo]
        ai_addr = addrinfo.ai_addr
        address_family = addrinfo.ai_family
        address_length = addrinfo.ai_addrlen
    else:
        var addrinfo = result[addrinfo_unix]
        ai_addr = addrinfo.ai_addr
        address_family = addrinfo.ai_family
        address_length = addrinfo.ai_addrlen

    if not ai_addr:
        print("ai_addr is null")
        raise Error("Failed to get IP address. getaddrinfo was called successfully, but ai_addr is null.")

    # Cast sockaddr struct to sockaddr_in struct and convert the binary IP to a string using inet_ntop.
    var addr_in = ai_addr.bitcast[sockaddr_in]().take_pointee()

    return convert_binary_ip_to_string(addr_in.sin_addr.s_addr, address_family, address_length).strip()


fn convert_port_to_binary(port: Int) -> UInt16:
    return htons(UInt16(port))


fn convert_binary_port_to_int(port: UInt16) -> Int:
    return int(ntohs(port))


fn convert_ip_to_binary(ip_address: String, address_family: Int) -> UInt32:
    var ip_buffer = UnsafePointer[UInt8].alloc(4)
    var status = inet_pton(address_family, ip_address.unsafe_ptr(), ip_buffer)
    if status == -1:
        print("Failed to convert IP address to binary")

    return ip_buffer.bitcast[c_uint]().take_pointee()


fn convert_binary_ip_to_string(owned ip_address: UInt32, address_family: Int32, address_length: UInt32) -> String:
    """Convert a binary IP address to a string by calling inet_ntop.

    Args:
        ip_address: The binary IP address.
        address_family: The address family of the IP address.
        address_length: The length of the address.

    Returns:
        The IP address as a string.
    """
    # It seems like the len of the buffer depends on the length of the string IP.
    # Allocating 10 works for localhost (127.0.0.1) which I suspect is 9 bytes + 1 null terminator byte. So max should be 16 (15 + 1).
    var ip_buffer = UnsafePointer[c_void].alloc(16)
    var ip_address_ptr = UnsafePointer.address_of(ip_address).bitcast[c_void]()
    _ = inet_ntop(address_family, ip_address_ptr, ip_buffer, 16)

    var index = 0
    while True:
        if ip_buffer[index] == 0:
            break
        index += 1

    return StringRef(ip_buffer, index)


fn build_sockaddr_pointer(ip_address: String, port: Int, address_family: Int) -> UnsafePointer[sockaddr]:
    """Build a sockaddr pointer from an IP address and port number.
    https://learn.microsoft.com/en-us/windows/win32/winsock/sockaddr-2
    https://learn.microsoft.com/en-us/windows/win32/api/ws2def/ns-ws2def-sockaddr_in.
    """
    var bin_port = convert_port_to_binary(port)
    var bin_ip = convert_ip_to_binary(ip_address, address_family)

    var ai = sockaddr_in(address_family, bin_port, bin_ip, StaticTuple[c_char, 8]())
    return UnsafePointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()


fn convert_sockaddr_to_host_port(sockaddr: UnsafePointer[sockaddr]) -> (HostPort, Error):
    """Casts a sockaddr pointer to a sockaddr_in pointer and converts the binary IP and port to a string and int respectively.

    Args:
        sockaddr: The sockaddr pointer to convert.

    Returns:
        A tuple containing the HostPort and an Error if any occurred,.
    """
    if not sockaddr:
        return HostPort(), Error("sockaddr is null, nothing to convert.")

    # Cast sockaddr struct to sockaddr_in to convert binary IP to string.
    var addr_in = sockaddr.bitcast[sockaddr_in]().take_pointee()

    return (
        HostPort(
            host=convert_binary_ip_to_string(addr_in.sin_addr.s_addr, AddressFamily.AF_INET, 16),
            port=convert_binary_port_to_int(addr_in.sin_port),
        ),
        Error(),
    )
