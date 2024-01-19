param([String]$account, [String]$share, [String]$key)

$connectTestResult = Test-NetConnection -ComputerName "${account}.file.core.windows.net" -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"${account}.file.core.windows.net`" /user:`"Azure\${account}`" /pass:`"${key}`""
    # Mount the drive
    New-PSDrive -Name S -PSProvider FileSystem -Root "\\${account}.file.core.windows.net\${share}" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}