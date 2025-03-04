# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the users to check (replace with actual usernames)
$usersToCheck = @(
  "user1",
  "user2",
  "user3"
)

# Set the number of days before expiration to send the alert
$daysBeforeExpiration = 14

# Email settings (replace with your actual settings)
$mailSender = "password-alert@yourdomain.com"
$smtpServer = "your.smtp.server.com"

# Loop through each user
foreach ($user in $usersToCheck) {
  # Get the user object from Active Directory
  $adUser = Get-ADUser $user -Properties PasswordLastSet, PasswordExpires

  # Calculate the password expiration date
  $passwordExpirationDate = $adUser.PasswordLastSet.AddDays($adUser.PasswordExpires)

  # Calculate the days until password expiration
  $daysToExpiration = (New-TimeSpan -Start (Get-Date) -End $passwordExpirationDate).Days

  # Check if the password will expire within the specified number of days
  if ($daysToExpiration -le $daysBeforeExpiration) {
    # Create the email subject and body
    $subject = "Password Expiration Alert for $user"
    $body = "Your password will expire in $daysToExpiration days. Please change it as soon as possible."

    # Send the email notification
    Send-MailMessage -From $mailSender -To $user -Subject $subject -Body $body -SmtpServer $smtpServer
  }
}