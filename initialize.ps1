<#
.SYNOPSIS
Make Default configurations and installations of my Windows Environment.
.DESCRIPTION 
This Script installs and configs Software like PowerShell, Oh-My-Posh and Windows Terminal
.OUTPUTS
#>

#Check if Script is running as Administrator
if(!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
  Write-Warning "Run your Terminal as Administrator."
  exit
}

# Declare Choice Options
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Description."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","Description."
$cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel","Description."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $cancel)

# Declaring Functions
## https://stackoverflow.com/questions/42300649/creating-desktop-ini-with-powershell-for-custom-folder-icon-not-working-on-windo
function setFolderImage($folder, $imagePath) {
    # make a temporary folder with desktop.ini
    $tmpDir = (Join-Path $env:TEMP ([IO.Path]::GetRandomFileName()))
    mkdir $tmpDir -force >$null
    $tmp = "$tmpDir\desktop.ini"
    @"
[.ShellClassInfo]
IconFile=$imagePath
IconIndex=0
"@ >$tmp
    (Get-Item -LiteralPath $tmp).Attributes = 'Archive, System, Hidden'

    # use a Shell method to move that file into the destination
    $shell = New-Object -com Shell.Application
    $shell.NameSpace($folder).MoveHere($tmp, 0x0004 + 0x0010 + 0x0400)

    # FOF_SILENT         0x0004 don't display progress UI
    # FOF_NOCONFIRMATION 0x0010 don't display confirmation UI, assume "yes" 
    # FOF_NOERRORUI      0x0400 don't put up error UI

    del -LiteralPath $tmpDir -force
}

# Debloating
## ThisIsWin11 Tool from https://github.com/builtbybel/ThisIsWin11
$title = "Debloat Windows" 
$message = "Do you want to Install a Software to Debloat your PC?"
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result) {
  0{
    debloatWindows
    Invoke-WebRequest -Uri "https://github.com/builtbybel/ThisIsWin11/releases/latest/download/TIW11.zip" -OutFile "TIW11.zip"
    Expand-Archive -Path "$PSScriptRoot\TIW11.zip" -DestinationPath "$PSScriptRoot\TIW11"
    Start-Process -FilePath "$PSScriptRoot\TIW11\ThisIsWin11.exe" -Wait
  }1{
    
  }2{
    exit
  }    
}

# Installing
## Powershell > Windows Terminal > NodeJS > Git > posh-git > oh-my-posh > Terminal-Icons > PSReadLine > CascadiaCode > Commitizen
$title = "Install DevTools" 
$message = "Do you want to Install DevTools?"
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
$devToolsInstalled = $false
switch ($result) {
  0{
    $devToolsInstalled = $true

    winget install --id microsoft.powershell -h --accept-package-agreements --accept-source-agreements
    winget install --id Microsoft.WindowsTerminal -h --accept-package-agreements --accept-source-agreements
    winget install --id OpenJS.NodeJS -h --accept-package-agreements --accept-source-agreements
    winget install --id git.git -h --accept-package-agreements --accept-source-agreements
    Install-Module posh-git -Scope CurrentUser
    Install-Module oh-my-posh -Scope CurrentUser
    Install-Module Terminal-Icons -Scope CurrentUser
    Install-Module PSReadLine -Scope CurrentUser
    oh-my-posh install font CascadiaCode
    npm install -g commitizen
  }1{
    
  }2{
    exit
  }    
}

# Config
## Windows Terminal Config and Powershell Profile
if($devToolsInstalled) {
    $title = "Configure Dev Tools" 
    $message = "Do you want to Configure the installed DevTools?"
    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    switch ($result) {
    0{
        New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Target "$HOME\.config\windows-terminal\settings.json"
        echo ". $env:USERPROFILE\.config\powershell\user_profile.ps1" > $PROFILE.CurrentUserCurrentHost 
    }1{
        
    }2{
        exit
    }    
    }
}


# Customize
## Set Git Folder Icon
$title = "Customize" 
$message = "Do you want the Customized Folders etc.?"
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result) {
  0{
    $gitFolderPath = Join-Path $PSScriptRoot "\git"
    $gitFolderIcon = Join-Path $PSScriptRoot "\.config\icons\folder_git.ico"
    setFolderImage $gitFolderPath $gitFolderIcon
  }1{

  }2{
    exit
  }    
}


# Cleanup
$title = "Cleanup" 
$message = "Do you want to Cleanup? (Including this Script)"
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result) {
  0{
    Remove-Item $PSScriptRoot\TIW11.zip -ErrorAction SilentlyContinue
    Remove-Item $PSScriptRoot\TIW11\ -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $PSScriptRoot\README.md -Force -ErrorAction SilentlyContinue
    Remove-Item $PSScriptRoot\.git\ -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $PSCommandPath -Force -ErrorAction SilentlyContinue
  }1{

  }2{
    exit
  }    
}
