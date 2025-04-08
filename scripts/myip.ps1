# This Powershell script returns your public facing IP address (WAN-IP). 
# To be used in conjunction with anything you particularly need your public IPv4
# for access purposes when setting public cloud security groups.

# Old - Do not need to use
# Resolve-DnsName -Name myip.opendns.com  -Server 208.67.222.222 -DnsOnly -Type A | Select-Object | Format-List *

# Below command uses DNS resolution and formats response to JSON. Will record as {"IPAddress":"<ip>"}
# Uncomment line below if you want to the DNS type.

# Resolve-DnsName -Name myip.opendns.com -Server 208.67.222.222 -DnsOnly -Type A | Select-Object -Property IPAddress | ConvertTo-Json

# Or you can also use API call to return your IP. Simpler in some ways because you will get a universal output
# regardless of OS type -> {"ip":"<ip>"} in JSON format -> meaning you don't have to regex or perform string manipulation (yay!).
# Uncomment the line below if you wish to use API call.

Invoke-WebRequest -Uri https://api.ipify.org?format=json | Select-Object -Property Content -ExpandProperty Content