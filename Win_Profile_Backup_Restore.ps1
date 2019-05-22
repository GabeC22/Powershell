$choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes","&No")
while ( $true ) {
cls
##### *** Backup folder destination *** #####
##############################################################################################################
##############################################################################################################

$destination = "\\[server]\[Profile Backup Share]"

##############################################################################################################
##############################################################################################################


##### *** Folders Included in the Backup *** #####
##############################################################################################################
##############################################################################################################

 $folder = "Desktop",
        "Favorites",
        "Documents",
        "Music",
        "Pictures",
        "Videos",
        "Links",
        "AppData\Local\Mozilla",
        "AppData\Local\Google",
        "AppData\Roaming\Mozilla",
        "Appdata\Roaming\Microsoft\Signatures",
        "Appdata\Roaming\Microsoft\Templates",
        "Appdata\Roaming\Microsoft\Windows\Cookies"

##############################################################################################################
##############################################################################################################

# Backup or Restore
$confirmation = Read-Host "Would you like to backup a user profile or restore a user profile to a new computer? (Type: backup or restore)"


# Check for backup or restore
#######################################################
if($confirmation -eq "backup"){
    
    cls

    $RemoteComputer = Read-Host 'What computer do you want to backup?'
    Get-ChildItem \\$RemoteComputer\c$\Users | Select Name | Out-Host
    $username = Read-Host 'What user profile do you want to backup?'
    $userprofile = "\\$RemoteComputer\c$\Users\$username"
    $appData = "\\$RemoteComputer\c$\Users\$username\AppData"


    ##### Folder Check for Existance ########
    $destinationpath = "$destination\$username"
    $folderexists = Test-Path $destinationpath

        If($folderexists -eq "True"){

        write-host -ForegroundColor Red "*** The profile folder $sourcefolder already exists. ***"  

        Write-Host -ForegroundColor Cyan "Verify the files before potentially copying over them."

        Invoke-Item "$destination"

        Pause
        }
 
        ##### Backup Data ########

     write-host -ForegroundColor green "Backing up data from $RemoteComputer for $username"
 
         foreach ($f in $folder)
         { 
          $currentLocalFolder = $userprofile + "\" + $f
          $currentRemoteFolder = $destination + "\" + $username + "\" + $f
          $currentFolderSize = (Get-ChildItem -ErrorAction silentlyContinue $currentLocalFolder -Recurse -Force | Measure-Object -ErrorAction silentlyContinue -Property Length -Sum ).Sum / 1MB
          $currentFolderSizeRounded = [System.Math]::Round($currentFolderSize)
          write-host -ForegroundColor cyan "  $f... ($currentFolderSizeRounded MB)"
          Robocopy $currentLocalFolder $currentRemoteFolder /secfix /sec /XF *.ini /E /R:1 /W:1 | Out-Host
       }
        Get-WMIObject Win32_Printer -ComputerName $RemoteComputer -ErrorAction SilentlyContinue | Select Name, Location | Export-Csv "$destination\$username\Desktop\Install These Printers.csv" -NoTypeInformation
        write-host -ForegroundColor Red "Review ALL of the log files above."
        pause
        Get-ChildItem -Path "\\$RemoteComputer\c$\Users\$username"  | Select Name, Length, LastWriteTime | Out-Host
        Get-ChildItem -Path "\\$RemoteComputer\c$\"  | Select Name, Length, LastWriteTime | Out-Host
        write-host -ForegroundColor Red "Review the C:Drive and Home folder for files/folders that may need copied manually."
        Invoke-Item "\\$RemoteComputer\c$\"
        Invoke-item "$destinationpath"
        pause
        
}


    
###############################################################################################################
###############################################################################################################   

##### Restore Data ########
###############################################################################################################
    
If($confirmation -eq 'restore') {
  
        cls
        $source = $destination
        $newcomputer = Read-Host 'What is the name of the new computer?'
        Get-ChildItem $source | Select Name | Out-Host
        $userfolder = Read-Host 'Type the name of the profile you want to restore.'
        $sourcefolder = "$source\$userfolder"

        $destinationprofile = "\\$newcomputer\c$\Users\$userfolder"

        Robocopy $sourcefolder $destinationprofile /XF *.ini /E /XX /XO /R:1 /W:3 | Out-Host
        write-host -ForegroundColor Red "Review the log file that popped up on the screen."
        }
        
$choice = $Host.UI.PromptForChoice("Repeat the script?","",$choices,0)
  if ( $choice -ne 0 ) {
    break
  }
   }