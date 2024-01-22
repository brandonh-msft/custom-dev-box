if([environment]::OSVersion.version.Major -ge 6) {
  # You cannot change the network location if you are joined to a domain, so abort
  if(1,3,4,5 -contains (Get-WmiObject win32_computersystem).DomainRole) { return }

  # Get network connections
  $networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
  $connections = $networkListManager.GetNetworkConnections()

  $connections |foreach {
    try{
        Write-Host $_.GetNetwork().GetName()"category was previously set to"$_.GetNetwork().GetCategory()
        $_.GetNetwork().SetCategory(1)
        Write-Host $_.GetNetwork().GetName()"changed to category"$_.GetNetwork().GetCategory()
    }
    catch {
    }
  }
}

Write-Output "Enabling PSRemoting"
Enable-PSRemoting -Force
winrm set winrm/config '@{MaxTimeoutms="7200000"}'
winrm set winrm/config/winrs '@{MaxShellsPerUser="100"}'
winrm set winrm/config/winrs '@{MaxConcurrentUsers="30"}'
winrm set winrm/config/winrs '@{MaxProcessesPerShell="100"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'