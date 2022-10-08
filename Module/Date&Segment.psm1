function ConvertTo-Time {
    param ($Segment)
    New-TimeSpan -second (($Segment + 1) * 10)
}

function ConvertTo-Segment {
    param ([Timespan]$Time)
    $Segment = $Time.TotalSeconds / 10
    [math]::Floor($Segment)
}