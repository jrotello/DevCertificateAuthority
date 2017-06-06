param(
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]
    $Hostname
)

try {
    Push-Location $PSScriptRoot\..\

    $keypath = ".\private\$($Hostname).key.pem"
    $csrpath = ".\csr\$($Hostname).csr.pem"
    $certpath = ".\certs\$($Hostname).cert.crt"
    $pfxpath = ".\pfx\$($Hostname).pfx"

    $cacertpath = ".\certs\ca.cert.pem"

    openssl genrsa -aes256 -out $keypath

    openssl req -config .\openssl.cnf `
                -key $keypath `
                -new `
                -sha256 `
                -out $csrpath

    openssl ca -config .\openssl.cnf `
               -extensions server_cert `
               -days 1825 `
               -notext `
               -md sha256 `
               -in $csrpath `
               -out $certpath

    openssl verify -CAfile $cacertpath $certpath

    openssl pkcs12 -export `
                   -out $pfxpath `
                   -inkey $keypath `
                   -in $certpath `
                   -certfile $cacertpath
} finally {
    Pop-Location
}