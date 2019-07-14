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
    
    $url = "https://graph.microsoft.com/v1.0/teams/" + $teamID + "/channels/" + $channelID + "/tabs/"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
    $response.value
}

function Remove-ChannelTab {
    param([string]$token, [System.Guid] $teamID, [string] $channelID, [System.Guid] $tabID)
    
    $url = "https://graph.microsoft.com/v1.0/teams/" + $teamID + "/channels/" + $channelID + "/tabs/" + $tabID
    Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"} -Method Delete
    
}

$scopes = 'Group.ReadWrite.All'
Connect-PnPOnline -Scopes $scopes

$token = Get-PnPAccessToken

$teams = Get-AllTeams $token

foreach($team in $teams) {
    $teamChannels = Get-TeamChannels $token $team.id

    foreach($channel in $teamChannels) {
        
        $channelTabs = Get-ChannelTabs $token $team.id $channel.id

        foreach($tab in $channelTabs) {
            if ([bool]($tab.configuration.wikiTabId) -and -not [bool]($tab.configuration.hasContent)) {
                Remove-ChannelTab $token $team.id $channel.id $tab.id
            }
        }
    }
}

$channels | Format-Table
