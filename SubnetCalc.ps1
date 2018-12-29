$subnetMasks = @{

	255 = 8
    254 = 7
    252 = 6
	248 = 5
	240 = 4
	224 = 3
	192 = 2
	128 = 1
	0 =   0

}
$subnetIncrements = @{
	128 = 128
	192 = 64
	224 = 32
	240 = 16
	248 = 8
	252 = 4
	254 = 2
	255 = 1
}
function getRange{
Param(
$numberOfRanges,
$increment
)
$ranges = [System.Collections.ArrayList]@()
	for($i = 0; $i -lt $numberOfRanges; $i++){
	  
		if($i -gt 0){
		$firstBound =  $increment * $i
		$endBound = $increment * ($i + 1)
		$ranges.add($firstBound..$endBound)
		}
		else{
		$ranges.Add(0..$increment)
		}
		
	}
	return $ranges
}


function getPosition{
    Param(
        $subnetMask
    )
    for($i=0; $i -lt $subNetMask.count; $i++){
        if($subNetMask[$i] -ne 255 -and $subNetMask[$i] -ne 0){
            return $i
        }
		
    }

}

function getIncrement{
	Param(
	$octet
	)
	$keys = $subnetIncrements.keys
	foreach($key in $keys){
	
		if($octet -eq $key){
		$increment = $subnetIncrements.item($key)
		}
	}
	return $increment
	
}

function getSubnetBits{

	Param(
	$octet
	)
		for($i =0; $i-le 8; $i++){
			if(($subnetmasks.GetEnumerator() | Where-Object {$_.value -eq $i} | select -expandproperty name) -eq $octet){
			$numberOfNetworkBits+= $subnetMasks.GetEnumerator() | where-object {$_.Value -eq $i} | select -expandproperty value
			}
		}
		
	return $numberOfNetworkBits
}
function getCurrentRange{
	Param(
	$ranges,
	$IPArray,
	$position
	)
	
	
	foreach($range in $ranges){
		if($range -eq $IPArray[$position]){
		
		$currentRange = $range
		}
		
	}
	return $currentRange
		
}

function makeArray{
	Param(
	$array
	)
	$returnedArray = [System.Collections.ArrayList]@()
	$returnedArray = $array.split(".")
	
	return $returnedArray
}

function buildTable{
	Param(
		$IPArray,
		$subnetArray,
		$networkAddress,
		$broadcastAddress,
		$networkBits,
		$hostBits,
		$numberOfNetworks,
		$hostsPerNetwork,
		$slashNotation
	)
			$row = $table.NewRow()
 			$row.IPAddress = "$IPArray" 
			$row.SubnetMask = "$subnetArray" 
			$row.NetworkAddress = "$networkAddress"
			$row.BroadcastAddress = "$broadcastAddress"
			$row.NetworkBits = "$numberOfNetworkBits"
			$row.HostBits = "$numberOfHostBits"
			$row.NumberOfNetworks = "$numberOfNetworks"
			$row.HostsPerNetwork = "$numberOfHostsPerNetwork"
			$row.SlashNotation = "/$numberOfNetworkBits"
			$table.Rows.Add($row)

			$table | format-List
}

$table = New-Object system.Data.DataTable “$tableName”

#Define Columns
$col1 = New-Object system.Data.DataColumn IPAddress,([string])
$col2 = New-Object system.Data.DataColumn SubnetMask,([string])
$col3 = New-Object system.Data.DataColumn NetworkAddress,([string])
$col4 = New-Object system.Data.DataColumn BroadcastAddress,([string])
$col5 = New-Object system.Data.DataColumn NetworkBits,([string])
$col6 = New-Object system.Data.DataColumn HostBits,([string])
$col7 = New-Object system.Data.DataColumn NumberOfNetworks,([string])
$col8 = New-Object system.Data.DataColumn HostsPerNetwork,([string])
$col9 = New-Object system.Data.DataColumn SlashNotation,([string])

$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)
$table.columns.add($col5)
$table.columns.add($col6)
$table.columns.add($col7)
$table.columns.add($col8)
$table.columns.add($col9)


$IPAddress = "10.128.0.0"
$subnetMask = "255.255.252.0"

$IPArray = makeArray $IPAddress
$subnetArray = makeArray $subnetMask


$networkAddress = makeArray $IPAddress
$broadcastAddress = makeArray $IPAddress

#Gets number of network bits

foreach($octet in $subnetArray){
	$numberOfNetworkBits += getSubnetBits $octet
}
if($numberofNetworkBits % 8 -eq 0){
	if($subnetArray[0] -eq 255 -and $subnetArray[1] -eq 255 -and $subnetArray[2] -eq 255){
	$numberOfHostBits = 8
	$numberOfNetworkBits = 24
	$numberOfNetworks = [math]::pow( 2, $numberOfNetworkBits )
	$numberOfHostsPerNetwork = [math]::pow(2, $numberOfHostBits)  - 2
	$slashNotation = "/24"
	$broadcastAddress[3] = 255
	$networkAddress[3] = 0
	}
	elseif($subnetArray[0] -eq 255 -and $subnetArray[1] -eq 255){
	$numberOfHostBits = 16
	$numberofNetworkBits = 16
	$slashNotation = "/16"
	$numberOfNetworks = [math]::pow( 2, $numberOfNetworkBits )
	$numberOfHostsPerNetwork = [math]::pow(2, $numberOfHostBits)  - 2
	$broadcastAddress[2] = 255
	$broadcastAddress[3] = 255
	$networkAddress[2] = 0
	$networkAddress[3] = 0
	}
	elseif($subnetArray[0] -eq 255){
	$numberOfHostBits = 24
	$numberofNetworkBits = 8
	$slashNotation = "/8"
	$numberOfNetworks = [math]::pow( 2, $numberOfNetworkBits )
	$numberOfHostsPerNetwork = [math]::pow(2, $numberOfHostBits)  - 2
	$broadcastAddress[1] = 255
	$broadcastAddress[2] = 255
	$broadcastAddress[3] = 255

	$networkAddress[1] = 0
	$networkAddress[2] = 0
	$networkAddress[3] = 0
	}
	write-host $broadcastAddress
	write-host $networkAddress
	buildTable $IPArray $subnetArray $networkAddress $broadcastAddress $numberOfNetworkBits $numberOfHostBits $numberOfNetworks $hostsPerNetwork $slashNotation

}

else{
$numberOfHostBits = 32 - $numberOfNetworkBits

#Gets position and increment where the mask is incrementing
$position = getPosition $subnetArray

$increment = getIncrement $subnetArray[$position]
$numberOfRanges = 256 / $increment
$rangesOfSubnets = getRange $numberOfRanges $increment
$currentRange = getCurrentRange $rangesOfSubnets $IPArray $position

for($i=0; $i -lt $currentRange.length; $i++){
	
	$networkBit = $currentRange[0]
	$broadcastBit = $currentRange[-1] -1
	
}
for($i =$position +1; $i -lt $networkAddress.count; $i++){
	$networkAddress[$i] = 0
}
for($i =$position +1; $i -lt $broadcastAddress.count ; $i++){
	$broadcastAddress[$i] = 255
}
  
$networkAddress[$position] = $networkBit
$broadcastAddress[$position] = $broadcastBit

$numberOfNetworks = [math]::pow( 2, $numberOfNetworkBits )
$numberOfHostsPerNetwork = [math]::pow(2, $numberOfHostBits)  - 2

buildTable $IPArray $subnetArray $networkAddress $broadcastAddress $numberOfNetworkBits $numberOfHostBits $numberOfNetworks $hostsPerNetwork $slashNotation


}

read-host
