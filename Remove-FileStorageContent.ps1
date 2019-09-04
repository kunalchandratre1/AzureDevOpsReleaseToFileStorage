function RemoveFileDir ([Microsoft.WindowsAzure.Storage.File.CloudFileDirectory] $dir, [Microsoft.Azure.Commands.Common.Authentication.Abstractions.IStorageContext] $ctx)
{   
    $filelist = Get-AzureStorageFile -Directory $dir
    #$dir.Name
    #$filelist
    
    foreach ($f in $filelist)
    {
        #$f
        
        if ($f.GetType().Name -eq "CloudFileDirectory")
        {
            RemoveFileDir $f $ctx
        }
        else
        {
            Remove-AzureStorageFile -File $f           
        }
    }
    Remove-AzureStorageDirectory -Directory $dir
    
} 


#define varibales
$StorageAccountName = "Your Storage Account Name" 
$StorageAccountKey = "Your Storage Account Primary Key"
$AzureShare = "Your File Share Name"
$AzureDirectory = "LatestPublish" #Here I am using the name of the folder as LatestPublish for publishing the output. You can choose different name if you want.


#create primary region storage context
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ctx.ToString()

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
else
{
    # create a directory in the share    
    $dir = Get-AzureStorageFile -Share $s -Path $AzureDirectory    
    RemoveFileDir $dir $ctx
    $d = New-AzureStorageDirectory -Share $s -Path $AzureDirectory
}

