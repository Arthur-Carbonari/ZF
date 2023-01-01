$myFoldersPath = Join-Path $PSScriptRoot .\myFolders.txt

$rootFolders = Get-Content $myFoldersPath

$foldersSet = [System.Collections.Generic.HashSet[string]]@($rootFolders)

$rootFolders | ForEach-Object {Get-ChildItem $_ -Directory} | Select-Object FullName | ForEach-Object {$foldersSet.Add($_.FullName) | Out-Null}

$selectedFolder = ($foldersSet | fzf $args)

if(!$selectedFolder){
    exit
}

return $selectedFolder
