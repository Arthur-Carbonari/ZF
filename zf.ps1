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

$foldersSet = [System.Collections.Generic.HashSet[string]]@($rootFolders)

$rootFolders | ForEach-Object {Get-ChildItem $_ -Directory} | Select-Object FullName | ForEach-Object {$foldersSet.Add($_.FullName) | Out-Null}

if ($args -contains "ls"){
    return $foldersSet
}

$selectedFolder = ($foldersSet | fzf @args)

if(!$selectedFolder){
    exit
}

return $selectedFolder
