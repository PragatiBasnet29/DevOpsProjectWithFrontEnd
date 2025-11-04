# Generate self-signed certificate for btnhd.com (testing/development)
# For production, use a certificate from a Certificate Authority (CA)

$certPath = "C:\Users\USER\Desktop\DevOpsProject\nginx\ssl"
$keyFile = Join-Path $certPath "btnhd.com.key"
$certFile = Join-Path $certPath "btnhd.com.crt"

# Create certificate using PowerShell (requires Windows 10/Server 2016+)
$cert = New-SelfSignedCertificate `
    -Subject "CN=btnhd.com" `
    -DnsName "btnhd.com", "www.btnhd.com", "localhost" `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -NotAfter (Get-Date).AddYears(1)

# Export the private key
$certPassword = ConvertTo-SecureString -String "temp" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath (Join-Path $certPath "temp.pfx") -Password $certPassword | Out-Null

# Export certificate and key in PEM format
# Note: This requires OpenSSL or alternative method
Write-Host "Certificate created in certificate store: $($cert.Thumbprint)"
Write-Host ""
Write-Host "To export as PEM format, you have two options:"
Write-Host ""
Write-Host "Option 1: Use OpenSSL (if installed)"
Write-Host "  openssl pkcs12 -in $certPath\temp.pfx -nocerts -nodes -out $keyFile -passin pass:temp"
Write-Host "  openssl pkcs12 -in $certPath\temp.pfx -clcerts -nokeys -out $certFile -passin pass:temp"
Write-Host ""
Write-Host "Option 2: Use online converter or certificate manager"
Write-Host ""
Write-Host "For production, obtain btnhd.com.crt from your Certificate Authority"

