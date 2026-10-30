#Requires -Modules Hooks
#Requires -Modules Logging

# Installs the ns/ mod directory into Server/ from an ENSL release zip.
# Server/ns is treated as pristine: customizations belong in Overlay/ns.

Invoke-Hook "PreInstallNaturalSelection"

$nsUrl = $Env:NS_URL

if (-not $nsUrl) {
    $nsUrl = "https://github.com/ENSL/NS/releases/download/${Env:NS_VERSION}/ns_$($Env:NS_VERSION -replace '\.', '')_full.zip"
}

$nsDir = "$Env:SERVER_DIR/ns"
$markerFile = "$nsDir/.lancommander-ns-url"

if ((Test-Path -Path "$nsDir/dlls/ns.so") -and (Test-Path -Path $markerFile) -and ((Get-Content -Path $markerFile -Raw).Trim() -eq $nsUrl)) {
    Write-Log "Natural Selection is already installed from $nsUrl. Skipping."
    return
}

$archive = "/tmp/ns.zip"

Write-Log "Downloading Natural Selection from $nsUrl"
curl -fsSL --output $archive "$nsUrl"

if ($LASTEXITCODE -ne 0) {
    Write-Log -Level Error "Failed to download Natural Selection (curl exit code $LASTEXITCODE)"
    return
}

if (Test-Path -Path $nsDir) {
    Write-Log "Removing previous Natural Selection install"
    Remove-Item -Path $nsDir -Recurse -Force
}

Write-Log "Extracting Natural Selection to $Env:SERVER_DIR"
unzip -q -o $archive "ns/*" -d $Env:SERVER_DIR

if ($LASTEXITCODE -ne 0) {
    Write-Log -Level Error "Failed to extract Natural Selection (unzip exit code $LASTEXITCODE)"
    return
}

Remove-Item -Path $archive -Force
Set-Content -Path $markerFile -Value $nsUrl -NoNewline

Invoke-Hook "PostInstallNaturalSelection"
