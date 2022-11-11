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

Write-Host "Test from arg:"
Write-Host $env:TEMPD
Write-Host "Test from env: "
Write-Host $env:GITHUB_WORKSPACE


$files = Get-ChildItem -Path (Join-Path $PSScriptRoot "*.csproj") -Recurse

foreach ($item in $files) {
    Write-Host "Project $item"
}