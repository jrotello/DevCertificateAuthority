try {
    Push-Location $PSScriptRoot\..\

    Remove-Item certs, crl, csr, newcerts, pfx, private -Recurse -ErrorAction Ignore
    Remove-Item index.txt*, serial, serial.old -ErrorAction Ignore
} finally {
    Pop-Location
}