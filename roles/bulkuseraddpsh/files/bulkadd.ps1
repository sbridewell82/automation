# Define domain information
$domain = "{{ dn }}"
$securityGroup = "{{ grp }}"
$targetOU = "{{ ou }}"
$defaultPassword = "{{ pw }}"  # Set your default password here

# Specify the path to the CSV file
$csvFilePath = "{{ role_path }}/files/UserList.csv"  # Update this with the actual path

# Import user details from CSV
$userList = Import-Csv $csvFilePath

# Loop through each user and create the account
foreach ($user in $userList) {
    $userLogonName = $user.UserLogonName
    $firstName = $user.FirstName
    $lastName = $user.LastName

    # Create the user account
    $userParams = @{
        'SamAccountName'  = $userLogonName
        'UserPrincipalName' = "$userLogonName@$domain"
        'Name' = $userLogonName
        'GivenName' = $firstName
        'Surname' = $lastName
        'DisplayName' = "$firstName $lastName"
        'Enabled' = $true
        'AccountPassword' = (ConvertTo-SecureString -AsPlainText $defaultPassword -Force)
        'ChangePasswordAtLogon' = $true
        'Description' = "User account for $userLogonName"
        'Path' = $targetOU
    }

    New-ADUser @userParams

    # Add user to the security group
    Add-ADGroupMember -Identity $securityGroup -Members $userLogonName
}

Write-Host "User creation, group membership, and OU placement completed."

