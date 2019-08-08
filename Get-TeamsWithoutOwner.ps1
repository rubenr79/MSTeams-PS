function Get-AllTeams {
    param([string]$token)
    
    $url = "https://graph.microsoft.com/beta/groups?`$filter=resourceProvisioningOptions/Any(x:x eq 'Team')"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
    $response.value
}

$scopes = 'Group.Read.All'
Connect-PnPOnline -Scopes $scopes

$token = Get-PnPAccessToken

$teams = Get-AllTeams $token

$result = @()

foreach($team in $teams) {
    $owners = Get-TeamOwners $token $team.id

    if ($owners -eq $null) {
        $members = Get-TeamMembers $token $team.id

        $teamToAdd = "" | Select-Object "TeamId","TeamName"
        $teamToAdd.TeamId = $team.id
        $teamToAdd.TeamName = $team.displayName

        $result += $teamToAdd
    }
}

$result