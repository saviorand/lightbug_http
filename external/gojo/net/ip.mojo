from utils.variant import Variant
from sys.info import os_is_linux, os_is_macos
from ..syscall.types import (
    c_int,
    c_char,
    c_void,
    c_uint,
)
from ..syscall.net import (
    addrinfo,
    addrinfo_unix,
    AF_INET,
    SOCK_STREAM,
    AI_PASSIVE,
    sockaddr,
    sockaddr_in,
    htons,
    ntohs,
    inet_pton,
    inet_ntop,
    getaddrinfo,
    getaddrinfo_unix,
    gai_strerror,
    to_char_ptr,
    c_charptr_to_string,
)

alias AddrInfo = Variant[addrinfo, addrinfo_unix]


fn get_addr_info(host: String) raises -> AddrInfo:
    var status: Int32 = 0
    if os_is_macos():
        var servinfo = Pointer[addrinfo]().alloc(1)
        servinfo.store(addrinfo())
        var hints = addrinfo()
        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_STREAM
        hints.ai_flags = AI_PASSIVE

        var host_ptr = to_char_ptr(host)

        var status = getaddrinfo(
            host_ptr,
            Pointer[UInt8](),
            Pointer.address_of(hints),
            Pointer.address_of(servinfo),
        )
        if status != 0:
            print("getaddrinfo failed to execute with status:", status)
            var msg_ptr = gai_strerror(c_int(status))
            _ = external_call["printf", c_int, Pointer[c_char], Pointer[c_char]](
                to_char_ptr("gai_strerror: %s"), msg_ptr
            )
            var msg = c_charptr_to_string(msg_ptr)
            print("getaddrinfo error message: ", msg)

        if not servinfo:
            print("servinfo is null")
            raise Error("Failed to get address info. Pointer to addrinfo is null.")

        return servinfo.load()
    elif os_is_linux():
        var servinfo = Pointer[addrinfo_unix]().alloc(1)
        servinfo.store(addrinfo_unix())
        var hints = addrinfo_unix()
        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_STREAM
        hints.ai_flags = AI_PASSIVE

        var host_ptr = to_char_ptr(host)

        var status = getaddrinfo_unix(
            host_ptr,
            Pointer[UInt8](),
            Pointer.address_of(hints),
            Pointer.address_of(servinfo),
        )
        if status != 0:
            print("getaddrinfo failed to execute with status:", status)
            var msg_ptr = gai_strerror(c_int(status))
            _ = external_call["printf", c_int, Pointer[c_char], Pointer[c_char]](
                to_char_ptr("gai_strerror: %s"), msg_ptr
            )
            var msg = c_charptr_to_string(msg_ptr)
            print("getaddrinfo error message: ", msg)

        if not servinfo:
            print("servinfo is null")
            raise Error("Failed to get address info. Pointer to addrinfo is null.")

        return servinfo.load()
    else:
        raise Error("Windows is not supported yet! Sorry!")


fn get_ip_address(host: String) raises -> String:
    """Get the IP address of a host."""
    # Call getaddrinfo to get the IP address of the host.
    var result = get_addr_info(host)
    var ai_addr: Pointer[sockaddr]
    var address_family: Int32 = 0
    var address_length: UInt32 = 0
    if result.isa[addrinfo]():
        var addrinfo = result.get[addrinfo]()
        ai_addr = addrinfo[].ai_addr
        address_family = addrinfo[].ai_family
        address_length = addrinfo[].ai_addrlen
    else:
        var addrinfo = result.get[addrinfo_unix]()
        ai_addr = addrinfo[].ai_addr
        address_family = addrinfo[].ai_family
        address_length = addrinfo[].ai_addrlen

    if not ai_addr:
        print("ai_addr is null")
        raise Error("Failed to get IP address. getaddrinfo was called successfully, but ai_addr is null.")

    # Cast sockaddr struct to sockaddr_in struct and convert the binary IP to a string using inet_ntop.
    var addr_in = ai_addr.bitcast[sockaddr_in]().load()

    return convert_binary_ip_to_string(addr_in.sin_addr.s_addr, address_family, address_length).strip()


fn convert_port_to_binary(port: Int) -> UInt16:
    return htons(UInt16(port))


fn convert_binary_port_to_int(port: UInt16) -> Int:
    return int(ntohs(port))


fn convert_ip_to_binary(ip_address: String, address_family: Int) -> UInt32:
    var ip_buffer = Pointer[c_void].alloc(4)
    var status = inet_pton(address_family, to_char_ptr(ip_address), ip_buffer)
    if status == -1:
        print("Failed to convert IP address to binary")

    return ip_buffer.bitcast[c_uint]().load()


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
    var ip_buffer = Pointer[c_void].alloc(16)
    var ip_address_ptr = Pointer.address_of(ip_address).bitcast[c_void]()
    _ = inet_ntop(address_family, ip_address_ptr, ip_buffer, 16)

    var string_buf = ip_buffer.bitcast[Int8]()
    var index = 0
    while True:
        if string_buf[index] == 0:
            break
        index += 1

    return StringRef(string_buf, index)


fn build_sockaddr_pointer(ip_address: String, port: Int, address_family: Int) -> Pointer[sockaddr]:
    """Build a sockaddr pointer from an IP address and port number.
    https://learn.microsoft.com/en-us/windows/win32/winsock/sockaddr-2
    https://learn.microsoft.com/en-us/windows/win32/api/ws2def/ns-ws2def-sockaddr_in.
    """
    var bin_port = convert_port_to_binary(port)
    var bin_ip = convert_ip_to_binary(ip_address, address_family)

    var ai = sockaddr_in(address_family, bin_port, bin_ip, StaticTuple[c_char, 8]())
    return Pointer[sockaddr_in].address_of(ai).bitcast[sockaddr]()
