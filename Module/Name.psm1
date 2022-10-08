function ConvertTo-Nickname {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ChannelName
    )
    process {
        switch ($ChannelName) {
            'jd_onlymusic' { $Nickname = 'jd' }
            'r_meme' { $Nickname = 'rme' }
            'k29309013' { $Nickname = 'wf' }
            'isteenlee' { $Nickname = 'xt' }
            'matonglah' { $Nickname = 'lah' }
            'littleblue_om' { $Nickname = 'lb' }
            'garbaged' { $Nickname = 'bb' }
            'akaonikou1207' { $Nickname = '56' }
            'dd_connie' { $Nickname = 'dd' }
            'taiwanmeme' { $Nickname = 'meme' }
            'ckshchen' { $Nickname = 'mt' }
            'miyachuang' { $Nickname = 'miya' }
            'banana_7788' { $Nickname = 'ban' }
            'howeasymo27' { $Nickname = 'momo' }
            'zhiting_li' { $Nickname = 'zt' }
            'smallmatonglah' { $Nickname = 'slah' }
            'a_iga' { $Nickname = '30' }
            'liyingyingder' { $Nickname = 're' }
            'joeykaotyk' { $Nickname = 'joey' }
            'fanfan' { $Nickname = 'fan' }
            'cooksux' { $Nickname = 'cook' }
            'jakenbakelive' { $Nickname = 'jake' }
            'robcdee' { $Nickname = 'rob' }
            'niwenwen' { $Nickname = 'wen' }
            'plumy_' { $Nickname = 'plumy' }
            'jessicakohh' { $Nickname = 'jessica' }
            'bubbly_live' { $Nickname = 'bubbly' }
            'quitelola' { $Nickname = 'lola' }
            'yunicorn19' { $Nickname = 'yuni' }
            'waterlynn' { $Nickname = 'water' }
            'seolahh' { $Nickname = 'seol' }
            'bonnierabbit' { $Nickname = 'bonnie' }
            'peeguutv' { $Nickname = 'ass' }
            'jaystreazy' { $Nickname = 'jay' }
            'jinritv' { $Nickname = 'jinri' }
            'bunniejin' { $Nickname = 'bunnie' }
            'cc979' { $Nickname = 'cc' }
            'keith_lin_' { $Nickname = 'kei' }
            'hellrena' { $Nickname = 'rena' }
            'tar00nijima' { $Nickname = '00' }
            'qingtian030' { $Nickname = 'qing' }
            'niiiiiiiiiico12' { $Nickname = 'nico' }
            'yuuko_live' { $Nickname = '7l' }
            default { $Nickname = $ChannelName }
        }
        $Nickname
    }
}
function ConvertTo-ChannelName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Nickname
    )
    process {
        switch ( $Nickname ) {
            'jd' { $ChannelName = 'jd_onlymusic' }
            'rme' { $ChannelName = 'r_meme' }
            'wf' { $ChannelName = 'k29309013' }
            'xt' { $ChannelName = 'isteenlee' }
            'lah' { $ChannelName = 'matonglah' }
            'lb' { $ChannelName = 'littleblue_om' }
            'bb' { $ChannelName = 'garbaged' }
            '56' { $ChannelName = 'akaonikou1207' }
            'dd' { $ChannelName = 'dd_connie' }
            'meme' { $ChannelName = 'taiwanmeme' }
            'mt' { $ChannelName = 'ckshchen' }
            'miya' { $ChannelName = 'miyachuang' }
            'ban' { $ChannelName = 'banana_7788' }
            'momo' { $ChannelName = 'howeasymo27' }
            'zt' { $ChannelName = 'zhiting_li' }
            'slah' { $ChannelName = 'smallmatonglah' }
            '30' { $ChannelName = 'a_iga' }
            're' { $ChannelName = 'liyingyingder' }
            'joey' { $ChannelName = 'joeykaotyk' }
            'fan' { $ChannelName = 'fanfan' }
            'cook' { $ChannelName = 'cooksux' }
            'jake' { $ChannelName = 'jakenbakelive' }
            'rob' { $ChannelName = 'robcdee' }
            'wen' { $ChannelName = 'niwenwen' }
            'plumy' { $ChannelName = 'plumy_' }
            'jessica' { $ChannelName = 'jessicakohh' }
            'bubbly' { $ChannelName = 'bubbly_live' }
            'lola' { $ChannelName = 'quitelola' }
            'yuni' { $ChannelName = 'yunicorn19' }
            'water' { $ChannelName = 'waterlynn' }
            'seol' { $ChannelName = 'seolahh' }
            'bonnie' { $ChannelName = 'bonnierabbit' }
            'ass' { $ChannelName = 'peeguutv' }
            'jay' { $ChannelName = 'jaystreazy' }
            'jinri' { $ChannelName = 'jinritv' }
            'bunnie' { $ChannelName = 'bunniejin' }
            'cc' { $ChannelName = 'cc979' }
            'kei' { $ChannelName = 'keith_lin_' }
            'rena' { $ChannelName = 'hellrena' }
            '00' { $ChannelName = 'tar00nijima' }
            'qing' { $ChannelName = 'qingtian030' }
            'nico' { $ChannelName = 'niiiiiiiiiico12' }
            '7l' { $ChannelName = 'yuuko_live' }
            default { $ChannelName = $Nickname }
        }
        $ChannelName
    }
}