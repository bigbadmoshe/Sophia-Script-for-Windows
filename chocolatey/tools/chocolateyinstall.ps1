﻿<#
	.SYNOPSIS
	Get direct URL of Sophia Script archive, depending on which Windows it is run on

	.SYNOPSIS
	For example, if you start script on Windows 11 you will start downloading Sophia Script for Windows 11

	.EXAMPLE To download for PowerShell 5.1
	choco install sophia --force -y

	.EXAMPLE To download for PowerShell 7
	choco install sophia --params "/PS7" --force -y
#>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Parameters = @{
	Uri             = "https://api.github.com/repos/farag2/Sophia-Script-for-Windows/releases/latest"
	UseBasicParsing = $true
}
$LatestGitHubRelease = (Invoke-RestMethod @Parameters).tag_name

if (-not $LatestGitHubRelease)
{
	Write-Warning -Message "https://api.github.com/repos/farag2/Sophia-Script-for-Windows/releases/latest is unreachable. Please fix connection or change your DNS records."
	Write-Information -MessageData "" -InformationAction Continue

	if ((Get-CimInstance -ClassName CIM_ComputerSystem).HypervisorPresent)
	{
		$DNS = (Get-NetRoute | Where-Object -FilterScript {$_.DestinationPrefix -eq "0.0.0.0/0"} | Get-NetAdapter | Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
	}
	else
	{
		$DNS = (Get-NetAdapter -Physical | Get-NetIPInterface -AddressFamily IPv4 | Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
	}
	Write-Warning -Message "Your DNS are $(if ($DNS.Count -gt 1) {$DNS -join ', '} else {$DNS})"

	pause
	exit
}

$Parameters = @{
	Uri             = "https://raw.githubusercontent.com/farag2/Sophia-Script-for-Windows/master/sophia_script_versions.json"
	UseBasicParsing = $true
}
$JSONVersions = Invoke-RestMethod @Parameters

$null = $packageParameters
$packageParameters = $env:chocolateyPackageParameters

switch ((Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber)
{
	"17763"
	{
		# Check for Windows 10 LTSC 2019
		if ((Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName) -match "LTSC 2019")
		{
			$LatestRelease = $JSONVersions.Sophia_Script_Windows_10_LTSC2019
			$URL = "https://github.com/farag2/Sophia-Script-for-Windows/releases/download/$LatestGitHubRelease/Sophia.Script.for.Windows.10.LTSC.2019.v$LatestRelease.zip"
			$Hash = "BFB0554FD186B52A391B4067F3186BCCD047C54C4A32D31DEE4D7891B04C2446"
		}
		else
		{
			Write-Verbose -Message "Windows version is not supported. Update your Windows" -Verbose

			# Receive updates for other Microsoft products when you update Windows
			(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")

			# Check for updates
			Start-Process -FilePath "$env:SystemRoot\System32\UsoClient.exe" -ArgumentList StartInteractiveScan

			# Open the "Windows Update" page
			Start-Process -FilePath "ms-settings:windowsupdate"

			pause
			exit
		}
	}
	"19044"
	{
		# Check for Windows 10 LTSC 2021
		if ((Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName) -match "LTSC 2021")
		{
			$LatestRelease = $JSONVersions.Sophia_Script_Windows_10_LTSC2021
			$URL = "https://github.com/farag2/Sophia-Script-for-Windows/releases/download/$LatestGitHubRelease/Sophia.Script.for.Windows.10.LTSC.2021.v$LatestRelease.zip"
			$hash = "9D73A8F5CDDA53BFBBF1DF7B9D503436DBDA205491EF71D174ED95931036D01E"
		}
		else
		{
			Write-Verbose -Message "Windows version is not supported. Update your Windows" -Verbose

			# Receive updates for other Microsoft products when you update Windows
			(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")

			# Check for updates
			Start-Process -FilePath "$env:SystemRoot\System32\UsoClient.exe" -ArgumentList StartInteractiveScan

			# Open the "Windows Update" page
			Start-Process -FilePath "ms-settings:windowsupdate"

			pause
			exit
		}
	}
	"19045"
	{
		if ($packageParameters)
		{
			if ($packageParameters.Contains('PS7'))
			{
				$LatestRelease = (Invoke-RestMethod @Parameters).Sophia_Script_Windows_10_PowerShell_7
				$URL = "https://github.com/farag2/Sophia-Script-for-Windows/releases/download/$LatestGitHubRelease/Sophia.Script.for.Windows.10.PowerShell.7.v$LatestRelease.zip"
				$Hash = "D77C427F20364A3CF037182FF143F3F631A735C997C14FAE7DACEEDE0F011BED"
			}
		}
		else
		{
			$LatestRelease = $JSONVersions.Sophia_Script_Windows_10_PowerShell_5_1
			$URL = "https://github.com/farag2/Sophia-Script-for-Windows/releases/download/$LatestGitHubRelease/Sophia.Script.for.Windows.10.v$LatestRelease.zip"
			$Hash = "0786B745C6C75FF1EEFBEF8970D66A1AA42EF2CDAEDE52255AD2AE9E9402CADF"
		}
	}
	{$_ -ge 26100}
	{
		# Check for Windows 11 LTSC 2024
		if ((Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName) -notmatch "LTSC 2024")
		{
			if ($packageParameters)
			{
				if ($packageParameters.Contains('PS7'))
				{
					$LatestRelease = $JSONVersions.Sophia_Script_Windows_11_PowerShell_7
					$URL = "https://github.com/farag2/Sophia-Script-for-Windows/releases/download/$LatestGitHubRelease/Sophia.Script.for.Windows.11.PowerShell.7.v$LatestRelease.zip"
					$Hash = "BE7BC1EEFC4D1099E3D0CD8085DBAFF703E1DA65A2947C4B3A448F5A04BCE130"
				}
			}
			else
			{
				$LatestRelease = $JSONVersions.Sophia_Script_Windows_11_PowerShell_5_1
				$URL = "https://github.com/farag2/Sophia-Script-for-Windows/releases/download/$LatestGitHubRelease/Sophia.Script.for.Windows.11.v$LatestRelease.zip"
				$Hash = "080F2CFE3A80BD91C3D713595F1263BE52F9A0E7A4AC51B2A0FB4E9E58420227"
			}
		}
		else
		{
			$LatestRelease = $JSONVersions.Sophia_Script_Windows_11_LTSC2024
			$URL = "https://github.com/farag2/Sophia-Script-for-Windows/releases/download/$LatestGitHubRelease/Sophia.Script.for.Windows.11.LTSC.2024.v$LatestRelease.zip"
			$Hash = "6C5B7FA807412B5BA89DC473ED2B7B6908A0D558C5E183D50804526BA7819E38"
		}
	}
}

# Downloads folder
$Downloads = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$packageArgs = @{
	packageName    = $env:ChocolateyPackageName
	unzipLocation  = $Downloads
	url            = $URL
	checksum64     = $Hash
	checksumType64 = "sha256"
}
Install-ChocolateyZipPackage @packageArgs
