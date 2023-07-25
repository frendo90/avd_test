#Création de C:\temp 
New-Item -itemtype directory -path "C:\temp"

#Start log
Start-Transcript C:\temp\perso_log.txt 
Write-Output 'Start log'

#Montage du partage SPPLMsources tant que VM pour récupérer les sources
Write-Output 'Montage du partage SPPLMsources tant que VM pour récupérer les sources'
New-PSDrive -Name S -PSProvider FileSystem -Root "\\rtapocavdsources.file.core.windows.net\spplmsources" -Persist

#Copie des sources dedans
Write-Output 'Copie des sources dedans'
Copy-Item "S:\Setups" -Destination "C:\temp" -recurse -wait

#Execution policy unrestricted
Write-Output 'Execution policy unrestricted'
Set-ExecutionPolicy unrestricted 

#Install Actcut
Write-Output 'Install Actcut'
start-process -filepath "C:\temp\Setups\Actcut 3.10.7.144467.exe" -ArgumentList "/noicons /log=C:\temp\log_actcut.txt /verysilent /suppressmsgboxes /norestart /forcecloseapplications /logcloseapplications" -ea:SilentlyContinue -verbose -wait

#Stop hasplms service isntalled by ActCut and uninstall Sentinel 9.6.0
Write-Output 'Stop hasplms service isntalled by ActCut and uninstall Sentinel 9.6.0'
sc.exe stop "hasplms" -ea:SilentlyContinue -verbose -wait
sc.exe delete "hasplms" -ea:SilentlyContinue -verbose -wait
Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq “Sentinel RMS License Manager 9.6.0”} | ? {$_.uninstall()} -ea:SilentlyContinue -verbose -wait

#Install Crystal Reports
Write-Output 'Install Crystal Reports'
start-process -filepath "C:\temp\Setups\CRRuntime_64bit_13_0_32.msi" -ArgumentList "/quiet" -ea:SilentlyContinue -verbose -wait   

#Install SPPLM
Write-Output 'Install SPPLM'
$spplm_installer=get-childitem -path "C:\temp\Setups" | where-object {$_.Name -match "Sp.setup*"} 
Start-Process -filepath "C:\temp\Setups\$spplm_installer" -ArgumentList "/silent" -ea:SilentlyContinue -verbose -wait

#Execution policy default
Write-Output 'Execution policy default'
Set-ExecutionPolicy default

#Erase folder "C:\temp\Setups"
Write-Output 'Erase folder "C:\temp\Setups"'
Remove-Item –path C:\temp\setups –recurse -ea:SilentlyContinue -verbose -wait

#Déconnexion du partage
Write-Output 'Déconnexion du partage'
Remove-PSDrive s

Write-Output 'End of the script'
 
Stop-Transcript