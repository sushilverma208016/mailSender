
Function Send-EMail {
    Param (
        [Parameter(`
            Mandatory=$true)]
        [String]$EmailTo,
        [Parameter(`
            Mandatory=$true)]
        [String]$Subject,
        [Parameter(`
            Mandatory=$true)]
        [String]$Body,
        [Parameter(`
            Mandatory=$true)]
        [String]$Password,
		[Parameter(`
            Mandatory=$true)]
        [String]$EmailFrom,
		[Parameter(`
            Mandatory=$true)]
        [String]$SMTPServer
    )

	$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25) 
	$SMTPClient.EnableSsl = $true
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $Password); 
	$SMTPClient.Send($SMTPMessage)
	Remove-Variable -Name SMTPClient
	Remove-Variable -Name Password
}

Send-EMail -EmailTo $args[0] -Subject $args[1] -Body $args[2] -password $args[3] -EmailFrom $args[4] -SMTPServer $args[5]
