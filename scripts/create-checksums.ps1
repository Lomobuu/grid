#Requires -Version 5.1
<#
.SYNOPSIS
    Generates _checksums.sha256 for a KA Terraform ISO package.

.DESCRIPTION
    Writes the manifest in the same format the vendor produces:

        <sha256>  ./relative/path

    Lowercase hex, two spaces, forward slashes, LF line endings and no BOM,
    so that "sha256sum --check" on the Linux runner accepts it.

    Given a zip, the manifest is generated from the archive contents and
    written back into the zip, replacing any manifest already in there.
    Given a folder, the manifest is written into the folder.

.EXAMPLE
    .\create-checksums.ps1 vendor-package\KA-Terraform-ISO-6.30.3582.zip

.EXAMPLE
    .\create-checksums.ps1 C:\temp\extracted-package
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ManifestName = '_checksums.sha256'

try { Add-Type -AssemblyName System.IO.Compression.FileSystem } catch { }

function Get-StreamSha256 {
    param([System.IO.Stream] $Stream)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $sha.ComputeHash($Stream)
    }
    finally {
        $sha.Dispose()
    }

    return (($bytes | ForEach-Object { $_.ToString('x2') }) -join '')
}

function Get-FileSha256 {
    param([string] $FilePath)

    $stream = [System.IO.File]::OpenRead($FilePath)
    try {
        return Get-StreamSha256 $stream
    }
    finally {
        $stream.Dispose()
    }
}

# Hashtable of relative path -> hash becomes the manifest text.
function Format-Manifest {
    param([hashtable] $Hashes)

    if ($Hashes.Count -eq 0) {
        throw "No files found to hash."
    }

    $names = [string[]] $Hashes.Keys
    [Array]::Sort($names, [System.StringComparer]::Ordinal)

    $lines = foreach ($name in $names) { "$($Hashes[$name])  ./$name" }

    return (($lines -join "`n") + "`n")
}

# Line layout: 64 hex chars, two spaces, "./", then the path.
function Read-Manifest {
    param([string] $Text)

    foreach ($line in ($Text -split "`r?`n")) {
        if ($line.Length -gt 68) {
            [pscustomobject]@{
                Hash = $line.Substring(0, 64)
                Name = $line.Substring(68)
            }
        }
    }
}

function Update-Folder {
    param([string] $Folder)

    $root = (Resolve-Path -LiteralPath $Folder).Path.TrimEnd('\', '/')
    $hashes = @{}

    # -Force so dotfiles and hidden files are included, as find(1) would.
    Get-ChildItem -LiteralPath $root -Recurse -File -Force |
        Where-Object { $_.Name -ne $ManifestName } |
        ForEach-Object {
            $relative = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
            $hashes[$relative] = Get-FileSha256 $_.FullName
        }

    $text = Format-Manifest $hashes
    $manifestPath = Join-Path $root $ManifestName

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($manifestPath, $text, $utf8NoBom)

    # Re-read what landed on disk and re-hash every file it lists.
    $checked = 0
    foreach ($entry in (Read-Manifest ([System.IO.File]::ReadAllText($manifestPath)))) {
        $actual = Get-FileSha256 (Join-Path $root $entry.Name)
        if ($actual -ne $entry.Hash) {
            throw "Verification failed for $($entry.Name)."
        }
        $checked++
    }

    Write-Host "Hashed and verified $checked files"
    Write-Host "Wrote $manifestPath"
}

function Update-Zip {
    param([string] $ZipPath)

    $full = (Resolve-Path -LiteralPath $ZipPath).Path
    $hashes = @{}

    $zip = [System.IO.Compression.ZipFile]::Open(
        $full, [System.IO.Compression.ZipArchiveMode]::Update)
    try {
        # Snapshot the entries, since adding and deleting mutates the collection.
        foreach ($entry in @($zip.Entries)) {
            $name = $entry.FullName.Replace('\', '/')

            if ($name.EndsWith('/')) { continue }

            if ($name -eq $ManifestName) {
                $entry.Delete()
                continue
            }

            $stream = $entry.Open()
            try {
                $hashes[$name] = Get-StreamSha256 $stream
            }
            finally {
                $stream.Dispose()
            }
        }

        $bytes = [System.Text.Encoding]::UTF8.GetBytes((Format-Manifest $hashes))

        $manifestEntry = $zip.CreateEntry($ManifestName)
        $out = $manifestEntry.Open()
        try {
            $out.Write($bytes, 0, $bytes.Length)
        }
        finally {
            $out.Dispose()
        }
    }
    finally {
        $zip.Dispose()
    }

    # Reopen the written zip and re-hash every entry the manifest lists.
    $checked = 0
    $zip = [System.IO.Compression.ZipFile]::OpenRead($full)
    try {
        $reader = New-Object System.IO.StreamReader($zip.GetEntry($ManifestName).Open())
        try {
            $text = $reader.ReadToEnd()
        }
        finally {
            $reader.Dispose()
        }

        foreach ($entry in (Read-Manifest $text)) {
            $stream = $zip.GetEntry($entry.Name).Open()
            try {
                $actual = Get-StreamSha256 $stream
            }
            finally {
                $stream.Dispose()
            }

            if ($actual -ne $entry.Hash) {
                throw "Verification failed for $($entry.Name)."
            }
            $checked++
        }
    }
    finally {
        $zip.Dispose()
    }

    Write-Host "Hashed and verified $checked files"
    Write-Host "Added $ManifestName to $full"
}

if (Test-Path -LiteralPath $Path -PathType Container) {
    Update-Folder $Path
}
elseif ((Test-Path -LiteralPath $Path -PathType Leaf) -and $Path -like '*.zip') {
    Update-Zip $Path
}
else {
    throw "Not a folder or a .zip file: $Path"
}
