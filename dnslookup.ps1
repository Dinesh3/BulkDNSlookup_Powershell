 cls
# Define the DNS server to use
$dnsServer = "ns1.com","ns2.com"
$outputFile = "E:\dinesh\poc\dns_output.txt"

# Initialize an array to hold the results
$results = @()

# Read the DNS names from the file and resolve them
Get-Content -Path E:\dinesh\poc\dns_chk.txt | 
ForEach-Object {
    $result = $null
    try {
        $result = Resolve-DnsName -Name $_ -DnsOnly -Server $dnsServer -Type ANY
    } catch {
        # Handle any errors that occur during resolution
    }

    if ($result) {
        # If resolution is successful, include the NameServer
        $results += $result | Select-Object -Property Name, Type, IPAddress, NAMEHOST, @{Name='NameServer'; Expression={$dnsServer}}
    } 
    else {
        # If resolution fails, create a custom object with the name server
        $results += [PSCustomObject]@{
            Name      = $_
            Type      = "N/A"
            IPAddress = "N/A"
            NAMEHOST  = "N/A"
            NS        = "N/A"
            NameServer = $dnsServer  # Display the name server even if resolution fails
        }
    }
}

# Output results to the console and write to a file
$results | Format-Table -AutoSize
$results | Export-Csv -Path $outputFile -NoTypeInformation -Force

# Output the current date and time
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd')"
Write-Host "Time: $(Get-Date -Format 'HH:mm:ss')" 
