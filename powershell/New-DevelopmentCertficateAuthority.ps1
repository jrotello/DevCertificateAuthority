param(
    [Parameter(Mandatory = $true)]
    [string]
    $SupportEmail
)

try {
    Push-Location $PSScriptRoot\..\

    .\powershell\Set-DevelopmentCertificateEnvironment.ps1

    mkdir certs, crl, csr, newcerts, pfx, private -Force | Out-Null

    $null | Out-File .\index.txt -Encoding ascii
    1000 | Out-File .\serial -Encoding ascii

    Write-Host "Generating private key for CA...." -ForegroundColor Yellow
    openssl genrsa -aes256 -out .\private\ca.key.pem 4096

    Write-Host "Generating self-signed CA certificate...." -ForegroundColor Yellow

    $ENV:__CERT_ORG_UNIT_NAME   = "$($ENV:__CERT_ORG_NAME) Certificate Authority"
    $ENV:__CERT_COMMON_NAME     = "$($ENV:__CERT_ORG_NAME) CA"
    $ENV:__CERT_EMAIL_ADDRESS   = $SupportEmail
    $ENV:__CERT_SUBJECT_ALT_NAME = "email:$SupportEmail"

    openssl req -config .\openssl.cnf `
                -key .\private\ca.key.pem `
                -new `
                -x509 `
                -days 7300 `
                -sha256 `
                -extensions v3_ca `
                -out .\certs\ca.cert.pem
} finally {
    .\powershell\Clear-DevelopmentCertificateEnvironment.ps1
    Pop-Location
}