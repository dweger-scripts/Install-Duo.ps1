Param (
	[string]$IKEY,
	[string]$SKEY,
	[string]$DuoHost
)
#*********************************************************************
#========================
#Install-Duo_v2.ps1
#========================
# This script will install Duo.
# Three arguments must be passed to this script in order for it to work.
# Running this script should look like this:
#  C:\Install_Duo_v2.ps1 -IKEY asdfasdfasdfasdf -SKEY fdsafdsafdsa -DuoHost host.duo.com
#========================
#Modified: 03.06.2023
#========================
#*********************************************************************
	#-------------------------------------------------
	# Variables
	#-------------------------------------------------
	#----Installer Variables
	$DownloadURI = "https://dl.duosecurity.com/DuoWinLogon_MSIs_Policies_and_Documentation-latest.zip"
	$DownloadPath = "C:\temp\Duo"
	$ZipName = "DuoWinLogon_MSIs_Policies_and_Documentation-latest.zip"
	$Zip = Join-Path $DownloadPath $ZipName
	$InstallerFolder = "Latest"
	$InstallerFullPath = Join-Path $DownloadPath $InstallerFolder
	$InstallerName = "DuoWindowsLogon64.msi"
	$Installer = Join-Path $InstallerFullPath $InstallerName
	#----Duo Specific variables
	# IKEY - Duo RDP application's Integration key.
	# SKEY - DUO RDP application's secret key
	# DuoHOST - Duo API hostname


	#----Logging specific variables
	# Where the log file should be stored.
	$LogFilePath = "C:\temp"
    # $RunTimestamp is the date/time the script was run.
	$RunTimestamp = get-date -Format "MM.dd.yyyy-HH_mm_ss"
	# $LogFileName is the name of the log file.
    $LogFileName = "DuoInstall-Log-" + $RunTimestamp + ".txt"
	# $Logfile describes the name of the log file located in the same folder as the script itself.
	$Logfile = Join-Path $LogFilePath $LogFileName
	#-------------------------------------------------

function Write-Log
{
	
	#-------------------------------------------------
	# This function allows us to write to the log file located at $Logfile.
	#-------------------------------------------------
	Param ([string]$logstring)
	Add-content $Logfile -value $logstring
	Write-Host $logstring
}
function TestArguments
{
	#-------------------------------------------------
	# This function checks to make sure the 3 required Duo install arguments have been passed to the script.
	#-------------------------------------------------	
	if($IKEY -eq $null){Write-Log "The IKEY variable was not passed to the script. Exiting the script.";Exit}
	if($SKEY -eq $null){Write-Log "The SKEY variable was not passed to the script. Exiting the script.";Exit}
	if($DuoHost -eq $null){Write-Log "The DuoHost variable was not passed to the script. Exiting the script.";Exit}
}
function TestForDuoInstall
{
	#-------------------------------------------------
	# This function will check for Duo DLLs and determine if the software is already installed.
	#-------------------------------------------------
	(Test-Path 'C:\Program Files\Duo Security\WindowsLogon\DuoCredProv.dll') -AND (Test-Path 'C:\Program Files\Duo Security\WindowsLogon\DuoCredFilter.dll')
}
	#-------------------------------------------------
	#Check Directories to make sure they exist
	#-------------------------------------------------
	
	if (!(Test-Path $LogFilePath)){new-item $LogFilePath -ItemType Directory}
	if (!(Test-Path $DownloadPath)) {New-Item -ItemType Directory -Path $DownloadPath}
	#-------------------------------------------------
	# Start the logging process
	#-------------------------------------------------

	Write-Log "======================================="
	Write-Log $(get-date)
    Write-Log $env:computername
	Write-Log "Log file: $LogFile"
	Write-Log $LogPathCreate
	Write-Log $InstallerPathCreate
	#-------------------------------------------------
#Check if Duo is already installed. Exit script if it already exists.
if (TestForDuoInstall) {Write-Log "Duo is already installed. Exiting the script.";Exit}
#else {Write-Log "Duo is not yet installed. Continuing the script."}

#Check if the required parameters were passed to the script.
TestArguments

#Download the latest DUO installer
#Write-Log "Attempting to Download the latest Duo installer."
Invoke-WebRequest -URI $DownloadURI -Outfile $Zip
#if($?) {Write-Log "Successfully downloaded the installer."}
if(!$?) {Write-Log "Did NOT download the installer. Exiting the script.";Exit}

#Unzip the Duo zip file.
#Write-Log "Attempting to unzip the Duo zip file."
if (Test-Path $Zip) {Expand-Archive -Path $Zip $InstallerFullPath}
Test-Path $Installer
#if($?){Write-Log "Successfully unzipped the Duo zip file. $Installer exists."}
if(!$?){Write-Log "Error unzipping the Duo zip file. Exiting the script.";Exit}

#Install Duo
#Write-Log "Attemping to install Duo."
msiexec /i $Installer IKEY=$IKEY SKEY=$SKEY Host=$DuoHost AutoPush="#1" FailOpen="#1" RDPOnly="#0" SmartCard="#0" UAC_PROTECTMODE="#2" UAC_OFFLINE="#1" UAC_OFFLINE_ENROLL="#1"
if($?){Write-Log "msiexec command ran successfully."}
if(!$?){Write-Log "msiexec command did not run successfully."}

#Test for successful install.
Start-Sleep -Seconds 60
if(TestForDuoInstall){Write-Log "Duo was installed successfully."}
else {Write-Log "Duo was not installed successfully. Further investigation is required."}

$AllLogText = Get-Content $Logfile
return $AllLogText
