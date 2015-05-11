# User Creation Automation Script: One-off
# Created By: Perry Beagle
# Date: 10/14/14

Import-Module ActiveDirectory

$IntroMsg       = @(Write-Host "

ATTENTION: 
This script must be run as by an account with 'Domain Admin' access-rights.
Do not use spaces when answering these prompts or the script will fail.

")

$IntroMsg

# Below is the code to run a windowed selection of the OU's available to move AD-Objects.
# That's right, ~60 lines of code for a popup menu!

Function Select_OU {
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
 
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select a Computer"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"
 
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
 
$objForm.Controls.Add($OKButton)
$objForm.AcceptButton = $OKButton
 
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
 
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$objForm.Controls.Add($CancelButton)
$objForm.CancelButton = $CancelButton
 
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please select a department:"
$objForm.Controls.Add($objLabel) 
 
$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80
 
[void] $objListBox.Items.Add("Account Services")        # Put the names of the various containers here
[void] $objListBox.Items.Add("CEO")                     # Each line coorelates to a specific OU in the domain 
[void] $objListBox.Items.Add("Claims")                  # The choice made here is added to the $OU variable in the next section
[void] $objListBox.Items.Add("Communications")
[void] $objListBox.Items.Add("Customer Care")
[void] $objListBox.Items.Add("Data Management")
[void] $objListBox.Items.Add("Distribution Services")
[void] $objListBox.Items.Add("Executive")
[void] $objListBox.Items.Add("Finance")
[void] $objListBox.Items.Add("Human Resources")
[void] $objListBox.Items.Add("Industry Relations")
[void] $objListBox.Items.Add("IS")
[void] $objListBox.Items.Add("Legal")
[void] $objListBox.Items.Add("Licensee Relations")
[void] $objListBox.Items.Add("Operations")
[void] $objListBox.Items.Add("Repertoire")
[void] $objListBox.Items.Add("Service")

$objForm.Controls.Add($objListBox)  
$objForm.Topmost = $True
$result = $objForm.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $objListBox.SelectedIndex -ge 0)
{
    $selection = $objListBox.SelectedItem
    Create_User
} 

}

Function Create_User {
    # Below is the actual script that is doing the bulk of the work
    # All of the varibles below are placeholders for the "New-ADUSer" parameters
    # Some ask for user input, others manipulate previous inputs to "automate" the parameters 

    $Givenname      = (Read-Host -Prompt 'First Name')
    $Surname        = (Read-Host -Prompt 'Last Name')
    $Uname          = ((Read-Host -Prompt 'Username, eg. John Smith = jsmith').ToLower()) 
    $Name           = ($Givenname + ' ' + $Surname)
    $EmailAddress   = $Uname + '@soundexchange.com'
    $Password       = (Read-Host -Prompt "Enter New User Password" -AsSecureString)
    $Description    = (Read-Host -Prompt "Title/Department")
    $OU             = "OU=$selection,OU=Users,OU=PEOPLE,DC=Example,DC=LOCAL"
    $Attributes     = @{
                    'ProxyAddresses'="SMTP:$EmailAddress", 
                    "smtp:$Uname@example.mail.onmicrosoft.com", 
                    "smtp:$Uname@example.LOCAL"; 
                    'targetAddress'=$Uname + '@example.onmicrosoft.com'; 
                    'userPrincipalName'=$Uname + '@example.com'
                    }

    New-ADUser -Name $Name -SamAccountName $Uname -AccountPassword $Password -DisplayName $Name -Description $Description -EmailAddress $EmailAddress -OtherAttributes $Attributes -Path $OU -Surname $Surname -Given $Givenname -Enabled 1

}

Select_OU