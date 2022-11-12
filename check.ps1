<#

$out = & dotnet sln list | where{$_ -like '*.csproj'}

foreach ($item in $out) {
    Write-Host "Selected project: $item"
}

#>


<#
$reff = Select-Xml -Path "Product\DirectCrm\DirectCrm.Core\DirectCrm.Core.Model.csproj" `
-XPath "//PackageReference" | ForEach-Object { $_.node.Include } | Where-Object { $_ -like 'Mindbox.*' } 

$reff | ForEach {[PSCustomObject]$_} | Format-Table -AutoSize
#>

<#
$projectFiles = Get-ChildItem -Path $env:GITHUB_WORKSPACE -Filter "*.csproj" -Recurse

if ($projectFiles.Length -eq 0 ) {
    Write-Error "Project files not found"
}

foreach ($item in $files) {
    Write-Host "Project $item"
}
#>

Import-Module $PSScriptRoot/lib/GitHubActionsCore

function Get-ProjectFiles {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $Path
    )
    
    return Get-ChildItem -Path $Path -Filter "*.csproj" -Recurse
}

function Get-PackageReferences {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $Path
    )
    
    return Select-Xml -Path $Path -XPath "//PackageReference" | ForEach-Object { $_.node.Include }
}

function Get-ProjectReferences {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $Path
    )

    return Select-Xml -Path $Path -XPath "//ProjectReference" | ForEach-Object { Split-Path $_.node.Include -leaf }
}

$ProjectFiles = Get-ProjectFiles $env:GITHUB_WORKSPACE

if($ProjectFiles.Length -eq 0) {
    Write-Warning "Project files not found!"
    exit 1
}

foreach ($ProjectFile in $ProjectFiles) {
    $file = $ProjectFile

    Write-Host $ProjectFile

    $project = $ProjectFile.BaseName + $ProjectFile.Extension

    $PackagesReferences = Get-PackageReferences $file
    $ProjectReferences = Get-ProjectReferences $file

    Write-Host "`e[32mProject: $project"
    Write-Host $file
    Write-Host "`tPackages:"
    $PackagesReferences | ForEach-Object { Write-Host "`t`t" $_ }
    Write-Host "`tProjects:"
    $ProjectReferences | ForEach-Object { Write-Host "`t`t" $_ }
}