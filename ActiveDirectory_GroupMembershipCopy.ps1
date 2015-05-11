# User Group Membership Copy Script
# Date: 4/21/15

# The most common method for distributing permissions to a new user is to copy those permissions from another user within the domain who has a similar, or the same role.
# This script does just that. Select user1 and user2, add user1's groups to user2's memberships. Rinse, repeat.

# Import the necessary modules

Import-Module ActiveDirectory

# Set Environment to NOT print errors to console when running script

$ErrorActionPreference   = 'SilentlyContinue'

# Variable Placeholders

$script:olduser          = ''
$script:oldUserPrincipal = ''
$script:newuser          = ''
$script:newUserPrincipal = ''


# Welcome Message

Function Startup {
    
    $printtoscreen = ("
        
        Please proceed with caution.
        If you need you are unsure about what users groups you should copy, do so manually.
        
        ")
    
    Write-Host -Object $printtoscreen -ForegroundColor Yellow                                            # Write banner message to console
}

# Ask for user to copy from

Function getolduser { 
    
    $keepuser = ''
    
    While ($keepuser -ne "Y") {
        
        $user                    = (Read-Host -Prompt "Username of user you want to copy (ex. jsmith)") # Ask what person's permissions they want to copy
        $oldUserObject           = Get-ADUser -Identity $user                                            # Get the properties of the User's AD Object 
        
        Write-Host -Object $oldUserObject.name.toupper() -ForegroundColor Red                            # Write selected user's name
        
        $script:oldUserPrincipal = Get-ADPrincipalGroupMembership -Identity $oldUserObject               # Get groups of selected user
        $script:olduser          = $oldUserObject
        
        ForEach ($_ in $script:oldUserPrincipal) {                                                       # Iterate through groups, writing to console, in Yellow
            
            Write-Host $_.name -ForegroundColor Yellow
        }
        
        $keepuser = (Read-Host -Prompt "Do you want to use this users groups? (Y/N)")                    # Ask user to confirm; end while loop
    }      
}
# Ask for user to copy the oldusers memberships to

Function getnewuser {
    
    $keepuser = ''
    
    While ($keepuser -ne "Y") {
        
        $user                    = (Read-Host -Prompt "Username of user you want to copy to")            # Ask what person to copy permissions to
        $newuserobject           = Get-ADUser -Identity $user                                            # Get the properties of the User's AD Object 
        
        Write-Host -Object $newuserobject.name.toupper() -ForegroundColor Red                            # Write selected users name
        
        $script:newUserPrincipal = Get-ADPrincipalGroupMembership -Identity $newuserobject               # Get groups of selected user
        $script:newuser          = $newuserobject

        ForEach ($_ in $newUserPrincipal) {                                                              # Iterate through groups, writing to console
            
            Write-Host $_.name -ForegroundColor Yellow
        }
        
        $keepuser = (Read-Host -Prompt "Continue with Copying? (Y/N)")                                   # Ask user to confirm; end while loop
    }
}

# Add groups to the selected account

Function addgroups ($script:oldUserPrincipal) {     
    
    Foreach ($_ in $script:oldUserPrincipal) {
        
        Add-ADGroupMember -Identity $_ -Members $script:newuser `
        -ErrorAction SilentlyContinue -WarningAction SilentlyContinue 
    }
    
    Write-Host -Object $script:newuser.Name.ToUpper() -ForegroundColor Red                               # Write name of New user to console
    Get-ADPrincipalGroupMembership -Identity $script:newuser | FT NAME -HideTableHeaders                 # Get group membership of new user; format 
}                                                                                                        # Write group membership to host
                                                                                                         

# remove the groups

Function RemoveGroups ($script:oldUserPrincipal) {
   
    $undo = (Read-Host -Prompt "Are you happy with these changes?")                                      # Confirm happiness with results
    
    If ($undo -ne "Y") {                                                                                 # If not happy
        
        Foreach ($_ in $script:oldUserPrincipal) {                                                       # For each group
            
            If ($_ -ne "CN=Domain Users,CN=Users,DC=EXAMPLE,DC=LOCAL") {                                 # If should -ne "Default Group/s" in domain, usually just "Domain Users"
                
                Remove-ADPrincipalGroupMembership -Identity $script:newuser -Memberof $_ -Confirm $false # Remove each group
                Write-Host -ForegroundColor Red "$script:newuser".ToUpper()                              # Write selected username to console
                }
            }
        
        Write-Host -Object $script:newuser.Name.ToUpper() -ForegroundColor Yellow                        # Write groups of selected user
        Get-ADPrincipalGroupMembership -Identity $script:newuser | FT NAME -HideTableHeaders 
        
        }
    
    Else { 
        
        Write-Host -ForegroundColor Yellow "That's all folks!"                                           # End if happiness
    }
}

# Running each function sequentially 

Function Run {

    $keepgoing = ''

    While ($keepgoing -eq "Y"){                                                                          # This while loop runs the rest of the functions above,                                                                
                                                                                                         # It allows the user to run these multiple times without
        Startup                                                                                          # needing to re-run the script
        getolduser
        getnewuser
        addgroups($script:oldUserPrincipal)
        removegroups($script:oldUserPrincipal)
    
        While ($keepgoing -ne "Y" -and $keepgoing -ne "N") {
           
            $keepgoing = (Read-Host "Would you like copy another set of groups? [Y/N]")
        }
    }

}
Run
