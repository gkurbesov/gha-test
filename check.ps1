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

Write-Host "Test write from script"

Write-Host $PSScriptRoot

$files = Get-ChildItem -Path (Join-Path $PSScriptRoot "*.csproj") -Recurse

foreach ($item in $files) {
    Write-Host "Project $item"
}