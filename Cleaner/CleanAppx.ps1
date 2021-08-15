# An all in one script to clean up windows of many annoying "features"
# I took inspiration from:
#   https://www.reddit.com/r/sysadmin/comments/mvcbfb/sysadmins_post_a_repetitive_task_you_automated/gvc96x0
#   https://github.com/adolfintel/Windows10-Privacy




$AppxList =
{
  "*BioEnrollment*",
  "*ParentalControls*",
  "*Advertising.xaml*",
  "*Advertising.xaml*",
  "*zune*",
  "*xbox*",
  "*maps*",
  "*sticky*",
  "*alarms*",
  "*people*",
  "*comm*",
  "*3dbuilder*",
  "*calculator*",
  "*windowscommunicationsapps*",
  "*windowscamera*",
  "*officehub*",
  "*skypeapp*",
  "*getstarted*",
  "*solitairecollection*",
  "*bing*",
  "*onenote*",
  "*windowsphone*",
  "*soundrecorder*",
  "*YourPhone*",
  "*GetHelp*",
  "*Wallet*",
  "*MixedReality*",
  "*FeedbackHub*",
  "**",
  "**",
  "**",
  ""
}

$WinOptFeatList =
{
  "*internetexplorer*",
  "*Hello-Face*",
  "*QuickAssist*",
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
      # Get a list of appx that are similar
      $AppxSimilarList = Get-AppxPackage -AllUsers | where PackageFullName -like $Appx

      foreach ($ASL in $AppxSimilarList)
      {
        $PackagePath = $ASL.InstallLocation
        $PackageName = $ASL.Name

        # Try and remove the Appx
        Remove-AppxPackage -Package $ASL -AllUsers

        # Try and remove residual installation folder
        # TODO test if this is needed. I think if the Remove-AppxPackage succeeds then this may not be needed.
        Remove-Item $PackagePath -Recurse -ErrorAction SilentlyContinue

        # Try and remove other folders of the same appx
        # There can be a few older versions
        Get-ChildItem "$Env:Programfiles\WindowsApps" `
          | Where-Object Name -Like "*$($PackageName)*" `
          | ForEach-Object `
          {
            Remove-Item -LiteralPath $_.Name -Recurse -ErrorAction SilentlyContinue
          }

      }
  }
}

function removeWinOptFeat {
  param (
    [ref]$WOFListToRemove
  )

  foreach ($WOF in $WOFListToRemove)
  {
    if ($WOF -ne "")
    {
      Get-WindowsPackage -Online | Where PackageName -like $WOF | Remove-WindowsPackage -Online -NoRestart
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
