# ANCHOR - m3u8
function Get-m3u8DL {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Name,
        [Parameter()]
        [string]$Filename
    )
    $Nickname = ConvertTo-Nickname $Name
    $ChannelName = ConvertTo-ChannelName $Nickname
    $Url = "https://www.twitch.tv/$ChannelName"
    $M3U8Url = streamlink $Url best --stream-url
    $Host.UI.RawUI.WindowTitle = "$Nickname | N_m3u8DL"
    if (!$Filename) {
        $Filename = "$Nickname`_$(Get-Date -Format "yyyyMMddTHHmmss")"
    }
    m3 $M3U8Url --workDir $Env:MyVod --saveName $Filename --enableMuxFastStart --retryCount "10"
    $Target = $Filename.Split('-')[1] # stream id
    if (!$Target) {
        $Target = $Filename.Split('_')[1] # date
    }
    Get-Item "$Env:MyVod\*$Target.ts" | Rename-Item -NewName { $_.Name -replace '^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}_', '' }
}

function Get-Streamlink {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Name,
        [Parameter()]
        [string]$Filename
    )
    $Nickname = ConvertTo-Nickname $Name
    $Url = "https://www.twitch.tv/$(ConvertTo-ChannelName $Nickname)"
    $OutputDirectory = Get-Filename -Filename $Filename -Nickname $Nickname -Suffix 'streamlink' -extension 'ts'
    $Host.UI.RawUI.WindowTitle = "$Nickname | Streamlink"
    streamlink -o $OutputDirectory --twitch-disable-ads $Url best
    Get-AudioNotification
}

function Get-FFmpeg {
    [CmdletBinding()]
    param ($Nickname, $Filename)
    $Url = "https://www.twitch.tv/$(ConvertTo-ChannelName $Nickname)"
    $M3U8Url = streamlink $Url best --stream-url
    $OutputDirectory = Get-Filename -Filename $Filename -Nickname $Nickname -Suffix 'ffmpeg' -extension 'ts'
    $Host.UI.RawUI.WindowTitle = "$Nickname | ffmpeg"
    ffmpeg -i $M3U8Url -c copy $OutputDirectory
    Get-AudioNotification
}

# TODO - youtube-dl can download

# ANCHOR - vod
function Get-TwitchTsSegment {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Arg,
        [Parameter()]
        [string]$Filename
    )
    begin {
        $Download = { wget $TsUrl -c -q --show-progress -P $OutputDirectory }
        $DownloadChat = {
            $VodId = (Get-TwitchVodList $Filename.Split('_')[0] | Where-Object stream_id -eq $StreamId).id
            if ( $VodId -and !(Test-Path "$Env:MyVod\$($Filename.Split('-')[0]).json") ) {
                Write-Verbose "[$((Get-Date).ToString('G'))] Vod id is $VodId."
                Get-TwitchChat $VodId $Filename
            }
        }
        $SearchFileCount = { (Get-ChildItem "$OutputDirectory\*.ts").Count - 1 }
        $SearchLost = { Search-LostPart -Directory $OutputDirectory -Max $ServerCount }
        $SearchMax = { Search-Maximum $OutputDirectory }
    }
    process {
        switch -Regex ($Arg) {
            "^https://" {
                Write-Verbose "[$((Get-Date).ToString('G'))] Vod url"
                $VodUrl = Format-TwtitchVodUrl $_
            }
            Default {
                Write-Verbose "[$((Get-Date).ToString('G'))] No vod url"
                $VodUrl = Get-TwitchVodUrl $_
            }
        }
        Write-Verbose "[$((Get-Date).ToString('G'))] M3U8 url is $VodUrl."
        if ($VodUrl -eq "Vod is not found." -or !$VodUrl) {
            Pause
        }
        # match
        $VodUrl -match '^https:\/\/(?<Domain>.+)\/(?<Sha>[0-9a-z]{20})_(?<ChannelName>.+)_(?<StreamId>[0-9]{11})_(?<UnixTime>[0-9]{10})\/(?<Quality>(chunked|[0-9]{2,3}0p[3-6]0))\/(?<Filename>.+)' | Out-Null
        $Nickname = ConvertTo-Nickname $Matches.ChannelName
        $StreamId = $Matches.StreamId
        Write-Verbose "[$((Get-Date).ToString('G'))] Stream id is $StreamId"
        $Host.UI.RawUI.WindowTitle = "$Nickname | Download vod"
        # filename
        if (!$Filename) {
            if (Test-Path "$Env:MyVod\*$StreamId") {
                Write-Verbose "[$((Get-Date).ToString('G'))] Has filename."
                $Filename = (Get-ChildItem "$Env:MyVod\*$StreamId").BaseName
            }
            else {
                Write-Verbose "[$((Get-Date).ToString('G'))] No filename."
                $UnixTime = $Matches.UnixTime
                $LocalTime = ([System.DateTimeOffset]::FromUnixTimeSeconds($UnixTime)).LocalDateTime
                $Date = $LocalTime.ToString('yyyyMMdd')
                $Filename = "$Nickname`_$Date-$StreamId"
            }
        }
        # path
        $OutputDirectory = "$Env:MyVod\$Filename"
        Write-Verbose "[$((Get-Date).ToString('G'))] Ts segment directory is $OutputDirectory."
        # init segment
        if (!(Test-Path $OutputDirectory)) {
            $i = 0
        }
        else {
            $i = & $SearchMax
        }
        Write-Verbose "[$((Get-Date).ToString('G'))] Start from $i."
        # download
        $VodUrlHeader = $VodUrl.Substring( 0, ($VodUrl.LastIndexOf('/')) )
        while ($true) {
            $TsUrl = "$VodUrlHeader/$i.ts"
            for ($j = 0; $j -lt 9; $j++) {
                if (Test-ExistingFile $TsUrl) {
                    break
                }
                if ($j -gt 5) {
                    Write-Verbose "[$((Get-Date).ToString('G'))]     $j"
                }
                Start-Sleep -Seconds 2
            }
            if ( ($j -ge 9) -and ((Get-TwitchStreamInfo $Nickname) -eq 'Offline') ) {
                break
            }
            & $Download
            $i++
        }
        Write-Verbose "[$((Get-Date).ToString('G'))] Download completed."
        # try to download chat | first time
        Write-Verbose "[$((Get-Date).ToString('G'))] Download chat first time."
        & $DownloadChat
        # after download
        Write-Verbose "[$((Get-Date).ToString('G'))] Check count."
        $FileCount = & $SearchFileCount
        if (Test-ExistingFile $VodUrl) {
            $ServerCount = [int](Get-Segment $VodUrl)
        }
        $i--
        if (($i -ne $FileCount) -or ($i -ne $ServerCount)) {
            Write-Verbose "[$((Get-Date).ToString('G'))]     Explorer count is $FileCount."
            Write-Verbose "[$((Get-Date).ToString('G'))]     Server count is $ServerCount."
            Write-Verbose "[$((Get-Date).ToString('G'))]     Downloaded count is $i."
            for ($j = 0; $j -lt 2; $j++) {
                $Lost0 = & $SearchLost
                Write-Verbose "[$((Get-Date).ToString('G'))] Lost array is $Lost0."
                foreach ($k in $Lost0) {
                    $TsUrl = "$VodUrlHeader/$k.ts"
                    & $Download
                }
                $Lost1 = & $SearchLost
                if (!$Lost1) {
                    break
                }
                else {
                    Write-Verbose "[$((Get-Date).ToString('G'))] Lost array is $Lost1."
                    if ((Test-ExistingFile "$VodUrlHeader$($Lost1[0])`-muted.ts")) {
                        foreach ($k in $Lost1) {
                            $TsUrl = "$VodUrlHeader/$k`-muted.ts"
                            & $Download
                        }
                        $Mute = $true
                    }
                }
            }
        }
        $FileCount = & $SearchFileCount
        if ($FileCount -ne $ServerCount) {
            & $DownloadChat
            Write-Verbose "[$((Get-Date).ToString('G'))] Explorer count is $FileCount."
            $Max = & $SearchMax
            if ($FileCount -ne $Max -or $Mute) {
                & $DownloadChat
                Pause
            }
        }
        # combine ts file
        Write-Verbose "[$((Get-Date).ToString('G'))] Combine ts segment."
        Join-TsFile $OutputDirectory
        # download chat
        Write-Verbose "[$((Get-Date).ToString('G'))] Download chat second time."
        & $DownloadChat
        Get-AudioNotification
    }
}

# ANCHOR - chat
function Get-TwitchChat {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$VodId,
        [Parameter()]
        [string]$Filename
    )
    process {
        if ($Filename) {
            Write-Verbose "[$((Get-Date).ToString('G'))] Has filename."
            $OutputDirectory = "$Env:MyVod\$($Filename.Split('-')[0]).json"
        }
        else {
            Write-Verbose "[$((Get-Date).ToString('G'))] No filename."
            $VodInfo = Get-TwitchVodInfo $VodId
            $StreamId = $VodInfo.stream_id
            $Nickname = ConvertTo-Nickname $VodInfo.user_login
            $VodDate = ([System.DateTimeOffset]$VodInfo.created_at).LocalDateTime
            Write-Verbose "[$((Get-Date).ToString('G'))] Stream id is $StreamId."
            Write-Verbose "[$((Get-Date).ToString('G'))] Title is $($VodInfo.title)."
            Write-Verbose "[$((Get-Date).ToString('G'))] Duration is $($VodInfo.duration)."
            Write-Verbose "[$((Get-Date).ToString('G'))] Type is $($VodInfo.type)."
            # csv
            $CsvDirectory = "$Env:MyDatabase\Twitch_$($VodDate.ToString('yyyy-MM')).csv"
            $CsvInfo = Import-Csv $CsvDirectory | Where-Object stream_id -eq $StreamId
            if ($CsvInfo) {
                Write-Verbose "[$((Get-Date).ToString('G'))] In csv."
                $StreamDate = ([System.DateTimeOffset]$CsvInfo.stream_started_at_local).ToLocalTime().ToString('yyyyMMdd')
                $Order = Format-TwtitchOrder $CsvInfo.order
                $OutputDirectory = "$Env:MyVod\$Nickname`_$StreamDate$Order.json"
            }
            else {
                Write-Verbose "[$((Get-Date).ToString('G'))] Not in csv."
                $OutputDirectory = "$Env:MyVod\$Nickname`_$($VodDate.ToString('yyyyMMdd'))-.json"
            }
        }
        Write-Verbose "[$((Get-Date).ToString('G'))] Json file directory is $OutputDirectory."
        # download
        tdc -m ChatDownload --id $VodId -o $OutputDirectory --chat-connections 50
        Write-Host ""
    }
}

# Get-duration
# Get-ChildItem *.ts | %{ ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal $_ }