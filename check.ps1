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

function Set-ActionFailed {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Message = ""
    )
    [System.Environment]::ExitCode = 1
    Write-ActionError $Message
}

function Write-ActionDebug {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Message = ""
    )

    Send-ActionCommand debug $Message
}

function Write-ActionError {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ParameterSetName = 'MsgOnly')]
        [Parameter(Position = 0, ParameterSetName = 'File')]
        [Parameter(Position = 0, ParameterSetName = 'Line')]
        [Parameter(Position = 0, ParameterSetName = 'Column')]
        [string]$Message = "",

        [Parameter(Position = 1, ParameterSetName = 'File', Mandatory)]
        [Parameter(Position = 1, ParameterSetName = 'Line', Mandatory)]
        [Parameter(Position = 1, ParameterSetName = 'Column', Mandatory)]
        [string]$File,

        [Parameter(Position = 2, ParameterSetName = 'Line', Mandatory)]
        [Parameter(Position = 2, ParameterSetName = 'Column', Mandatory)]
        [int]$Line,

        [Parameter(Position = 3, ParameterSetName = 'Column', Mandatory)]
        [int]$Column
    )
    $params = [ordered]@{ }
    if ($File) {
        $params['file'] = $File
    }
    if ($PSCmdlet.ParameterSetName -in 'Column', 'Line') {
        $params['line'] = $Line
    }
    if ($PSCmdlet.ParameterSetName -eq 'Column') {
        $params['col'] = $Column
    }
    Send-ActionCommand error $params -Message $Message
}

function Write-ActionWarning {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ParameterSetName = 'MsgOnly')]
        [Parameter(Position = 0, ParameterSetName = 'File')]
        [Parameter(Position = 0, ParameterSetName = 'Line')]
        [Parameter(Position = 0, ParameterSetName = 'Column')]
        [string]$Message = "",

        [Parameter(Position = 1, ParameterSetName = 'File', Mandatory)]
        [Parameter(Position = 1, ParameterSetName = 'Line', Mandatory)]
        [Parameter(Position = 1, ParameterSetName = 'Column', Mandatory)]
        [string]$File,

        [Parameter(Position = 2, ParameterSetName = 'Line', Mandatory)]
        [Parameter(Position = 2, ParameterSetName = 'Column', Mandatory)]
        [int]$Line,

        [Parameter(Position = 3, ParameterSetName = 'Column', Mandatory)]
        [int]$Column
    )
    $params = [ordered]@{ }
    if ($File) {
        $params['file'] = $File
    }
    if ($PSCmdlet.ParameterSetName -in 'Column', 'Line') {
        $params['line'] = $Line
    }
    if ($PSCmdlet.ParameterSetName -eq 'Column') {
        $params['col'] = $Column
    }
    Send-ActionCommand warning $params -Message $Message
}


## Used to signal output that is a command to Action/Workflow context
if (-not (Get-Variable -Scope Script -Name CMD_STRING -ErrorAction SilentlyContinue)) {
    Set-Variable -Scope Script -Option Constant -Name CMD_STRING -Value '::'
}

function ConvertTo-ActionCommandString {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$Command,

        [Parameter(Position = 1)]
        [System.Collections.IDictionary]$Properties,

        [Parameter(Position = 2)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Message
    )

    if (-not $Command) {
        $Command = 'missing.command'
    }

    $cmdStr = "$($CMD_STRING)$($Command)"
    if ($Properties.Count -gt 0) {
        $first = $true
        foreach ($key in $Properties.Keys) {
            $val = ConvertTo-ActionEscapedProperty $Properties[$key]
            if ($val) {
                if ($first) {
                    $first = $false
                    $cmdStr += ' '
                }
                else {
                    $cmdStr += ','
                }
                $cmdStr += "$($key)=$($val)"
            }
        }
    }
    $cmdStr += $CMD_STRING
    $cmdStr += ConvertTo-ActionEscapedData $Message

    return $cmdStr
}

function ConvertTo-ActionKeyValueFileCommand {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory, Position = 1)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value
    )
    $convertedValue = ConvertTo-ActionCommandValue $Value
    if ($convertedValue -notmatch '\n') {
        return "$Name=$convertedValue"
    }
    $delimiter = "ghadelimiter_$(New-Guid)"
    if ($Name -contains $delimiter) {
        throw "Unexpected input: name should not contain the delimiter `"$delimiter`""
    }
    if ($convertedValue -contains $delimiter) {
        throw "Unexpected input: value should not contain the delimiter `"$delimiter`""
    }
    $eol = [System.Environment]::NewLine
    return "$Name<<$delimiter$eol$convertedValue$eol$delimiter"
}

<#
.SYNOPSIS
Sanitizes an input into a string so it can be passed into issueCommand safely.
Equivalent of `core.toCommandValue(input)`.
.PARAMETER Value
Input to sanitize into a string.
#>
function ConvertTo-ActionCommandValue {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value
    )
    if ($null -eq $Value) {
        return ''
    }
    if ($Value -is [string]) {
        return $Value
    }
    return ConvertTo-Json $Value -Depth 100 -Compress -EscapeHandling EscapeNonAscii
}

## Escaping based on https://github.com/actions/toolkit/blob/3e40dd39cc56303a2451f5b175068dbefdc11c18/packages/core/src/command.ts#L92-L105
function ConvertTo-ActionEscapedData {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value
    )
    return (ConvertTo-ActionCommandValue $Value).
    Replace("%", '%25').
    Replace("`r", '%0D').
    Replace("`n", '%0A')
}

function ConvertTo-ActionEscapedProperty {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Value
    )
    return (ConvertTo-ActionCommandValue $Value).
    Replace("%", '%25').
    Replace("`r", '%0D').
    Replace("`n", '%0A').
    Replace(':', '%3A').
    Replace(',', '%2C')
}


Write-ActionDebug "Write debug"
Write-ActionWarning "Write warning"
Write-ActionError "Write error"

Write-Host "set action as failed"

Set-ActionFailed "Failed fuck!"