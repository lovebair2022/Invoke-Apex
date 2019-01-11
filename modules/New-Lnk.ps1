function New-Lnk {
<#

.SYNOPSIS 
 Generates an LNK file with a custom command in current users' StartUp directory.

.PARAMETER Help
 Displays Help

.PARAMETER BaseCmd
 The base executable without arguments, i.e., cmd.exe, powershell.exe, etc..

.PARAMETER CmdArgs
 The arguments for the base executable, i.e., "/c start ..."

.PARAMETER IconNum
 This is the number of the icon as it appears in shell32.dll. A reference chart can be found here: https://help4windows.com/windows_7_shell32_dll.shtml

.PARAMETER LnkName
 The name of the resulting LNK file without the .lnk extension.

.EXAMPLE
 New-Lnk -BaseCmd "cmd.exe" -CmdArgs "/c foo" -IconNum 220 -LnkName "IE Update"

 Author: (@0rbz_)
#>

[CmdletBinding()]
param (

	[Parameter(ParameterSetName = 'Help', Position=1)]
	[Switch]$Help,
	[Parameter()]
	[String]$BaseCmd,
	[Parameter()]
	[String]$CmdArgs,
	[Parameter()]
	[String]$IconNum,
	[Parameter()]
	[String]$LnkName
)

#$TimeSource = (Get-Item "C:\??*?\*3?\c??.?x?").FullName

	if ($Help) {
		Write @"
 -------------------------------------------------------------------------------		
 Generates an LNK file in current users' StartUp directory.
 
 -BaseCmd = The base executable, i.e., cmd.exe, powershell.exe, etc..
 -CmdArgs = Command line arguments for BaseCmd.
 -IconNum = The icon number as it appears in shell32.dll.
 -LnkName = The name of the LNK file.
 
 Ex: New-Lnk -BaseCmd "cmd.exe" -CmdArgs "/c foo" -IconNum 220 -LnkName "Update"
 -------------------------------------------------------------------------------
 
"@
	}
	
	elseif ($BaseCmd -and $CmdArgs -and $IconNum -and $LnkName) {
		Try {
			$StartUp = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup"
			$Command = "$BaseCmd"
			$Wss = New-Object -ComObject WScript.Shell
			$LnkCr = $Wss.CreateShortcut("$StartUp\$LnkName.lnk")
			$LnkCr.TargetPath = $Command
			$LnkCr.Arguments = "$CmdArgs"
			#$LnkCr.Description ="" # comment field
			$LnkCr.IconLocation = "shell32.dll,$IconNum"
			$LnkCr.Save()
			
#			[IO.File]::SetCreationTime("$StartUp\$LnkName.lnk", [IO.File]::GetCreationTime($TimeSource))
#			[IO.File]::SetLastAccessTime("$StartUp\$LnkName.lnk", [IO.File]::GetLastAccessTime($TimeSource))
#			[IO.File]::SetLastWriteTIme("$StartUp\$LnkName.lnk", [IO.File]::GetLastWriteTime($TimeSource))
			Write " [+] LNK file created with command '$basecmd $CmdArgs' and LNK name '$LnkName.lnk'`n"
		}
		Catch {
			Write " [!] Unknown Error. Does $Startup directory exist?"
		}
	}
}
