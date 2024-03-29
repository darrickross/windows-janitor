# An all in one script to clean up windows of many annoying "features"
# I took inspiration from:
#   https://www.reddit.com/r/sysadmin/comments/mvcbfb/sysadmins_post_a_repetitive_task_you_automated/gvc96x0
#   https://github.com/adolfintel/Windows10-Privacy

$ErrorForgroundColor = "White"
$ErrorBackgroundColor = "Red"


$AppxList =@(
  "*BioEnrollment*"
  "*ParentalControls*"
  "*Advertising.xaml*"
  "*Advertising.xaml*" #TODO TEST if this is needed. According to some other scripts you want to list it twice.
  "*zune*"
  "*xbox*"
  "*maps*"
  "*sticky*"
  "*alarms*"
  "*people*"
  "*comm*"
  "*3dbuilder*"
  "*calculator*"
  "*windowscommunicationsapps*"
  "*windowscamera*"
  "*officehub*"
  "*skypeapp*"
  "*getstarted*"
  "*solitairecollection*"
  "*bing*"
  "*onenote*"
  "*windowsphone*"
  "*soundrecorder*"
  "*YourPhone*"
  "*GetHelp*"
  "*Wallet*"
  "*MixedReality*"
  "*FeedbackHub*"
  #"**"
  #"**"
  #"**"
)

$WinOptFeatList = @(
  "*internetexplorer*"
  "*Hello-Face*"
  "*QuickAssist*"
)

function removeAppxPackage {
  param (
    #Required, Check if they exist
    [ref]$RemoveList

    #Optional, when using check that they exist.
    [ref]$SuccessfullyRemovedList
    [ref]$UnsuccessfullyRemovedList
  )

  if ($RemoveList -ne $null)
  {
    Write-Host "removeAppxPackage() was not provided with a list of packages to look for and remove." -ForegroundColor $($ErrorForgroundColor) -BackgroundColor $($ErrorBackgroundColor)
    return
  }


  ForEach ($Appx in $AppxListToRemove)
  {
    if ($Appx -ne "")
    {
      # Get a list of appx that are similar
      $AppxSimilarList = Get-AppxPackage -AllUsers | where PackageFullName -like $Appx

      ForEach ($ASL in $AppxSimilarList)
      {
        $error.clear()
        Try
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
          Get-ChildItem "$Env:Programfiles\WindowsApps" |
            Where-Object Name -Like "*$($PackageName)*" |
            ForEach-Object `
            {
              Remove-Item -LiteralPath $_.Name -Recurse -ErrorAction SilentlyContinue
            } #


        } # End Try
        catch
        {
          $UnsuccessfullyRemovedList += $AppxPackageList
        } # End Catch


        if (!$error)
        {
          $SuccessfullyRemovedList += $AppxPackageList
        } # End If (!$error)
      } # End ForEach $AppxSimilarList



      # Try and remove all the app folders as well.
      # This is different, it tries to remove others that may have been missed.
      # However I think this might be redudent in 99% if not 100% of scenerios.
      # TODO Test if this is needed for default Windows 10 installs.
      Get-ChildItem "$Env:Programfiles\WindowsApps" |
        Where-Object Name -Like $Appx |
        ForEach-Object `
        {
          Remove-Item -LiteralPath $_.Name
        } # End ForEach-Object


      # Get Provisioned Appx.
      $AppxProvSimilarList = Get-AppxProvisionedPackage -Online | Where DisplayName -like $Appx

      ForEach ($ProvPackage in $AppxProvSimilarList)
      {
        $error.clear()
        try
        {
          $PackagePath = $ASL.InstallLocation
          $PackageName = $ASL.Name

          #Try and remove the Appx
          Remove-AppxPackage -Package $ASL -AllUsers

          #Try and remove residual installation folder
          Remove-Item $PackagePath -Recurse -ErrorAction SilentlyContinue

          #Try and remove other folders of the same appx
          Get-ChildItem "$Env:Programfiles\WindowsApps" | Where-Object Name -Like "*$($PackageName)*" | ForEach-Object { Remove-Item -LiteralPath $_.Name -Recurse -ErrorAction SilentlyContinue }

        }
        catch
        {
          $UnsuccessfullyRemovedList += $AppxPackageList
        }
        if (!$error)
        {
          $SuccessfullyRemovedList += $AppxPackageList
        }

      }

      #Try and remove all the app folders as well.
      Get-ChildItem | Where-Object Name -Like $Appx | ForEach-Object { Remove-Item -LiteralPath $_.Name }


      $AppxProvSimilarList = Get-AppxProvisionedPackage -Online | Where DisplayName -like $Appx

      foreach ($FullAppxName in $AppxProvSimilarList)

      $error.clear()
      Try
      {
        #Could probably seprate each into its own try catch to differenciate between a failing Get-AppxProvisionedPackage or Get-AppxPackage in case that is a case.

        Get-AppxProvisionedPackage -Online | Where DisplayName -like $Appx | Remove-AppxProvisionedPackage -Online

        Get-AppxPackage -AllUsers | where PackageFullName -like $Appx | Remove-AppxPackage

        #Try to remove the file path to help clear the disk.
        #It's not much but honest work

        #TODO make an option to remove the package from all user's appdata folder not just curr user
        $AppxPath="$Env:LOCALAPPDATA\Packages\$Appx*"

        Remove-Item $AppxPath -Recurse -Force -ErrorAction SilentlyContinue
      }
      catch
      {
        $UnsuccessfullyRemovedList += $Appx
      }

      if (!$Error)
      {
        $SuccessfullyRemovedList += $Appx
      }




    }
  }
}

function removeWinOptFeat {
  param (
    [ref]$WOFListToRemove
    [ref]$SuccessfullyRemoved
    [ref]$UnsuccessfullyRemoved
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
