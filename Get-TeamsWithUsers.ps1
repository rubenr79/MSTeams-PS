function Get-AllTeams {
    param([string]$token)
    
    $url = "https://graph.microsoft.com/beta/groups?`$filter=resourceProvisioningOptions/Any(x:x eq 'Team')"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
    $response.value
}

function Get-TeamOwners {
    param([string]$token, [System.Guid] $teamID)
    
    $url = "https://graph.microsoft.com/v1.0/groups/" + $teamID + "/owners"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
    
    return $response.value | ToArray
}

function Get-TeamMembers {
    param([string]$token, [System.Guid] $teamID)
    
    $url = "https://graph.microsoft.com/v1.0/groups/" + $teamID + "/members"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
    
    return $response.value | ToArray
}

function ToArray
{
  begin
  {
    $output = @();
  }
  process
  {
    $output += $_;
  }
  end
  {
    return ,$output;
  }
}

$scopes = 'Group.Read.All'
Connect-PnPOnline -Scopes $scopes

$token = Get-PnPAccessToken

$teams = Get-AllTeams $token

$result = @()

foreach($team in $teams) {
    $owners = Get-TeamOwners $token $team.id
    $members = Get-TeamMembers $token $team.id
    $guests = $members | where {$_.userPrincipalName -like '*#EXT#*'}

    $teamToAdd = "" | Select-Object "TeamId","TeamName","Owners","Members","Guests"
    $teamToAdd.TeamId = $team.id
    $teamToAdd.TeamName = $team.displayName
    $teamToAdd.Owners = $owners.count
    $teamToAdd.Members = $members.count
    $teamToAdd.Guests = $guests.count

    $result += $teamToAdd
}

$result | Format-Table