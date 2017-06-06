try {
    Push-Location $PSScriptRoot\..\

    mkdir certs, crl, csr, newcerts, pfx, private -Force | Out-Null

    $null | Out-File .\index.txt -Encoding ascii
    1000 | Out-File .\serial -Encoding ascii

    openssl genrsa -aes256 -out .\private\ca.key.pem 4096

    openssl req -config .\openssl.cnf `
                -key .\private\ca.key.pem `
                -new `
                -x509 `
                -days 7300 `
                -sha256 `
                -extensions v3_ca `
                -out .\certs\ca.cert.pem
} finally {
    Pop-Location
}