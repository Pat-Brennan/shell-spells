$schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
$userClass = $schema.FindClass('user')
$userClass.GetAllProperties().Name