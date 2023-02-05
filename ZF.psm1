$safehome = if ([String]::IsNullOrWhiteSpace($Env:HOME)) { $env:USERPROFILE } else { $Env:HOME } 
$favoriteFoldersPath = Join-Path $safehome \.favoriteFolders
$cdHistory = Join-Path -Path $safehome -ChildPath '\.cdHistory'

<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>


function zf {
    [CmdletBinding()]
    param (

        [Alias('a')]
        [switch]
        $add = $null,

        [Alias('ls')]
        [switch]
        $list = $null,

        [Alias('rm')]
        [switch]
        $remove = $null,

        [Alias('f')]
        [switch]
        $files = $null,

        
        [Alias('m')]
        [switch]
        $multi = $null

    )

    if(!$favoriteFolders){
        $Global:favoriteFolders = [System.Collections.Generic.HashSet[string]]@(Get-Content $favoriteFoldersPath)
    }

    if($add){
        $cwd = (Get-Location).Path

        if ($favoriteFolders.Contains($cwd)){
            return
        }
        
        $favoriteFolders.Add($cwd)
        $favoriteFolders | Out-File $favoriteFoldersPath

        return
    }
    
    if($remove){
        $cwd = (Get-Location).Path

        if (-not $favoriteFolders.Contains($cwd)){
            return
        }
        
        $favoriteFolders.Remove($cwd)
        $favoriteFolders | Out-File $favoriteFoldersPath

        return
    }

    if($list){
        return $favoriteFolders
    }

    $quickAccess = [System.Collections.Generic.HashSet[string]]@($favoriteFolders)

    $favoriteFolders | ForEach-Object {Get-ChildItem $_ -Directory} | Select-Object FullName | ForEach-Object {$quickAccess.Add($_.FullName) | Out-Null}

    if($files){
        $quickAccessFiles = $quickAccess | ForEach-Object {Get-ChildItem $_ -File} | Select-Object FullName
        $quickAccessFiles | ForEach-Object {$quickAccess.Add($_.FullName) | Out-Null}
        # $args = $args | Where-Object {$_ -ne "-file"}
    }

    # Integration with Z: Gets cdHistory and add it to the quickAccess
    if ((Test-Path -Path $cdHistory)) {
        $cdHistorySet =  [System.Collections.Generic.HashSet[string]]@(Get-Content -Path $cdHistory -Encoding UTF8 | Where-Object { (-not [String]::IsNullOrWhiteSpace($_)) } | ForEach-Object {$_.Substring(25)})
        $cdHistorySet | ForEach-Object {$quickAccess.Add($_) | Out-Null}
        
        if($files){
            # Add files as well?
        }
    }
    # =============================================
    
    if($multi){
        $args += '-m'
    }

    $selectedFolder = ($quickAccess | fzf $args --height 40)

    if(!$selectedFolder){
        return
    }

    return $selectedFolder

}

Export-ModuleMember -Function zf