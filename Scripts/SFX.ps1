Write-Verbose -Message SFX -Verbose

# Download WinRAR and 7-Zip to expand winrar-x64-713.exe as WinRAR fails to install
# https://www.rarlab.com
New-Item -Path WinRAR -ItemType Directory -Force

$Parameters = @{
	Uri             = "https://www.rarlab.com/rar/winrar-x64-713.exe"
	OutFile         = "WinRAR\winrar-x64-713.exe"
	UseBasicParsing = $true
}
Invoke-WebRequest @Parameters

# Download the latest 7-Zip x64
$Parameters = @{
	Uri             = "https://sourceforge.net/projects/sevenzip/best_release.json"
	UseBasicParsing = $true
	Verbose         = $true
}
$bestRelease = (Invoke-RestMethod @Parameters).platform_releases.windows.filename.replace("exe", "msi")

$Parameters = @{
	Uri             = "https://unlimited.dl.sourceforge.net/project/sevenzip$($bestRelease)?viasf=1"
	OutFile         = "WinRAR\7Zip.msi"
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-WebRequest @Parameters

# Expand 7Zip.msi
$Arguments = @(
	"/a `"WinRAR\7Zip.msi`""
	"TARGETDIR=`"WinRAR\7zip`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

& "WinRAR\7zip\Files\7-Zip\7z.exe" x "WinRAR\winrar-x64-713.exe" -o"WinRAR"

# Get latest version tag for Windows 11
$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Sophia-Script-for-Windows/refs/heads/master/sophia_script_versions.json"
	UseBasicParsing = $true
}
$Latest_Release_Windows_11_PowerShell_5_1 = (Invoke-RestMethod @Parameters).Sophia_Script_Windows_11_PowerShell_5_1

(Get-Content -Path Scripts\SFX_config.txt -Encoding utf8NoBOM -Raw) | Foreach-Object -Process {$_ -replace "SophiaScriptVersion", $Latest_Release_Windows_11_PowerShell_5_1} | Set-Content -Path Scripts\SFX_config.txt -Encoding utf8NoBOM -Force

# Create SFX archive
& "WinRAR\Rar.exe" a -sfx -z"Scripts\SFX_config.txt" -ep1 -r "Sophia.Script.for.Windows.11.v$($Latest_Release_Windows_11_PowerShell_5_1)_WinGet.exe" "Sophia_Script_for_Windows_11_v$($Latest_Release_Windows_11_PowerShell_5_1)\*"
