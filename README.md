# Install-Duo.ps1
This script will install Duo.

## Usage
Three arguments must be passed to this script in order for it to work.
Running this script should look like this:                                        
` C:\Install_Duo.ps1 -IKEY asdfasdfasdfasdf -SKEY fdsafdsafdsa -DuoHost host.duo.com `

### -IKEY 
Duo RDP application's Integration key.
### -SKEY 
DUO RDP application's secret key
### -DuoHOST 
Duo API hostname

## Deploy from RMM
Powershell one-liner for easy use in an RMM.

` $downloadURI = 'https://raw.githubusercontent.com/dweger-scripts/Install-Duo.ps1/main/Install-Duo.ps1'; $script = 'C:\temp\Install-Duo.ps1'; Invoke-WebRequest -URI $downloadURI -Outfile $script `

