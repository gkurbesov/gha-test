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
Write-Error "Test error"