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
function Send-ActionCommand {
    param(
        [Parameter(Position=0, Mandatory)]
        [string]$Command,

        [Parameter(ParameterSetName="WithProps", Position=1, Mandatory)]
        [hashtable]$Properties,

        [Parameter(ParameterSetName="WithProps", Position=2)]
        [Parameter(ParameterSetName="SkipProps", Position=1)]
        [string]$Message=''
    )

    if (-not $Command) {
        $Command = 'missing.command'
    }

    $cmdStr = "$($CMD_STRING)$($Command)"
    if ($Properties.Count -gt 0) {
        $cmdStr += ' '
        foreach ($key in $Properties.Keys) {
            $val = ConvertTo-EscapedValue -Value $Properties[$key]
            $cmdStr += "$($key)=$($val)"
        }
    }
    $cmdStr += $CMD_STRING
    $cmdStr += ConvertTo-EscapedData -Value $Message
    $cmdStr += [System.Environment]::NewLine

    return $cmdStr
}

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