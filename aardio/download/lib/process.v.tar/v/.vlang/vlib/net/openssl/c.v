module openssl

// On Linux, prefer a localy built openssl, because it is
// much more likely for it to be newer, than the system
// openssl from libssl-dev. If there is no local openssl,
// the next flag is harmless, since it will still use the
// (older) system openssl.
#flag linux -I/usr/local/include/openssl -L/usr/local/lib
#flag windows -l libssl -l libcrypto
#flag -lssl -lcrypto
#flag linux -ldl -lpthread
// MacPorts
#flag darwin -I/opt/local/include
#flag darwin -L/opt/local/lib
// Brew
#flag darwin -I/usr/local/opt/openssl/include
#flag darwin -L/usr/local/opt/openssl/lib
// Brew arm64
#flag darwin -I /opt/homebrew/opt/openssl/include
#flag darwin -L /opt/homebrew/opt/openssl/lib
//
#include <openssl/rand.h> # Please install OpenSSL development headers
#include <openssl/ssl.h>
#include <openssl/err.h>

pub struct C.SSL {
}

pub struct SSL_CTX {
}

pub struct SSL {
}

pub struct SSL_METHOD {
}

pub struct OPENSSL_INIT_SETTINGS {
}

fn C.BIO_new_ssl_connect(ctx &C.SSL_CTX) &C.BIO

fn C.BIO_set_conn_hostname(b &C.BIO, name &char) int

// there are actually 2 macros for BIO_get_ssl
// fn C.BIO_get_ssl(bp &C.BIO, ssl charptr, c int)
// fn C.BIO_get_ssl(bp &C.BIO, sslp charptr)
fn C.BIO_get_ssl(bp &C.BIO, vargs ...voidptr)

fn C.BIO_do_connect(b &C.BIO) int

fn C.BIO_do_handshake(b &C.BIO) int

fn C.BIO_puts(b &C.BIO, buf &char)

fn C.BIO_read(b &C.BIO, buf voidptr, len int) int

fn C.BIO_free_all(a &C.BIO)

fn C.SSL_CTX_new(method &C.SSL_METHOD) &C.SSL_CTX

fn C.SSL_CTX_set_options(ctx &C.SSL_CTX, options int)

fn C.SSL_CTX_set_verify_depth(s &C.SSL_CTX, depth int)

fn C.SSL_CTX_load_verify_locations(ctx &C.SSL_CTX, ca_file &char, ca_path &char) int

fn C.SSL_CTX_free(ctx &C.SSL_CTX)

fn C.SSL_new(&C.SSL_CTX) &C.SSL

fn C.SSL_set_fd(ssl &C.SSL, fd int) int

fn C.SSL_connect(&C.SSL) int

fn C.SSL_set_cipher_list(ctx &SSL, str &char) int

fn C.SSL_get_peer_certificate(ssl &SSL) &C.X509

fn C.ERR_clear_error()

fn C.SSL_get_error(ssl &C.SSL, ret int) int

fn C.SSL_get_verify_result(ssl &SSL) int

fn C.SSL_set_tlsext_host_name(s &SSL, name &char) int

fn C.SSL_shutdown(&C.SSL) int

fn C.SSL_free(&C.SSL)

fn C.SSL_write(ssl &C.SSL, buf voidptr, buflen int) int

fn C.SSL_read(ssl &C.SSL, buf voidptr, buflen int) int

fn C.SSL_load_error_strings()

fn C.SSL_library_init() int

fn C.SSLv23_client_method() &C.SSL_METHOD

fn C.TLS_method() voidptr

fn C.TLSv1_2_method() voidptr

fn C.OPENSSL_init_ssl(opts u64, settings &OPENSSL_INIT_SETTINGS) int

fn init() {
	$if ssl_pre_1_1_version ? {
		// OPENSSL_VERSION_NUMBER < 0x10100000L
		C.SSL_load_error_strings()
		C.SSL_library_init()
	} $else {
		C.OPENSSL_init_ssl(C.OPENSSL_INIT_LOAD_SSL_STRINGS, 0)
	}
}

pub const (
	is_used = 1
)