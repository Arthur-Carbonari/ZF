$myFoldersPath = Join-Path $PSScriptRoot .\myFolders.txt

$rootFolders = Get-Content $myFoldersPath

if ($args -contains "add"){
    $cwd = (Get-Location).Path

    if ($cwd -in $rootFolders){
        return
    }

    $rootFolders += $cwd
    $rootFolders | Out-File $myFoldersPath
    return
}

if ($args -contains "rmv"){
    $cwd = (Get-Location).Path

    if ($cwd -notin $rootFolders){
        return
    }

    $rootFolders = $rootFolders | Where-Object { $_ -ne $cwd }
    $rootFolders | Out-File $myFoldersPath
    return
}

$foldersSet = [System.Collections.Generic.HashSet[string]]@($rootFolders)

$rootFolders | ForEach-Object {Get-ChildItem $_ -Directory} | Select-Object FullName | ForEach-Object {$foldersSet.Add($_.FullName) | Out-Null}

if ($args -contains "-file"){
    $filesPath = @()
    $foldersSet | ForEach-Object {Get-ChildItem $_ -File} | Select-Object FullName | ForEach-Object {$filesPath += $_.FullName}
    $filesPath | ForEach-Object {$foldersSet.Add($_) | Out-Null}
    $args = $args | Where-Object {$_ -ne "-file"}
}

if ($args -contains "ls"){
    return $foldersSet
}

# Integration with z

# Gets the path to .cdHistory folder
$safehome = if ([String]::IsNullOrWhiteSpace($Env:HOME)) { $env:USERPROFILE } else { $Env:HOME } 
$cdHistory = Join-Path -Path $safehome -ChildPath '\.cdHistory'

# Get cdHistory and add it to folder set
if ((Test-Path -Path $cdHistory)) {
  Get-Content -Path $cdHistory -Encoding UTF8 | ? { (-not [String]::IsNullOrWhiteSpace($_)) } | ForEach-Object {$foldersSet.Add($_.Substring(25)) | Out-Null}
}

# =============================================

$selectedFolder = ($foldersSet | fzf $args)

if(!$selectedFolder){
    exit
}

return $selectedFolder
