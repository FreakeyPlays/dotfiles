# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Imports
Import-Module posh-git
Import-Module Terminal-Icons
Import-Module PSReadLine

# Load oh-my-posh Theme
$OMP_THEME = Join-Path $PSScriptRoot '..\oh-my-posh\freaky.omp.json'
oh-my-posh --init --shell pwsh --config $OMP_THEME | Invoke-Expression

# History
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# Alias
Set-Alias -Name g -Value git
Set-Alias -Name grep -Value findstr
Set-Alias -Name c -Value clear
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name rm -Value Remove-Item
Set-Alias -Name touch -Value New-Item