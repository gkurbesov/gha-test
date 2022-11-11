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
function Write-ActionError {
    param(
        [string]$Message=""
    )

    Send-ActionCommand error $Message
}

 function Write-ActionWarning {
    param(
        [string]$Message=""
    )

    Send-ActionCommand warning $Message
}

 function Write-ActionInfo {
    param(
        [string]$Message=""
    )

    ## Hmm, which one??
    #Write-Host "$($Message)$([System.Environment]::NewLine)"
    Write-Output "$($Message)$([System.Environment]::NewLine)"
}

Write-ActionInfo "Test info"
Write-ActionWarning "Test warning"
Write-ActionError "Test error"