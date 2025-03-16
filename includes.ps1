param (
    [string]$sourcePath
)

[xml]$vcxproj = Get-Content "${sourcePath}/Amalgam/Amalgam.vcxproj"

function Convert-WindowsPathToUnix {
    param (
        [string]$windowsPath
    )

    $unixPath = $windowsPath -replace '\\', '/'
    return $unixPath
}

# Remove existing files
Remove-Item -Path srcs.txt -ErrorAction SilentlyContinue
Remove-Item -Path lib_roots.txt -ErrorAction SilentlyContinue
Remove-Item -Path lib_names.txt -ErrorAction SilentlyContinue

New-Item srcs.txt
New-Item lib_roots.txt
New-Item lib_names.txt

$itemGroups = $vcxproj.Project.ItemGroup
foreach ($itemGroup in $itemGroups) {
    $clCompiles = $itemGroup.ClCompile
    if ($clCompiles) {
        foreach ($clCompile in $clCompiles) {
            $path = Convert-WindowsPathToUnix -windowsPath $clCompile.Include
            Add-Content -Path srcs.txt -Value "Amalgam/${path}"
        }
    }

    $libraries = $itemGroup.Library
    if ($libraries) {
        foreach ($library in $libraries) {
            $libDir = Split-Path -Parent -Path $library.Include
            $libName = Split-Path -Leaf -Path $library.Include
            $libName = $libName -replace '\.lib', ''
            $libDir = Convert-WindowsPathToUnix -windowsPath $libDir
            Add-Content -Path lib_roots.txt -Value "Amalgam/${libDir}"
            Add-Content -Path lib_names.txt -Value $libName
        }
    }
}