# ANCHOR - user
function Get-TwitchUserInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Nickname
    )
    process {
        $ChannelName = ConvertTo-ChannelName $Nickname
        (curl -s -H "Client-Id: $ClientID" -H "Authorization: Bearer $Auth" -X GET "https://api.twitch.tv/helix/users?login=$ChannelName" | ConvertFrom-Json).data
    }
    # id
}

# ANCHOR - stream
function Get-TwitchStreamInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Nickname
    )
    process {
        $ChannelName = ConvertTo-ChannelName $Nickname
        $TwitchStreamInfo = (curl -s -H "Client-Id: $ClientID" -H "Authorization: Bearer $Auth" -X GET "https://api.twitch.tv/helix/streams?user_login=$ChannelName" --max-time 5 --retry 5 --retry-delay 1 -S | ConvertFrom-Json).data
        if (($TwitchStreamInfo.type) -eq 'live') {
            $TwitchStreamInfo
        }
        else {
            'Offline'
        }
    }
}

function Get-TwitchTrackerDate {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$TwitchTrackerUrl
    )
    $Response = (Invoke-WebRequest -Uri $TwitchTrackerUrl -Verbose:$false).Content
    $Response -match 'stream on\s(?<Date>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})' | Out-Null
    ([System.DateTimeOffset]"$($Matches.Date) +00:00").LocalDateTime
}

# ANCHOR - vod
function Get-TwitchVodList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Nickname
    )
    process {
        $Id = (Get-TwitchUserInfo $Nickname).id
        Write-Verbose "[$((Get-Date).ToString('G'))] User id is $Id."
        (curl -s -H "Client-Id: $ClientID" -H "Authorization: Bearer $Auth" -X GET "https://api.twitch.tv/helix/videos?user_id=$Id&first=100" --max-time 5 --retry 5 --retry-delay 1 -S | ConvertFrom-Json).data
    }
}

function Get-TwitchVodInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$VideoId
    )
    process {
        (curl -s -H "Client-Id: $ClientID" -H "Authorization: Bearer $Auth" -X GET "https://api.twitch.tv/helix/videos?id=$VideoId" | ConvertFrom-Json).data
    }
}

function Get-TwitchVodUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Arg0,
        [Parameter()]
        [string]$Arg1,
        [ValidateRange(0, 59)]
        [int]$Hour,
        [ValidateRange(0, 59)]
        [int]$Minute,
        [ValidateRange(1, 31)]
        [int]$Day,
        [ValidateRange(1, 12)]
        [int]$Month,
        [ValidatePattern('\d{4}')]
        [int]$Year
    )
    begin {
        $Domains = @(
            'https://d3vd9lfkzbru3h.cloudfront.net/',
            'https://dgeft87wbj63p.cloudfront.net/',
            'https://d2nvs31859zcd8.cloudfront.net/',
            'https://d1m7jfoe9zdc1j.cloudfront.net/',
            'https://d1mhjrowxxagfy.cloudfront.net/',
            'https://dqrpb9wgowsf5.cloudfront.net/',
            'https://ds0h3roq6wcgc.cloudfront.net/',
            'https://d1ymi26ma8va5x.cloudfront.net/',
            'https://d2aba1wr3818hz.cloudfront.net/',
            'https://d2e2de1etea730.cloudfront.net/',
            'https://d2nvs31859zcd8.cloudfront.net/',
            'https://d2vjef5jvl6bfs.cloudfront.net/',
            'https://d3aqoihi2n8ty8.cloudfront.net/',
            'https://d3c27h4odz752x.cloudfront.net/',
            'https://ddacn6pr5v0tl.cloudfront.net/'
        )
        $StreamsChartsPattern = 'https://streamscharts.com/channels/(?<ChannelName>\w+)/streams/(?<StreamId>\d{11})/*'
        $TwitchTrackerPattern = 'https://twitchtracker.com/(?<ChannelName>\w+)/streams/(?<StreamId>\d{11}/*)'
    }
    process {
        if ($Arg1) {
            $ManualInputStreamId = $true
        }
        switch ($Arg0) {
            { $Arg0 -match "1\d{9}$" } {
                Write-Verbose "[$((Get-Date).ToString('G'))] Vod id"
                $VodId = $_.Split('/')[-1]
                $VodInfo = Get-TwitchVodInfo $VodId
                $VodType = $VodInfo.type
                $VodTempUrl = $VodInfo.thumbnail_url.Split('/')
                Write-Verbose "[$((Get-Date).ToString('G'))] Domain is $($VodTempUrl[4])."
                Write-Verbose "[$((Get-Date).ToString('G'))] Base url is $($VodTempUrl[5])."
                if ($VodType -eq "archive") {
                    $VodUrl = "https://$($VodTempUrl[4]).cloudfront.net/$($VodTempUrl[5])/chunked/index-dvr.m3u8"
                }
                else {
                    $VodUrl = "https://$($VodTempUrl[4]).cloudfront.net/$($VodTempUrl[5])/chunked/highlight-$VodId.m3u8"
                }
                if (Test-ExistingFile $VodUrl) {
                    Write-Verbose "[$((Get-Date).ToString('G'))] Vod url is existent."
                    return $VodUrl
                }
                else {
                    return "Something need to be fixed."
                }
            }
            { $Arg0 -match $StreamsChartsPattern -and $Arg1 -match "\d{2}\s\w+\s\d{4},\s\d{2}:\d{2}" } {
                Write-Verbose "[$((Get-Date).ToString('G'))] Streams Charts url"
                $_ -match $StreamsChartsPattern | Out-Null
                $ChannelName = $Matches.ChannelName
                $StreamId = $Matches.StreamId
                $Arg1 += " +00:00"
                $InputDate = [System.DateTimeOffset]::ParseExact($Arg1, 'dd MMM yyyy, HH:mm K', $null)
                Write-Verbose "[$((Get-Date).ToString('G'))] Input date (UTC) is $($InputDate.ToString('G'))."
                Write-Verbose "[$((Get-Date).ToString('G'))] Input date (Local) is $($InputDate.LocalDateTime.ToString('G'))."
            }
            { $Arg1 -match "\d{11}" } {
                Write-Verbose "[$((Get-Date).ToString('G'))] Nickname, Stream id and date"
                $ChannelName = ConvertTo-ChannelName $Arg0
                $StreamId = $Arg1
                $Now = Get-Date
                if (!$Year) {
                    $Year = $Now.Year
                    $AutoYear = $true
                }
                if (!$Month) {
                    $Month = $Now.Month
                    $AutoMonth = $true
                }
                if (!$Day) {
                    $Day = $Now.Day
                    $AutoDay = $true
                }
                $InputDate = [System.DateTimeOffset]("{0:d4}-{1:d2}-{2:d2}T{3:d2}:{4:d2}:00Z" -f $Year, $Month, $Day, $Hour, $Minute)
                if ($InputDate -gt $Now -and $AutoDay) {
                    $InputDate = $InputDate.AddDays(-1)
                }
                elseif ($InputDate -gt $Now -and $AutoMonth) {
                    $InputDate = $InputDate.AddMonths(-1)
                }
                elseif ($InputDate -gt $Now -and $AutoYear) {
                    $InputDate = $InputDate.AddYears(-1)
                }
                Write-Verbose "[$((Get-Date).ToString('G'))] Input date (UTC) is $($InputDate.ToString('G'))."
                Write-Verbose "[$((Get-Date).ToString('G'))] Input date (Local) is $($InputDate.LocalDateTime.ToString('G'))."
            }
            { $Arg0 -match $TwitchTrackerPattern } {
                Write-Verbose "[$((Get-Date).ToString('G'))] Twitch Tracker url"
                $_ -match $TwitchTrackerPattern | Out-Null
                $ChannelName = $Matches.ChannelName
                $StreamId = $Matches.StreamId
                $StreamDate = Get-TwitchTrackerDate $_
            }
            default {
                Write-Verbose "[$((Get-Date).ToString('G'))] Nickname"
                $ChannelName = ConvertTo-ChannelName $_
                for ($i = 0; $i -lt 30; $i++) {
                    if ($i -gt 0) {
                        Write-Verbose "[$((Get-Date).ToString('G'))]     Hold on 2 seconds."
                        Start-Sleep -Seconds 2
                    }
                    Write-Verbose "[$((Get-Date).ToString('G'))]     Try $i times."
                    $StreamInfo = Get-TwitchStreamInfo $_
                    if ( ($StreamInfo -ne 'Offline') -and ($null -ne $StreamInfo) ) {
                        Write-Verbose "[$((Get-Date).ToString('G'))] Find stream info."
                        break
                    }
                    elseif ($StreamInfo -eq 'Offline') {
                        return "Offline"
                    }
                }
                $StreamId = $StreamInfo.id
                $StreamDate = ([System.DateTimeOffset]$StreamInfo.started_at).LocalDateTime
                $During = (Get-Date) - $StreamDate
                $WaitTime = [timespan]'00:00:45'
                if ($During -lt $WaitTime) {
                    Write-Verbose "[$((Get-Date).ToString('G'))] During is $During."
                    Start-Sleep -Seconds ($WaitTime.TotalSeconds - $During.TotalSeconds)
                }
            }
        }
        if (!$ManualInputStreamId) {
            Write-Verbose "[$((Get-Date).ToString('G'))] Stream id is $StreamId."
            Write-Verbose "[$((Get-Date).ToString('G'))] Stream date is $StreamDate."
            $UnixTime = ([System.DateTimeOffset]$StreamDate).ToUnixTimeSeconds()
            for ($i = 0; $i -lt 2; $i++) {
                if ($i -eq 1) {
                    Write-Verbose "[$((Get-Date).ToString('G'))] Unix time - 1."
                    $UnixTime --
                }
                Write-Verbose "[$((Get-Date).ToString('G'))] Unix time is $UnixTime."
                $BaseUrl = "$ChannelName`_$StreamId`_$UnixTime"
                $BaseUrlStream = [IO.MemoryStream]::new([byte[]][char[]]$BaseUrl)
                $HashedBaseUrl = ((Get-FileHash -InputStream $BaseUrlStream -Algorithm SHA1).Hash.ToLower()).Substring(0, 20)
                # cheack
                foreach ($Domain in $Domains) {
                    Write-Verbose "[$((Get-Date).ToString('G'))]     Check domain $Domain."
                    $VodUrl = "$Domain$HashedBaseUrl`_$BaseUrl/chunked/index-dvr.m3u8"
                    $Response = Invoke-WebRequest -URI $VodUrl -Method Head -SkipHttpErrorCheck -TimeoutSec 10 -Verbose:$false
                    if ($Response.StatusCode -eq '200') {
                        return $VodUrl
                    }
                }
            }
        }
        else {
            $VodUrls = @()
            for ($Second = 0; $Second -lt 60; $Second++) {
                $DateUTC = $InputDate.AddSeconds($Second)
                $UnixTime = $DateUTC.ToUnixTimeSeconds()
                $BaseUrl = "$ChannelName`_$StreamId`_$UnixTime"
                $mystream = [IO.MemoryStream]::new([byte[]][char[]]$BaseUrl)
                $HashedBaseUrl = (Get-FileHash -InputStream $mystream -Algorithm SHA1).Hash.ToLower().Substring(0, 20)
                foreach ($Domain in $Domains) {
                    $VodUrls += "$Domain$HashedBaseUrl`_$BaseUrl/chunked/index-dvr.m3u8"
                }
            }
            # $VodUrls > '123.txt'
            $Collections = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
            $VodUrls | ForEach-Object -ThrottleLimit 360 -Parallel {
                $Response = Invoke-WebRequest -URI $_ -Method Head -SkipHttpErrorCheck -TimeoutSec 10 -ErrorAction Continue
                $Concurrent = $using:Collections
                if ($Response.StatusCode -eq '200') {
                    [void]$Concurrent.TryAdd($_)
                }
            }
            if (([array]$Collections)[0] -match '^https://') {
                return ([array]$Collections)[0]
            }
        }
        "Vod is not found."
    }
}

# ANCHOR - segment
function Get-Segment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$SourceUrl
    )
    $VodUrl = Format-TwtitchVodUrl $SourceUrl
    $Filename = "$Env:MyTemp\$($VodUrl.Split('/')[3]).m3u8"
    wget $VodUrl -q -N -O $Filename
    $Segment = $((Get-Content $Filename)[-2]).Split('.')[0]
    Remove-Item $Filename
    $Segment.Replace('-unmuted','')
}

function Format-TwtitchVodUrl {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$VodUrl
    )
    if (($VodUrl -notlike ".m3u8$") -or ($VodUrl -notlike "*chunked*")) {
        Write-Verbose "[$((Get-Date).ToString('G'))] Standardize url."
        $MatchSlash = ($VodUrl | Select-String '/' -AllMatches).Matches
        $NextToLastSlash = $MatchSlash[-2].Index
        $VodUrl = $VodUrl.Substring(0, $NextToLastSlash) + '/chunked/index-dvr.m3u8'
    }
    $VodUrl
}

# ANCHOR - chat
# function Get-TwitchVodChat {
#     param ($VodId)
#     $VodId = '1527827092'
#     $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
#     $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36"
#     $Response0 = Invoke-WebRequest -UseBasicParsing `
#         -Uri "https://api.twitch.tv/v5/videos/$VodId/comments?content_offset_seconds=0" `
#         -WebSession $session `
#         -Headers @{ "client-id"="kimne78kx3ncx6brgo4mv6wki5h1ko" } `
#         -ContentType "application/json; charset=UTF-8"
#     $Raw0 = $Response0.Content | ConvertFrom-Json
#     $Content = $Raw0.comments
#     $cursor = $Raw0._next
#     while ($null -ne $cursor) {
#         $Response1 = Invoke-WebRequest -UseBasicParsing `
#         -Uri "https://api.twitch.tv/v5/videos/$VodId/comments?cursor=$cursor" `
#         -WebSession $session `
#         -Headers @{ "client-id"="kimne78kx3ncx6brgo4mv6wki5h1ko" } `
#         -ContentType "application/json; charset=UTF-8"
#         $Raw1 = $Response1.Content | ConvertFrom-Json
#         $Content += $Raw1.comments
#         $cursor = $Raw1._next
#     }
#     $Content | ctj -Depth 9 > "$Env:MyVod\789.json"
# }