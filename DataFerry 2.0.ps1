#DataFerry - Data Transfer GUI Script
#Ver 2.0
#Capable of transfering drive data 

#GUI:
Function GUI{
#Hiding the PowerShell window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)


#User name for displaying and utilizing functions
    $CurrentUser = [System.Environment]::UserName


#Starting status
    $Global:Stat = "No Drive Selected"


#Button script status code
    $Global:Progress = 0


#PowerShell GUI initialization
    Add-Type -AssemblyName System.Windows.Forms

#Form creation 
    $TransferInterfaceForm = New-Object System.Windows.Forms.Form
    $TransferInterfaceForm.ClientSize = '500,600'
    $TransferInterfaceForm.StartPosition = "CenterScreen"
    $TransferInterfaceForm.Text = "DataFerry - Data Transfer Utility Ver 2.0"
    $TransferInterfaceForm.BackColor = "#FFFFFF"


#Text descriptions
#General description of script
    $DescriptionTxt = New-Object System.Windows.Forms.Label
    $DescriptionTxt.Location = New-Object System.Drawing.Size(25,50)
    $DescriptionTxt.Size = New-Object System.Drawing.Size(450,120)
    $DescriptionTxt.Font = "Calibri, 12"
    $DescriptionTxt.Text = "Welcome to DataFerry, this utility will help you easily transition your data from one workstation to another with your U: Drive or an external USB Drive. 
    `nUpload Data: Uploads data to a drive used for the transfer `nTransfer To A New Workstation: Copies data to the workstation" 


#Instructions
    $InstructionsTxt = New-Object System.Windows.Forms.Label
    $InstructionsTxt.Location = New-Object System.Drawing.Size(25,180)
    $InstructionsTxt.Size = New-Object System.Drawing.Size(450,20)
    $InstructionsTxt.Font = [System.Drawing.Font]::new("Calibri", 12, [System.Drawing.FontStyle]::Bold)
    $InstructionsTxt.Text = "How To Use:"

    $InstructionContentTxt = New-Object System.Windows.Forms.Label
    $InstructionContentTxt.Location = New-Object System.Drawing.Size(25,200)
    $InstructionContentTxt.Size = New-Object System.Drawing.Size(450,100)
    $InstructionContentTxt.Font = "Calibri, 12"
    $InstructionContentTxt.Text = "  1. Ensure that your drive is present on your old workstation `n  2. Select your upload/transfer drive from the drop down menu `n  3. If the status is 'Ready To Begin' select your desired operation `n  4. Watch the progress bar to follow the operation's progress `n  5. Check files, install, and repeat on the new workstation"


#Displaying current user 
    $DisplayUsrTxt = New-Object System.Windows.Forms.Label
    $DisplayUsrTxt.Location = New-Object System.Drawing.Size(25,0)
    $DisplayUsrTxt.Size = New-Object System.Drawing.Size(275,20)
    $DisplayUsrTxt.Font = [System.Drawing.Font]::new("Calibri", 12, [System.Drawing.FontStyle]::Bold)
    $DisplayUsrTxt.Text = "Current User: $CurrentUser"


#Status to start
    $ReadystatTxt = New-Object System.Windows.Forms.Label
    $ReadystatTxt.Location = New-Object System.Drawing.Size(300,0) 
    $ReadystatTxt.Size = New-Object System.Drawing.Size(200,20)
    $ReadystatTxt.Font = [System.Drawing.Font]::new("Calibri", 12, [System.Drawing.FontStyle]::Bold)
    $ReadystatTxt.Text = "Status: $Global:Stat"


#Prompt to select disk
    $DiskPrompt = New-Object System.Windows.Forms.Label
    $DiskPrompt.Location = New-Object System.Drawing.Size(40,400)
    $DiskPrompt.Size = New-Object System.Drawing.Size(340,20)
    $DiskPrompt.Font = [System.Drawing.Font]::new("Calibri", 12, [System.Drawing.FontStyle]::Bold)
    $DiskPrompt.Text = "Please select a drive to copy to, or transfer from:"


#Progress of the upload / download
    $TransferProg = New-Object System.Windows.Forms.Label
    $TransferProg.Location = New-Object System.Drawing.Size(25,325)
    $TransferProg.Size = New-Object System.Drawing.Size(450,20)
    $TransferProg.Font = [System.Drawing.Font]::new("Calibri", 11, [System.Drawing.FontStyle]::Bold)
    $TransferProg.Text = "Not Running:"


#Drive selection
#Destination drive
    $DriveSelector = New-Object System.Windows.Forms.ComboBox
    $DriveSelector.Location = New-Object System.Drawing.Size(380,400)
    $DriveSelector.Size = New-Object System.Drawing.Size(70,20)
    
    $Choices = [collections.arraylist]@( #Destination and Source Disk Options
        [pscustomobject]@{Name = 'N/A'; Value = 0}
        [pscustomobject]@{Name = 'U: Drive' ; Value = 'U:'}
        [pscustomobject]@{Name = 'D:' ; Value = 'D:'}
        [pscustomobject]@{Name = 'E:' ; Value = 'E:'}
    )
    $DriveSelector.DataSource=$Choices
    $DriveSelector.Displaymember='Name'


    $DriveSelector.add_SelectedIndexChanged({ #Refreshes and stores the value of the string
    $Global:Drive = $DriveSelector.SelectedItem.Value
    Ready-Status $Global:Drive
    })
    

#Buttons to control fuctions & appearance settings
    $UploadToDriveBtn = New-Object System.Windows.Forms.Button
    $UploadToDriveBtn.BackColor = "#DCDCDC" 
    $UploadToDriveBtn.Location = New-Object System.Drawing.Size(21,450)
    $UploadToDriveBtn.Size = New-Object System.Drawing.Size(210,110)
    $UploadToDriveBtn.Font = [System.Drawing.Font]::new("Calibri", 14, [System.Drawing.FontStyle]::Bold)
    $UploadToDriveBtn.Text = "Upload Data"

    $UploadToDriveBtn.Add_Click({Upload_Drive $CurrentUser $Global:Drive}) #Calls upon the upload func


    $DownloadToWorkstationBtn = New-Object System.Windows.Forms.Button
    $DownloadToWorkstationBtn.BackColor = "#DCDCDC"
    $DownloadToWorkstationBtn.Location = New-Object System.Drawing.Size(270,450)
    $DownloadToWorkstationBtn.Size = New-Object System.Drawing.Size(210,110)
    $DownloadToWorkstationBtn.Font = [System.Drawing.Font]::new("Calibri", 14, [System.Drawing.FontStyle]::Bold)
    $DownloadToWorkstationBtn.Text = "Transfer To A New Workstation"
    

    $DownloadToWorkstationBtn.Add_Click({Download_Workstation $CurrentUser $Global:Drive}) #Calls upon the download function 


#Progress bar to show current status
    $ProgressBar = New-Object System.Windows.Forms.ProgressBar
    $ProgressBar.Name = 'Script Status'
    $ProgressBar.Location = New-Object System.Drawing.Size (25, 350)
    $ProgressBar.Size = New-Object System.Drawing.Size (450,20)
    $ProgressBar.BackColor = '#f7f7f7'
    $ProgressBar.Value = $Global:Progress


#Showing each object in the form
    $TransferInterfaceForm.Controls.Add($DescriptionTxt) 
    $TransferInterfaceForm.Controls.Add($InstructionsTxt)
    $TransferInterfaceForm.Controls.Add($InstructionContentTxt)
    $TransferInterfaceForm.Controls.Add($DisplayUsrTxt) 
    $TransferInterfaceForm.Controls.Add($ReadystatTxt) 
    $TransferInterfaceForm.Controls.Add($DiskPrompt) 
    $TransferInterfaceForm.Controls.Add($TransferProg)
    $TransferInterfaceForm.Controls.Add($DriveSelector) 
    $TransferInterfaceForm.Controls.Add($UploadToDriveBtn) 
    $TransferInterfaceForm.Controls.Add($DownloadToWorkstationBtn) 
    $TransferInterfaceForm.Controls.Add($ProgressBar)

    $TransferInterfaceForm.ShowDialog() | Out-Null
}



#GUI STATUS MANAGEMENT
Function Ready-Status{ #Checks and changes the status to let users know if they selected an option with a present drive ready for transfer
    Param($Selector)

    if(($Selector -ne 0 -And (Test-Path $Selector))){
        $Global:Stat = "Ready To Begin"
    }
    elseif($Selector -eq 0){
        $Global:Stat = "No Drive Selected"
    }
    else{
        $Global:Stat = "Drive Not Present"
    }

    $ReadystatTxt.Text = "Status: $Global:Stat" #Refreshes the status of the script
}



#TRANSFERRING FUNCTIONS
Function Upload_Drive {
    param ([String]$UploadUsr, $Temp)

    $Destination = $Temp

    If((Test-Path $Destination)){ #Error checking to see if the drive chosen exists
       
        #Checking the transfer file exists in destination and creates one if there isn't one
        $JobCheck = {
            param ($Locate)
            if(!(Test-Path $Locate\\Data-Transfer)){
                New-Item -Path $Locate\\Data-Transfer -ItemType Directory
            }
            else{
                Remove-Item -Path $Locate\\Data-Transfer -Recurse -Force
                New-Item -Path $Locate\\Data-Transfer -ItemType Directory
            }}

        #Transfering select folders from user account to destination drive
        $JobSign = {param ($UploadUsr, $Locate) Copy-Item -path C:\\Users\$UploadUsr\AppData\Roaming\Microsoft\Signatures -Destination $Locate\\Data-Transfer -Force -Recurse}
        $JobDesk = {param ($UploadUsr, $Locate) Copy-Item -Path C:\\Users\$UploadUsr\Desktop -Destination $Locate\\Data-Transfer -Force -Recurse}
        $JobDoc = {param ($UploadUsr, $Locate) Copy-item -path C:\\Users\$UploadUsr\Documents -Destination $Locate\\Data-Transfer -Force -Recurse}
        $JobDown = {param ($UploadUsr, $Locate) Copy-item -path C:\\Users\$UploadUsr\Downloads -Destination $Locate\\Data-Transfer -Force -Recurse}
        $JobFav = {param ($UploadUsr, $Locate) Copy-item -path C:\\Users\$UploadUsr\Favorites -Destination $Locate\\Data-Transfer -Force -Recurse}
        $JobPic = {param ($UploadUsr, $Locate) Copy-item -path C:\\Users\$UploadUsr\Pictures -Destination $Locate\\Data-Transfer -Force -Recurse}
        $JobVid = {param ($UploadUsr, $Locate) Copy-item -path C:\\Users\$UploadUsr\Videos -Destination $Locate\\Data-Transfer -Force -Recurse}
       
        #Running job tasks in the background
        $ProgressBar.Value = $Global:Progress = 11.11
        $TransferProg.Text = "Running: Preparing for upload"
        $TransferProg.Refresh()
        Start-Job -ScriptBlock $JobCheck -ArgumentList $Destination
        Start-Sleep -Milliseconds 1000

        $ProgressBar.Value = $Global:Progress = 22.22
        $TransferProg.Text = "Running: Uploading Desktop to $Destination"
        $TransferProg.Refresh()
        Start-Job -ScriptBlock $JobDesk -ArgumentList $UploadUsr, $Destination
        Start-Sleep -Milliseconds 1000

        $ProgressBar.Value = $Global:Progress = 33.33
        $TransferProg.Text = "Running: Uploading Documents to $Destination"
        $TransferProg.Refresh()
        Start-Job -ScriptBlock $JobDoc -ArgumentList $UploadUsr, $Destination
        Start-Sleep -Milliseconds 1000
        
        $ProgressBar.Value = $Global:Progress =  44.44
        $TransferProg.Text = "Running: Uploading Downloads to $Destination" 
        $TransferProg.Refresh()
        Start-Job -ScriptBlock $JobDown -ArgumentList $UploadUsr, $Destination
        Start-Sleep -Milliseconds 1000
         
        $ProgressBar.Value = $Global:Progress = 55.55
        $TransferProg.Text = "Running: Uploading Favorites to $Destination"
        $TransferProg.Refresh()
        Start-Job -ScriptBlock $JobFav -ArgumentList $UploadUsr, $Destination
        Start-Sleep -Milliseconds 1000
        
        $ProgressBar.Value = $Global:Progress = 66.66
        $TransferProg.Text = "Running: Uploading Pictures to $Destination"
        $TransferProg.Refresh()
        Start-Job -ScriptBlock $JobPic -ArgumentList $UploadUsr, $Destination
        Start-Sleep -Milliseconds 1000

        $ProgressBar.Value = $Global:Progress = 77.77
        $TransferProg.Text = "Running: Uploading Videos to $Destination"
        $TransferProg.Refresh()
        Start-Job -ScriptBlock $JobVid -ArgumentList $UploadUsr, $Destination
        Start-Sleep -Milliseconds 1000
        
        $ProgressBar.Value = $Global:Progress = 88.88
        $TransferProg.Text = "Running: Uploading Stored Signatures to $Destination"
        $TransferProg.Refresh()
        Start-Job -ScriptBlock $JobSign -ArgumentList $UploadUsr, $Destination
        Start-Sleep -Milliseconds 1000

        $ProgressBar.Value = $Global:Progress = 100
        $TransferProg.Text = "Completed: The data uploaded successfully!"
        $TransferProg.Refresh()
    }
    
}


#DOWNLOAD ScriptBlock:
Function Download_Workstation {
    param ([String]$DownloadUsr, $Source)

    $Letter = $Source
    
    if((Test-Path $Letter)){ #Error checking to see if the drive chosen exists
        #Checking the transfer file exists in source and notifies user if not found
        if(!(Test-Path $Letter\\Data-Transfer)){
        }
        else{
            $JobDownSign = {param ($DownloadUsr, $Locate) Copy-Item -Path $Locate\\Data-Transfer\Signatures -Destination C:\\Users\$DownloadUsr\AppData\Roaming\Microsoft -Recurse -Force}
            $JobDownDesk = {param ($DownloadUsr, $Locate) Copy-Item -Path $Locate\\Data-Transfer\Desktop -Destination C:\\Users\$DownloadUsr -Recurse -Force}
            $JobDownDoc = {param ($DownloadUsr, $Locate) Copy-Item -Path $Locate\\Data-Transfer\Documents -Destination C:\\Users\$DownloadUsr -Recurse -Force}
            $JobDownDown = {param ($DownloadUsr, $Locate) Copy-Item -Path $Locate\\Data-Transfer\Downloads -Destination C:\\Users\$DownloadUsr -Recurse -Force}
            $JobDownFav = {param ($DownloadUsr, $Locate) Copy-Item -Path $Locate\\Data-Transfer\Favorites -Destination C:\\Users\$DownloadUsr -Recurse -Force}
            $JobDownPic = {param ($DownloadUsr, $Locate) Copy-Item -Path $Locate\\Data-Transfer\Pictures -Destination C:\\Users\$DownloadUsr -Recurse -Force}
            $JobDownVid = {param ($DownloadUsr, $Locate) Copy-Item -Path $Locate\\Data-Transfer\Videos -Destination C:\\Users\$DownloadUsr -Recurse -Force}

            #Running transfer tasks in the background
            $ProgressBar.Value = $Global:Progress = 11.11
            $TransferProg.Text = "Running: Preparing for transfer"
            $TransferProg.Refresh()
            Start-Sleep -Milliseconds 1000

            $ProgressBar.Value = $Global:Progress = 22.22
            $TransferProg.Text = "Running: Transfering Desktop from $Letter"
            $TransferProg.Refresh()
            Start-Job -ScriptBlock $JobDownDesk -ArgumentList $DownloadUsr, $Letter
            Start-Sleep -Milliseconds 1000
            
            $ProgressBar.Value = $Global:Progress = 33.33
            $TransferProg.Text = "Running: Transfering Documents from $Letter"
            $TransferProg.Refresh()
            Start-Job -ScriptBlock $JobDownDoc -ArgumentList $DownloadUsr, $Letter
            Start-Sleep -Milliseconds 1000
            
            $ProgressBar.Value = $Global:Progress = 44.44
            $TransferProg.Text = "Running: Transfering Downloads from $Letter"
            $TransferProg.Refresh()
            Start-Job -ScriptBlock $JobDownDown -ArgumentList $DownloadUsr, $Letter
            Start-Sleep -Milliseconds 1000

            $ProgressBar.Value = $Global:Progress = 55.55
            $TransferProg.Text = "Running: Transfering Favorites from $Letter"
            $TransferProg.Refresh()
            Start-Job -ScriptBlock $JobDownFav -ArgumentList $DownloadUsr, $Letter
            Start-Sleep -Milliseconds 1000

            $ProgressBar.Value = $Global:Progress = 66.66
            $TransferProg.Text = "Running: Transfering Pictures from $Letter"
            $TransferProg.Refresh()
            Start-Job -ScriptBlock $JobDownPic -ArgumentList $DownloadUsr, $Letter
            Start-Sleep -Milliseconds 1000

            $ProgressBar.Value = $Global:Progress = 77.77
            $TransferProg.Text = "Running: Transfering Videos from $Letter"
            $TransferProg.Refresh()
            Start-Job -ScriptBlock $JobDownVid -ArgumentList $DownloadUsr, $Letter
            Start-Sleep -Milliseconds 1000

            $ProgressBar.Value = $Global:Progress = 88.88
            $TransferProg.TExt = "Running: Transfering Stored Signatures to $Letter"
            $TransferProg.Refresh()
            Start-Job -SciptBlock $JobDownSign -ArgumentList $DownloadUsr, $Letter
            Start-Sleep -Milliseconds 1000

            $ProgressBar.Value = $Global:Progress = 100
            $TransferProg.Text = "Completed: The data transfered successfully!"
            $TransferProg.Refresh()
        }
    }
    
}


GUI