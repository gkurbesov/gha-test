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

Write-Host "List files:"

# Get-ChildItem -Path $env:GITHUB_WORKSPACE -Recurse -Name | Write-Output


$files = Get-ChildItem -Path (Join-Path $env:GITHUB_WORKSPACE "*.csproj") -Recurse

if ($files.Length -eq 0 ) {
    Write-Error "Files not found"
}

foreach ($item in $files) {
    Write-Host "Project $item"
}

