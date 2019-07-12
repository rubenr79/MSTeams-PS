function Get-AllTeams {
    param([string]$token)
    
    $url = "https://graph.microsoft.com/beta/groups?`$filter=resourceProvisioningOptions/Any(x:x eq 'Team')"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
    $response.value
}

function Get-TeamChannels {
    param([string]$token, [System.Guid] $teamID)
    
    $url = "https://graph.microsoft.com/v1.0/teams/" + $teamID + "/channels"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
    $response.value
}

function Get-ChannelTabs {
    param([string]$token, [System.Guid] $teamID, [string] $channelID)
    
    $url = "https://graph.microsoft.com/v1.0/teams/" + $teamID + "/channels/" + $channelID + "/tabs"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
    $response.value
}

$scopes = 'Group.Read.All'
Connect-PnPOnline -Scopes $scopes

$token = Get-PnPAccessToken

$teams = Get-AllTeams $token

$channels = @()

foreach($team in $teams) {
    $teamChannels = Get-TeamChannels $token $team.id

    foreach($channel in $teamChannels) {
        $channelToAdd = "" | Select-Object "TeamId","TeamName","ChannelId","ChannelName", "ChannelTabs"
        $channelToAdd.TeamId = $team.id
        $channelToAdd.TeamName = $team.displayName
        $channelToAdd.ChannelId = $channel.id
        $channelToAdd.ChannelName = $channel.displayName

        $channelTabs = Get-ChannelTabs $token $team.id $channel.id

        $channelToAdd.ChannelTabs = $channelTabs

        $channels += $channelToAdd
    }
}

$channels | Format-Table
