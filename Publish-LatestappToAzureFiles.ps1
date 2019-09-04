#define varibales
$StorageAccountName = "Your Storage Account Name" 
$StorageAccountKey = "Your Storage Account Primary Key"
$AzureShare = "Your File Share Name"
$AzureDirectory = "LatestPublish" #Here I am using the name of the folder as LatestPublish for publishing the output. You can choose different name if you want.

#record your artifact name instead of _SampleCoreApp-ASP.NET Core-CI is your artifact name is different. Make sure to add "/" before the artifact name as shonw below. 
#Also I am assuming you have the folder name as drop only. IF not change it.
$Source = $Env:SYSTEM_DEFAULTWORKINGDIRECTORY + "/_SampleCoreApp-ASP.NET Core-CI/drop"

 

#create primary region storage context
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey


#Check for Share Existence
$S = Get-AzureStorageShare -Context $ctx -ErrorAction SilentlyContinue|Where-Object {$_.Name -eq $AzureShare}

if (!$S.Name)
{
    # create a new share
    $s = New-AzureStorageShare $AzureShare -Context $ctx
}

# Check for directory
$d = Get-AzureStorageFile -Share $s -ErrorAction SilentlyContinue|select Name
if ($d.Name -notcontains $AzureDirectory)
{
    # create a directory in the share
    $d = New-AzureStorageDirectory -Share $s -Path $AzureDirectory
}

# get all the folders in the source directory
$Folders = Get-ChildItem -Path $Source -Directory -Recurse

$S = Get-AzureStorageShare -Name $AzureShare -Context $ctx
foreach($Folder in $Folders)
{
    $f = ($Folder.FullName).Substring(($source.Length))
    $Path = $AzureDirectory + $f
    # create a directory in the share for each folder
    New-AzureStorageDirectory -Share $s -Path $Path -ErrorAction SilentlyContinue
}

#Get all the files in the source directory
$files = Get-ChildItem -Path $Source -Recurse -File
foreach($File in $Files)
{
    $f = ($file.FullName).Substring(($Source.Length))
    $Path = $AzureDirectory + $f
    #upload the files to the storage

    if($Confirm)
    {
        Set-AzureStorageFileContent -Share $s -Source $File.FullName -Path $Path -Confirm
    }
    else
    {
        Set-AzureStorageFileContent -Share $s -Source $File.FullName -Path $Path -Force
    }
}
