# AD User Creation Tool - User_Creation.ps1
# Date: 6/3/15

Import-Module ActiveDirectory

$userous  = Get-ADOrganizationalUnit -Filter * -SearchBase 'OU=Users,OU=SX_PEOPLE,DC=SOUNDX,DC=LOCAL' | Select-Object -Property Name,Distinguishedname 

$sript:department = 0 

Function Display-ADDepartments {
    $i = 0
    Write-Host Departments -ForegroundColor DarkYellow
    
    ForEach ($object in $userous){
        
        Write-Host $i $object.name
        $i++
    }
}

Function Get-ADNewUserDepartment {
 
    $keepselection = ''
  
    While ($keepselection -ne "Y"){

        $script:department = Read-Host -Prompt "Please select a number that corresponds with the department the new user will be joining"
        Write-Host "You selected the" $userous[$script:department].Name "department."
        $verifyselection = (Read-Host -Prompt "Do you want to keep this selection? [Y/N]").ToUpper()
        
        If ($verifyselection -eq "N" -or $verifyselection -eq "N0") {
            
            $keepselection = "N"
            Write-Host "Alright, let's try that again."
            
        }
        
        Else {
            
            $keepselection = "Y"
            Write-Host "The new user will be added to the" -NoNewline
            Write-Host " " -NoNewline
            Write-Host $userous[$script:department].name -ForegroundColor DarkYellow -NoNewline
            Write-Host " " -NoNewline
            Write-Host "department organizational unit."
            Write-Host "The user object will be placed in the following directory: " -NoNewline 
            $userous = $userous[$script:department].Distinguishedname
            Write-Host $userous -ForegroundColor DarkYellow 
        }
     }
}    
    

Function Get-ADNewUserInformation {
    
    Write-Host "Now we will gather the necessary information about the user. At each prompt, enter the requested information, then press [ENTER]" -ForegroundColor Yellow
    $Givenname    = (Read-Host -Prompt "Please enter the users First Name")
    $Surname      = (Read-Host -Prompt "Please enter the users Last Name")
    $Password     = (Read-Host -Prompt "Create the users password" -AsSecureString)
    $Username     = (Read-Host -Prompt "Please enter the user's username. This is the first initial of their firstname + the lastname. ex. Bilbo Baggins = bbaggins").ToLower()
    $Description  = (Read-Host -Prompt "Please provide a description of this user object. (Format = <Title>_<Department>)")
    $Description  = "$Description"  
    $FullName     = ($Givenname + ' ' + $Surname)
    $EmailAddress = ($Username + '@soundexchange.com')
    $Attributes   = @{'ProxyAddresses'="SMTP:$EmailAddress", "smtp:$Username@soundx.mail.onmicrosoft.com", "smtp:$Username@soundx.local"; 'targetAddress'="$Username" + "@soundx.onmicrosoft.com"; 'userPrincipalName'= "$Username" + "@soundx.local"}
    $Path         = $userous[$script:department].Distinguishedname
    
    New-ADUser -Name "$FullName" -SamAccountName $Username -AccountPassword $Password -DisplayName $FullName -EmailAddress $EmailAddress -Description $Description -OtherAttributes $Attributes -Path $Path -Surname $Surname -Given $Givenname -Enabled 1

}


Function New-SXADUser {
    
    Display-ADDepartments
    Get-ADNewUserDepartment
    Get-ADNewUserInformation

}

New-ADSXUser
