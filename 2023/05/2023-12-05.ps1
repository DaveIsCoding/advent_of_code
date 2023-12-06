<# The gardener and his team want to get started as soon as possible, so they'd like to know the closest location that needs a seed. Using these maps, find the lowest location number that corresponds to any of the initial seeds. To do this, you'll need to convert each seed number through other categories until you can find its corresponding location number. In this example, the corresponding types are:

Seed 79, soil 81, fertilizer 81, water 81, light 74, temperature 78, humidity 78, location 82.
Seed 14, soil 14, fertilizer 53, water 49, light 42, temperature 42, humidity 43, location 43.
Seed 55, soil 57, fertilizer 57, water 53, light 46, temperature 82, humidity 82, location 86.
Seed 13, soil 13, fertilizer 52, water 41, light 34, temperature 34, humidity 35, location 35.
So, the lowest location number in this example is 35.

What is the lowest location number that corresponds to any of the initial seed numbers? #>

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\05\example_input.txt
$ExampleAnswer = 35
$PuzzleInput = Get-Content .\2023\05\puzzle_input.txt

function aoc20231205p1 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    [int64[]]$Seeds = @()  # Seed list.
    [hashtable]$Maps = @{} # foo-to-bar = @{1=2,4=9...etc.}
    [hashtable]$ValueMap = @{} # 1=2,4=9...etc.

    # Build hashtables from the input.
    $PuzzleInput | ForEach-Object {
        
        $Line = $_

        # If the line contains seeds:, it's a seed list.
        If ($Line -match '^seeds:') {
            $Seeds = [int64[]](($Line -split ':')[1].Trim(" ") -split '\s+')
        }
        
        # If the line contains a :, it's the start of a new Map.
        # Maps:
        # foo-to-bar = @{1=2,4=9...etc.}
        ElseIf ($Line -match '.*:.*') { 
            
            $MapName =$Line -replace ' map:'
            $ValueMaps = @()

            $Maps+=@{ "$MapName"=$ValueMaps }
        }
        
        # If the line contains digits, it's a Value Map.
        ElseIf ($Line -match "\d") {
            
            $ValueMap = @{}

            # Get the upper and lower bounds of the Value Map.
            [int64]$SourceStart = [int64](($Line -split "\s+")[1])
            [int64]$DestinationStart = [int64](($Line -split "\s+")[0])
            [int64]$Length = [int64](($Line -split "\s+")[2])

            $ValueMap.SourceStart = $SourceStart
            $ValueMap.DestinationStart = $DestinationStart
            $ValueMap.Offset = $DestinationStart - $SourceStart
            $ValueMap.Length = $Length

            # Put the finished Value Map into the Map hashtable.
            $Maps.$MapName += ,($ValueMap)
        }
    }

    # Build the chain for each seed.
    $Chains = @()
    
    ForEach ($Seed in $Seeds) {

        $Soil = Map-Object $Maps $Seed "seed" "soil"
        $Fertilizer = Map-Object $Maps $Soil "soil" "fertilizer"
        $Water = Map-Object $Maps $Fertilizer "fertilizer" "water"
        $Light = Map-Object $Maps $Water "water" "light"
        $Temperature = Map-Object $Maps $Light "light" "temperature"
        $Humidity = Map-Object $Maps $Temperature "temperature" "humidity"
        $Location = Map-Object $Maps $Humidity "humidity" "location"
        
        $Chains += ,($Seed,$Soil,$Fertilizer,$Water,$Light,$Temperature,$Humidity,$Location)
    }

    # Which has the lowest location?
    ($Chains | ForEach-Object { $_[7] } | Measure-Object -Minimum).Minimum

}

function Map-Object {
    param (
        [hashtable]$Maps,    
        [int64]$Source,
        [string]$SourceType,
        [string]$DestinationType
    )

    # Check if the value is mapped, otherwise return the source.
    ForEach ($ValueMap in $Maps["$SourceType-to-$DestinationType"]) {

        # Check if the source is in the mapped range.
        If ( $ValueMap.SourceStart -le $Source -and 
             $Source -le $ValueMap.SourceStart + $ValueMap.Length -1 ) {

            $Destination = $Source + $ValueMap.Offset
        }

    }
    
    # If no match was found, return the source.
    If ($Destination) {$Destination} Else {$Source}
}

# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231205p1 $ExampleInput -Debug) -eq $ExampleAnswer) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231205p1 $PuzzleInput
}
Else {$False}


<# --- Part Two ---
 Everyone will starve if you only plant such a small number of seeds. Re-reading the almanac, it looks like the seeds: line actually describes ranges of seed numbers.

The values on the initial seeds: line come in pairs. Within each pair, the first value is the start of the range and the second value is the length of the range. So, in the first line of the example above:

seeds: 79 14 55 13
This line describes two ranges of seed numbers to be planted in the garden. The first range starts with seed number 79 and contains 14 values: 79, 80, ..., 91, 92. The second range starts with seed number 55 and contains 13 values: 55, 56, ..., 66, 67.

Now, rather than considering four seed numbers, you need to consider a total of 27 seed numbers.

In the above example, the lowest location number can be obtained from seed number 82, which corresponds to soil 84, fertilizer 84, water 84, light 77, temperature 45, humidity 46, and location 46. So, the lowest location number is 46.

Consider all of the initial seed numbers listed in the ranges on the first line of the almanac. What is the lowest location number that corresponds to any of the initial seed numbers? #>

$ExampleAnswer2 = 46

function aoc20231205p2 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    [int64[]]$Seeds = @()  # Seed list.
    $SeedMaps = @() # @{Start=79,Length=2}, @{Start=101,Length=32}
    [hashtable]$Maps = @{} # foo-to-bar = @{1=2,4=9...etc.}
    [hashtable]$ValueMap = @{} # 1=2,4=9...etc.
    

    # Build hashtables from the input.
    $PuzzleInput | ForEach-Object {
        
        $Line = $_

        # If the line contains seeds:, it's a seed list.
        # We need to split the seed line into pairs.
        If ($Line -match '^seeds:') {
            $Seeds = [int64[]](($Line -split ':')[1].Trim(" ") -split '\s+')

            $SeedMap = @{}
            $Seeds | ForEach-Object {
                
                If (!$SeedMap.Start) {$SeedMap.Start = $_}
                Else {
                    $SeedMap.Length = $_
                    $SeedMap.End = $SeedMap.Start + $SeedMap.Length -1
                    $SeedMaps += ,($SeedMap)
                    [hashtable]$SeedMap = @{}
                }
            }
        }
        
        # If the line contains a :, it's the start of a new Map.
        # Maps:
        # foo-to-bar = @{1=2,4=9...etc.}
        ElseIf ($Line -match '.*:.*') { 
            
            $MapName =$Line -replace ' map:'
            $ValueMaps = @()

            $Maps+=@{ "$MapName"=$ValueMaps }
        }
        
        # If the line contains digits, it's a Value Map.
        ElseIf ($Line -match "\d") {
            
            $ValueMap = @{}

            # Get the upper and lower bounds of the Value Map.
            [int64]$SourceStart = [int64](($Line -split "\s+")[1])
            [int64]$DestinationStart = [int64](($Line -split "\s+")[0])
            [int64]$Length = [int64](($Line -split "\s+")[2])

            $ValueMap.SourceStart = $SourceStart
            $ValueMap.DestinationStart = $DestinationStart
            $ValueMap.Offset = $DestinationStart - $SourceStart
            $ValueMap.Length = $Length
            $ValueMap.SourceEnd = $SourceStart + $Length -1
            $ValueMap.DestinationEnd = $DestinationStart + $Length -1

            # Put the finished Value Map into the Map hashtable.
            $Maps.$MapName += ,($ValueMap)
        }
    }

    # DISCLAIMER: I needed this video to help me figure this out.
    # https://i.imgur.com/pjVQRdE.mp4

    # Parse the seed-to=soil maps.
    # Anywhere that the Seed Map ranges  overlap with the seed-to-soil maps,
    # those ranges must be chopped off and moved to their new positions.
    # The rest of the Seed Maps remain unchanged.
    $Soil = Map-Ranges "seed" "soil" $SeedMaps $Maps["seed-to-soil"]
    $Fertilizer = Map-Ranges "soil" "fertilizer" $Soil $Maps["soil-to-fertilizer"]
    $Water = Map-Ranges "fertilzer" "water" $Fertilizer $Maps["fertilizer-to-water"]
    $Light = Map-Ranges "water" "light" $Water $Maps["water-to-light"]
    $Temperature = Map-Ranges "light" "temperature" $Light $Maps["light-to-temperature"]
    $Humidity = Map-Ranges "temperature" "humidity" $Temperature $Maps["temperature-to-humidity"]
    $Location = Map-Ranges "humidity" "location" $Humidity $Maps["humidity-to-location"]

    If (!$Lowest) {$Lowest = ($Location.Start | Sort-Object | Measure-Object -Minimum).Minimum }
    ElseIf ($Location -lt $Lowest) {$Lowest = $Location}

    $Lowest
}

function Get-SeedLocation {
    param (
        $Seed,
        $Maps
    )

    $Soil = Map-Object $Maps $Seed "seed" "soil"
    $Fertilizer = Map-Object $Maps $Soil "soil" "fertilizer"
    $Water = Map-Object $Maps $Fertilizer "fertilizer" "water"
    $Light = Map-Object $Maps $Water "water" "light"
    $Temperature = Map-Object $Maps $Light "light" "temperature"
    $Humidity = Map-Object $Maps $Temperature "temperature" "humidity"
    $Location = Map-Object $Maps $Humidity "humidity" "location"

    $Location

}

function Get-Overlap {
    param (
        $SourceRangeStart,
        $SourceRangeEnd,
        $DestinationRangeStart,
        $DestinationRangeEnd
    )

    # Evaluates to $True if there is an overlap.
    If ( $SourceRangeStart -le $DestinationRangeEnd -and 
         $SourceRangeEnd -ge $DestinationRangeStart ) {

        [System.Math]::Max($DestinationRangeStart,$SourceRangeStart),[System.Math]::Min($SourceRangeEnd,$DestinationRangeEnd)

    }
}

function Map-Ranges {
    param (
        $FromType,
        $ToType,
        $FromMaps,
        $ToMaps
    )   
    
    $OutMaps = @()

    ForEach ($ToMap in $ToMaps) {
        
        ForEach ($FromMap in $FromMaps) {
            
            $Overlap = Get-Overlap $FromMap.Start $FromMap.End $ToMap.SourceStart $ToMap.SourceEnd

            # If the ToMap overlaps with the FromMap, move the overlap.
            If ($Overlap) {
                
                # Slice out the overlap range and move it.
                # This range must not be processed by further ToMaps.
                $OutMaps += ,@{"Start" =  $Overlap[0] + $ToMap.Offset
                               "End" =    $Overlap[1] + $ToMap.Offset
                               "Length" = $Overlap[1] - $Overlap[0]}

                
                # Upate the remainder of the FromMap in place,
                # so that subsequent ToMaps can move them.

                # Make a new map for the left side, if necessary.
                If ($FromMap.Start -lt $Overlap[0]) {
                    $FromMaps += ,@{"Start" =  $FromMap.Start
                                    "End" =    $Overlap[0] -1
                                    "Length" = $Overlap[0] - $FromMap.Start}
                }

                # Make a new map for the right side, if necessary.
                # Update the FromMap, to prevent double-slicing.
                If ($FromMap.End -gt $Overlap[1]) {
                    $FromMaps += ,@{"Start" =  $Overlap[1] + 1
                                    "End" =    $FromMap.End
                                    "Length" = $FromMap.End - $Overlap[1]}
                }

                # Clear the properties of the original FromMap.
                # This will prevent any further overlaps.
                $FromMap.Start = 0
                $FromMap.End = 0
                $FromMap.Length = 0
            }
        }
        # Clean out any zeroed FromMaps.
        $FromMaps = $FromMaps | Where-Object {$_.Length -gt 0}
    }

    # Return the (possibly modified) FromMaps, and new Maps.
    $OutMaps += $FromMaps
    $OutMaps
}

# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231205p2 $ExampleInput -Debug) -eq $ExampleAnswer2) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231205p2 $PuzzleInput -Debug
}
Else {$False}
