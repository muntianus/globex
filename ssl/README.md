SSL Certificates

Place your TLS certificates here for nginx container.

Expected files (example):
- fullchain.pem
- privkey.pem

Local self-signed (development only):
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout privkey.pem -out fullchain.pem -subj "/CN=localhost"

Update nginx.conf ssl_certificate and ssl_certificate_key paths if names differ.

