param(
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]
    $CommonName
)

try {
    Push-Location $PSScriptRoot\..\

    .\powershell\Set-DevelopmentCertificateEnvironment.ps1

    $keypath    = ".\private\$($CommonName).key.pem"
    $csrpath    = ".\csr\$($CommonName).csr.pem"
    $certpath   = ".\certs\$($CommonName).cert.crt"
    $pfxpath    = ".\pfx\$($CommonName).pfx"
    $cacertpath = ".\certs\ca.cert.pem"

    $subjectAltNames = ,"DNS:$CommonName"
    # $Hostnames | ForEach-Object {
    #     $subjectAltNames += "DNS:$_"
    # }

    Write-Host "Generating key for CN=$($CommonName)..." -ForegroundColor Yellow
    $ENV:__CERT_COMMON_NAME = $CommonName
    $ENV:__CERT_SUBJECT_ALT_NAME = $subjectAltNames -join ', '
    openssl genrsa -aes256 -out $keypath

    Write-Host "Generating certificate signing request for CN=$($CommonName)..." -ForegroundColor Yellow
    openssl req -config .\openssl.cnf `
                -key $keypath `
                -new `
                -sha256 `
                -out $csrpath

    Write-Host "Signing certificate for CN=$($CommonName)..." -ForegroundColor Yellow
    openssl ca -config .\openssl.cnf `
               -extensions server_cert `
               -days 1825 `
               -notext `
               -md sha256 `
               -in $csrpath `
               -out $certpath

    Write-Host "Verifying certificate with CN=$($CommonName) against certificate authority..." -ForegroundColor Yellow
    openssl verify -CAfile $cacertpath $certpath

    Write-Host "Exporting PFX for CN=$($CommonName) at $($pfxpath)..." -ForegroundColor Yellow
    openssl pkcs12 -export `
                   -out $pfxpath `
                   -inkey $keypath `
                   -in $certpath `
                   -certfile $cacertpath
} finally {
    .\powershell\Clear-DevelopmentCertificateEnvironment.ps1
    Pop-Location
}