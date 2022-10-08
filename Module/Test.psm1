function Test-ExistingFile {
    param ($Url)
    $Response = Invoke-WebRequest -URI $Url -Method Head -SkipHttpErrorCheck
    if ($Response.StatusCode -eq 200) {
        $true
    }
    else {
        $false
    }
}

function Search-Maximum {
    param ([System.IO.DirectoryInfo]$Directory)
    $All = Get-ChildItem "$Directory\*ts" | Sort-Object {[int]($_.Basename -replace '-muted', '')}
    if ($All) {
        [int]($All[-1].BaseName)
    }
    else {
        0
    }
}