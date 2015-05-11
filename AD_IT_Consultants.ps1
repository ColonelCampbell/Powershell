# Group Membership Audit
# Date: 5/7/15

# This script creates a CSV file containing the group memberships of all the users in a particular group and give relevant data for each of those groups. 
# This is a rather modular script, that can offer a bit of customization if one were to change, or add parameters for the other available properties contained in and AD Group object.

# Import necessary modules here

Import-Module ActiveDirectory


# Global variables, these can be turned in to prompts for tool creation, or changed to fit a static need.

$groupname = "IT_Consultants"                                        # Place the DisplayName of the group here
$directory = "c:\scriptdump\"                                        # Where do you want to dump the audit file?
$fullpath  = "$directory"+"$groupname"+".csv"                        # Creates the directory, and fullpath to the audit file

# Get Groupmembers of $groupname, seperate properties into variables, write variables to CSV with proper headers

Function GroupMembershipCSV {
    
    $Users = Get-ADGroupMember -Identity $groupname
    
    # Add headers to the csv file. If adding a new column, be sure to add a header in this cmdlet
    # These column headers need to be in the same order of the $Print variable

    $makefile = (New-Item -Path $fullpath -ItemType File -Value "Username, GroupName, GroupCategory, WhenCreated, WhenChanged, Description `n") 
    $makefile
     
    ForEach ($_ in $users){                                          # Get Groupmembership of each user in $groupname
        
        $groups = Get-ADPrincipalGroupMembership -Identity $_ 
        
        
        ForEach ($grp in $groups) {                                  # Iterate through groups, creating variables for each property we need
                                                                     # You may want to edit the following variables if different information is needed
            $username = $_.name
            $details = (Get-ADGroup -Identity $grp -Properties *)    # Grab all properties first
            $name          = $details.samaccountname                 
            $whencreated   = $details.whencreated
            $whenchanged   = $details.whenchanged
            $groupcategory = $details.groupcategory
            $description   = $details.description
           
            $Print = @(                                              # Edit this statement to print individual object properties from the variables above
                $username      + ", " +                              # Don't forget to add the column headers to match ($makefile)
                $name          + ", " + 
                $groupcategory + ", " + 
                $whencreated   + ", " + 
                $whenchanged   + ", " +
                $description
            )
            
            $Print | Out-File -FilePath $fullpath -Encoding utf8 -Append
        }
    } 
}

# The Sendmail function sends an email with the specified parameters

Function Sendmail {
    
    # Change these variables to edit the process of sending the email 
    $recipient = 'reciever@example.com'                                        # Enter the email address this needs to be sent to here
    $sender    = 'sender@example.com'                                          # Enter the name of the email this will appear to come from   
    $subject   = "Group Memberships" + " " + "$groupname" + " " + "$date"      # Subject line of the email       
    $body      = "See Attachment"                                              # The body of the email 
    $smtp      = "10.100.10.241"                                               # Email server address (can be a url)
    $attach    = $fullpath
    
    Send-MailMessage -To $recipient -From $sender -Attachments $attach -Subject $subject -SmtpServer $smtp
}

# Calling functions sequentially

GroupMembershipCSV
Sendmail
Remove-Item -Path $fullpath