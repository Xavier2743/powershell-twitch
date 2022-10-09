# powershell-twitch

## Applications
+ ffmpeg (scoop)
+ Streamlink (scoop)
+ curl (scoop)
+ Wget (scoop)
+ [N_m38DL](https://github.com/nilaoda/N_m3u8DL-CLI)
+ [TwitchDownloaderCLI](https://github.com/lay295/TwitchDownloader)
+ [ChromeDriver](https://sites.google.com/chromium.org/driver/downloads?authuser=0)

## Modules
+ [BurntToast](https://www.powershellgallery.com/packages/BurntToast/)
+ [Selenium.WebDriver](https://www.nuget.org/packages/Selenium.WebDriver) (nupkg/lib/netXX/)

## My Modules

### Date and Segment

#### ConvertTo-Time (ctt)
```powershell
ConvertTo-Time 10    # 00:01:50
```

#### ConvertTo-Segment (cts)
```powershell
ConvertTo-Segment 1:10:50    # 425
```

### Download

### FFmpeg

### File

### Info

Need Twitch api client id and auth

#### Get-TwitchUserInfo (gui)
```powershell
Get-TwitchUserInfo 'xqc'

# id                : 71092938
# login             : xqc
# display_name      : xQc
# type              :
# broadcaster_type  : partner
# description       : THE BEST AT ABSOLUTELY EVERYTHING. THE JUICER. LEADER OF THE JUICERS.
# profile_image_url : https://static-cdn.jtvnw.net/jtv_user_pictures/xqc-profile_image-9298dca608632101-300x300.jpeg
# offline_image_url : https://static-cdn.jtvnw.net/jtv_user_pictures/dc330b28-9c9f-4df4-b8b6-ff56b3c094fd-channel_offline_image-1920x1080.png
# view_count        : 524730962
# created_at        : 2014-09-12 23:50:05
```

#### Get-TwitchStreamInfo (gsi)
```powershell
Get-TwitchStreamInfo 'xhibaoger'

# id            : 39752311911
# user_id       : 25086797
# user_login    : xhibaoger
# user_name     : 火暴可可
# game_id       : 491334
# game_name     : Kartrider
# type          : live
# title         : 爆哥/NEAL  好久不見
# viewer_count  : 17743
# started_at    : 2022-10-09 13:10:09
# language      : zh
# thumbnail_url : https://static-cdn.jtvnw.net/previews-ttv/live_user_xhibaoger-{width}x{height}.jpg
# tag_ids       : {74c92063-a389-4fd2-8460-b1bb82b04ec7}
# is_mature     : False
```

#### Get-TwitchTrackerDate
Return UTC time
```powershell
Get-TwitchTrackerDate 'https://twitchtracker.com/jd_onlymusic/streams/39695350135'    # 2022-09-21 12:59:49
```

#### Get-TwitchVodList (gvl)
```powershell
Get-TwitchVodList 'howeasymo27'

# id             : 1617703209
# stream_id      : 1
# user_id        : 714224253
# user_login     : howeasymo27
# user_name      : 摸摸爹斯
# title          : 精華片段：10/7 曉組織 / 微開箱( •̀ ω •́ )✧
# description    :
# created_at     : 2022-10-07 19:03:11
# published_at   : 2022-10-07 19:03:11
# url            : https://www.twitch.tv/videos/1617703209
# thumbnail_url  : https://static-cdn.jtvnw.net/cf_vods/d3vd9lfkzbru3h/b01c15991b0f34da0d59_howeasymo27_66150465024_9162206118//thumb/thumb1617703209-%{width}x%{height}.jpg
# viewable       : public
# view_count     : 67
# language       : zh
# type           : highlight
# duration       : 4h37m44s
# muted_segments :
#
# ...
```

#### Get-TwitchVodInfo (gvi)
```powershell
Get-TwitchVodInfo '1511303463'

# id             : 1511303463
# stream_id      : 1
# user_id        : 714224253
# user_login     : howeasymo27
# user_name      : 摸摸爹斯
# title          : 精華片段：6/9  練習台
# description    :
# created_at     : 2022-06-22 22:12:30
# published_at   : 2022-06-22 22:12:30
# url            : https://www.twitch.tv/videos/1511303463
# thumbnail_url  : https://static-cdn.jtvnw.net/cf_vods/d3vd9lfkzbru3h/877a1786f54e0a2f156a_howeasymo27_16263368809_8590899066//thumb/thumb1511303463-%{width}x%{height}.jpg
# viewable       : public
# view_count     : 96
# language       : zh
# type           : highlight
# duration       : 10h5m45s
# muted_segments :
```

#### Get-TwitchVodUrl (gvu)
1. Nickname (only on live stream)
    ```powershell
    Get-TwitchVodUrl 'jaystreazy'

    # https://d2nvs31859zcd8.cloudfront.net/f73a21f00ebae9c81145_jaystreazy_41370164811_1665320026/chunked/index-dvr.m3u8
    ```
2. Vod id (vod id or video url)
    ```powershell
    Get-TwitchVodUrl '1511305336'

    # https://d3vd9lfkzbru3h.cloudfront.net/2bfa24edeae13b464b57_howeasymo27_53879328638_7462980500/chunked/highlight-1511305336.m3u8
    ```
3. Twitch Tracker url
    ```powershell
    Get-TwitchVodUrl 'https://twitchtracker.com/jd_onlymusic/streams/39695350135'

    # https://d3vd9lfkzbru3h.cloudfront.net/799d66c6360a54f5149e_jd_onlymusic_39695350135_1663765189/chunked/index-dvr.m3u8
    ```
4. Streams Charts url + date(UTC)

    Date format: dd MMM yyyy, HH:mm\
    (If you don't know what it is, just copy the text after 'the start time:' on the Streams Charts website.)
    ```powershell
    Get-TwitchVodUrl 'https://streamscharts.com/channels/jd_onlymusic/streams/39695350135' '21 Sep 2022, 12:59'

    # https://d1mhjrowxxagfy.cloudfront.net/799d66c6360a54f5149e_jd_onlymusic_39695350135_1663765189/chunked/index-dvr.m3u8
    ```
5. Nickname + stream id + date(UTC)

    now - stream date < a day, input hour and minute\
    now - stream date < a month, input hour, minute and day\
    now - stream date < a year, input hour, minute, day and month\
    now - stream date >= a year, input all (hour, minute, day, month and year)
    ```powershell
    Get-TwitchVodUrl 'jd_onlymusic' '39695350135' 12 59 21

    # https://d1mhjrowxxagfy.cloudfront.net/799d66c6360a54f5149e_jd_onlymusic_39695350135_1663765189/chunked/index-dvr.m3u8
    ```

If it's possible, use 1, 2 or 3 first.

#### Get-Segment
```powershell
Get-Segment 'https://d1mhjrowxxagfy.cloudfront.net/799d66c6360a54f5149e_jd_onlymusic_39695350135_1663765189/chunked/index-dvr.m3u8'

# 1107
```

#### Format-TwtitchVodUrl
```powershell
Format-TwtitchVodUrl 'https://d1mhjrowxxagfy.cloudfront.net/799d66c6360a54f5149e_jd_onlymusic_39695350135_1663765189/720p60/10.ts'

# 'https://d1mhjrowxxagfy.cloudfront.net/799d66c6360a54f5149e_jd_onlymusic_39695350135_1663765189/chunked/index-dvr.m3u8'
```

### Name

#### ConvertTo-Nickname
```powershell
ConvertTo-Nickname joeykaotyk    # joey
```

#### ConvertTo-ChannelName
```powershell
ConvertTo-ChannelName joey    # joeykaotyk
```

### Notification

### Test

## My Scripts