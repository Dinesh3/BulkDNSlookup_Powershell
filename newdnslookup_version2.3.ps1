 cls
# Script Version 2.3 - Modified 17-Feb-25 by Dinesh Sekar
### To Resolve our list of DNS Servers A Record, CNAME, NS, SOA, with Name Server and Name Server category
#The below dnsServer you can add your own DNS server to resolve
$dnsServers = @{
    InternalDNS =@(
    "dev.poc.com",
    "test.poc.com"
    )
    externalDNS =@(
    "google.com",
    "8.8.8.8",
    "4.2.2.2"
  
    )
}

# List of record types to resolve
$recordTypes = @("A", "CNAME") # You can add as per your required DNS Records Type

# Read DNS records from the file
Get-Content -Path E:\dinesh\poc\dns_chk.txt | ForEach-Object {
    $recordName = $_
    $results = @()  # Initialize an array to hold results for each DNS server

    foreach ($category in $dnsServers.Keys) {
        foreach ($server in $dnsServers[$category]) {
            foreach ($type in $recordTypes) {
                try {
                    $result = Resolve-DnsName -Name $recordName -DnsOnly -Server $server -Type $type
                    if ($result) {
                        $results += $result | Select-Object -Property Name, @{Name='Type'; Expression={$type}}, @{Name='RecordData'; Expression={if ($_.IPAddress) { $_.IPAddress } else { $_.NameHost }}}, @{Name='NameServer'; Expression={$server}}, @{Name='Category'; Expression={$category}}
                    }
                } catch {
                    # Handle the error and log it
                    $results += [PSCustomObject]@{
                        Name = $recordName
                        Type = $type
                        RecordData = "N/A"
                        NameServer = $server
                        Category = $category
                        ErrorMessage = $_.Exception.Message
                    }
                }
            }
        }
    }

    # Output results for the current record
    $results | Format-Table -AutoSize
}

Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd')"
Write-Host "Time: $(Get-Date -Format 'HH:mm:ss')" 
