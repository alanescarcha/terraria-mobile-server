$path = Convert-Path .\TerrariaServer.exe

if(-not (Test-Path $path)) {
    $path = Convert-Path ".\Terraria Server.app\Contents\MacOS\TerrariaServer.exe"
}

if(-not (Test-Path $path)) {
    throw "Could not find the TerrariaServer.exe file. Make sure TerrariaServer.exe or Terraria Server.app is in the same folder you're running this script in."
}

$hash = (Get-FileHash -Path $path).Hash
$ps5? = (($PSVersionTable).PSVersion).Major -lt 6

[byte[]]$bytes = if($ps5?) {Get-Content -Path $path -Encoding Byte -Raw} else {Get-Content -Path $path -AsByteStream -Raw}

if($hash -eq "43EDFA6D295AE4A4D219D74F074AA102485DD87A4D04D1DB3FC7FCBAB9A8EEDF") {
    # Windows
    $offset = 0x0864C1
} elseif($hash -eq "8FFACB9F96D167B86639B5A43E2EF7DAB9C0E6336D98043E0ED21DCA928058A9") {
    # MacOS
    $offset = 0x086519
} elseif($hash -eq "E0B29869D4082AC8AAA6AD52BBC1B2CBC2E9E45C9964CA3949ABD419639786D5") {
    # Linux
    $offset = 0x086519
} else {
    throw "The TerrariaServer.exe that was found is not a version that can be patched."
}

$bytes[$offset] = 0x15

if($ps5?) {
    Set-Content -Path $path -Encoding Byte -Value $bytes
} else {
    Set-Content -Path $path -AsByteStream -Value $bytes
}

Write-Information "TerrariaServer.exe patched successfully." -InformationAction Continue