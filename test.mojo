import lightbug_http.rustls as rls
import os
from utils import StringSlice, Span
from collections import Optional, InlineArray
from memory import Arc

alias DEMO_OK = 0
alias DEMO_AGAIN = 1
alias DEMO_EOF = 2
alias DEMO_ERROR = 3


@value
struct ConnData:
    var fd: Int
    var verify_arg: String
    var data: List[UInt8]


fn log_cb(level: Int, message: StringSlice):
    print("Log level:", level, "Message:", message)



fn default_provider_with_custom_ciphersuite(
    custom_ciphersuite_name: StringSlice,
) raises -> rls.CryptoProvider:
    custom_ciphersuite = Optional[rls.SupportedCiphersuite]()
    for suite in rls.default_crypto_provider_ciphersuites():
        if not suite:
            raise Error("failed to get ciphersuite")
        if suite.get_name() == custom_ciphersuite_name:
            custom_ciphersuite = suite

    if not custom_ciphersuite:
        raise Error(
            "failed to select custom ciphersuite: "
            + str(custom_ciphersuite_name)
        )

    provider_builder = rls.CryptoProviderBuilder()
    providers = List(custom_ciphersuite.value())
    provider_builder.set_cipher_suites(providers)

    return provider_builder^.build()


fn main() raises:
    var cert_path = "/etc/ssl/cert.pem"
    if not os.setenv("CA_FILE", cert_path):
        raise Error("Failed to set CA_FILE environment variable")

    custom_provider = default_provider_with_custom_ciphersuite(
        "TLS13_CHACHA20_POLY1305_SHA256"
    )
    tls_versions = List[UInt16](0x0303, 0x0304)
    config_builder = rls.ClientConfigBuilder(custom_provider, tls_versions)
    server_cert_root_store_builder = rls.RootCertStoreBuilder()
    server_cert_root_store_builder.load_roots_from_file(cert_path)
    server_root_cert_store = server_cert_root_store_builder^.build()
    server_cert_verifier_builder = rls.WebPkiServerCertVerifierBuilder(
        server_root_cert_store
    )
    server_cert_verifier = server_cert_verifier_builder^.build()
    config_builder.set_server_verifier(server_cert_verifier)
    var alpn = List[Span[UInt8, StaticConstantLifetime]]("http/1.1".as_bytes_span())
    config_builder.set_alpn_protocols(alpn)
    client_config = config_builder^.build()
    host = "www.google.com"
    port = "443"
    path = "/"
    conn = rls.ClientConnection(client_config, host)
    # result = do_request(client_config, host, port, path)
