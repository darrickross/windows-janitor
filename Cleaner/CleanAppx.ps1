# An all in one script to clean up windows of many annoying "features"
# I took inspiration from:
#   https://www.reddit.com/r/sysadmin/comments/mvcbfb/sysadmins_post_a_repetitive_task_you_automated/gvc96x0
#   https://github.com/adolfintel/Windows10-Privacy




$AppxList =
{
  "*zune*",
  "*bing*",
  ""
}

function removeAppxPackage {
  param (
    [ref]$RemoveList
  )

  foreach ($Appx in $AppxListToRemove)
  {
    if ($Appx -ne "")
    {
      #Get a list of
      $AppxSimilarList = Get-AppxPackage -AllUsers | where PackageFullName -like $Appx

      foreach ($ASL in $AppxSimilarList)
      {
      }
  }
}
$CurrUserDesktopPath = [Environment]::GetFolderPath("Desktop")
$Date = Get-Date -Format "yyyyMMdd-HHmm"
$LogFileName = "CleanAppx_$($Date).txt"
$LogFile = join-path $CurrUserDesktopPath $LogFileName

Get-AppxPackage -AllUsers | ft Name, PackageFullName -Autosize | Out-File -FilePath $LogFile -Append

removeAppx($AppxList)

Get-AppxPackage -AllUsers | ft Name, PackageFullName -Autosize | Out-File -FilePath $LogFile -Append
