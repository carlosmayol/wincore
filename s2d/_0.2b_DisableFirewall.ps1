# Fill in these variables with your values
$ServerList = "lab6_ws2019_03", "lab6_ws2019_04", "lab6_ws2019_05", "lab6_ws2019_06"

Invoke-Command ($ServerList) {Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled false}


