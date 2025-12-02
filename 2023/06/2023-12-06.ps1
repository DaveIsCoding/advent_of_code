<# For example:

Time:      7  15   30
Distance:  9  40  200
This document describes three races:

The first race lasts 7 milliseconds. The record distance in this race is 9 millimeters.
The second race lasts 15 milliseconds. The record distance in this race is 40 millimeters.
The third race lasts 30 milliseconds. The record distance in this race is 200 millimeters.
Your toy boat has a starting speed of zero millimeters per millisecond. For each whole millisecond you spend at the beginning of the race holding down the button, the boat's speed increases by one millimeter per millisecond.

So, because the first race lasts 7 milliseconds, you only have a few options:

Don't hold the button at all (that is, hold it for 0 milliseconds) at the start of the race. The boat won't move; it will have traveled 0 millimeters by the end of the race.
Hold the button for 1 millisecond at the start of the race. Then, the boat will travel at a speed of 1 millimeter per millisecond for 6 milliseconds, reaching a total distance traveled of 6 millimeters.
Hold the button for 2 milliseconds, giving the boat a speed of 2 millimeters per millisecond. It will then get 5 milliseconds to move, reaching a total distance of 10 millimeters.
Hold the button for 3 milliseconds. After its remaining 4 milliseconds of travel time, the boat will have gone 12 millimeters.
Hold the button for 4 milliseconds. After its remaining 3 milliseconds of travel time, the boat will have gone 12 millimeters.
Hold the button for 5 milliseconds, causing the boat to travel a total of 10 millimeters.
Hold the button for 6 milliseconds, causing the boat to travel a total of 6 millimeters.
Hold the button for 7 milliseconds. That's the entire duration of the race. You never let go of the button. The boat can't move until you let go of the button. Please make sure you let go of the button so the boat gets to move. 0 millimeters.
Since the current record for this race is 9 millimeters, there are actually 4 different ways you could win: you could hold the button for 2, 3, 4, or 5 milliseconds at the start of the race.

In the second race, you could hold the button for at least 4 milliseconds and at most 11 milliseconds and beat the record, a total of 8 different ways to win.

In the third race, you could hold the button for at least 11 milliseconds and no more than 19 milliseconds and still beat the record, a total of 9 ways you could win.

To see how much margin of error you have, determine the number of ways you can beat the record in each race; in this example, if you multiply these values together, you get 288 (4 * 8 * 9).

Determine the number of ways you could beat the record in each race. What do you get if you multiply these numbers together? #>

$Day="06"

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\$Day\example_input.txt
$PuzzleInput = Get-Content .\2023\$Day\puzzle_input.txt

$ExampleAnswer = 288

function aoc20231206p1 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    <# 
    e.g. Race record is 10 seconds, distance 10 mm
    if we wait 1 seconds, we will move at 1mm/s for 9s, cover 9mm == LOSE
    if we wait 2 seconds, we will move at 2mm/s for 8s, cover 16mm == WIN

    once we are going "fast enough", any faster speed will also win,
    but we must allow at least 1 second to actually move in.

    The smallest possible charge time is 1 seconds.
    This will win if record distance < (record time -1)
    This will lose if (record distance) >= (record time -1)

    To win a race of rT seconds and rD distance,
    you must move at at least (floor ( rd /rt ) ) + 1 mm/s,
    and therefore charge for at least (floor ( rd /rt ) ) + seconds,
    
    and at most rT - ( ceiling(rD/rT) + 1 ) seconds
    
    This gives ( rT - ( ceiling(rD/rT) + 1 ) ) - (floor (rd/rt)) possible ways to win.
    #>

    function Get-MinChargeTime {
        param (
            [int64]$recordTime,
            [int64]$targetDistance
        )
        # "Use some symmetrical properties of the equations to further simplify..." is apparently what we did here. And by "we", I mean Andrés.
        $MinChargeTime = [int64]([System.Math]::Ceiling( ( ( -1 * $recordTime ) + ( [System.Math]::Pow(( ( [System.Math]::Pow($recordTime,2) ) - (4*$targetDistance) ),0.5) ) ) / -2 ) )

        $MinChargeTime
    }

    function Get-MaxChargeTime {
        param (
            [int64]$recordTime,
            [int64]$targetDistance
        )
        # "Use some symmetrical properties of the equations to further simplify..." is apparently what we did here. And by "we", I mean Andrés.
        $MaxChargeTime = [int64]([System.Math]::Floor( ( ( -1 * $recordTime ) - ( [System.Math]::Pow(( ( [System.Math]::Pow($recordTime,2) ) - (4*$targetDistance) ),0.5) ) ) / -2 ) )

        $MaxChargeTime
    }

    $Time = [int64[]](($PuzzleInput[0] -replace '[^\d\s]').Trim(" ") -split '\s+')
    $Distance = [int64[]](($PuzzleInput[1] -replace '[^\d\s]').Trim(" ") -split '\s+')

    For ($i=0; $i -lt $Time.Count; $i++) {
        
        # We have to BEAT the distance, not match it, so increase Distance by 1.
        $WaysToWin = ( ( Get-MaxChargeTime $Time[$i] ($Distance[$i]+1) ) - ( Get-MinChargeTime $Time[$i] ($Distance[$i]+1) ) ) + 1
        
        If (!$Total) {$Total = $WaysToWin}
        Else {$Total *= $WaysToWin}
    }

    # Return the answer
    $Total
}

# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231206p1 $ExampleInput -Debug) -eq $ExampleAnswer) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231206p1 $PuzzleInput
}
Else {$False}

<# --- Part Two ---
As the race is about to start, you realize the piece of paper with race times and record distances you got earlier actually just has very bad kerning. There's really only one race - ignore the spaces between the numbers on each line.

So, the example from before:

Time:      7  15   30
Distance:  9  40  200
...now instead means this:

Time:      71530
Distance:  940200
Now, you have to figure out how many ways there are to win this single race. In this example, the race lasts for 71530 milliseconds and the record distance you need to beat is 940200 millimeters. You could hold the button anywhere from 14 to 71516 milliseconds and beat the record, a total of 71503 ways!

How many ways can you beat the record in this one much longer race?
 #>

$ExampleAnswer2 = 71503

function aoc20231206p2 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    function Get-MinChargeTime {
        param (
            [int64]$recordTime,
            [int64]$targetDistance
        )
        $MinChargeTime = [int64]([System.Math]::Ceiling( ( ( -1 * $recordTime ) + ( [System.Math]::Pow(( ( [System.Math]::Pow($recordTime,2) ) - (4*$targetDistance) ),0.5) ) ) / -2 ) )

        $MinChargeTime
    }

    function Get-MaxChargeTime {
        param (
            [int64]$recordTime,
            [int64]$targetDistance
        )
        $MaxChargeTime = [int64]([System.Math]::Floor( ( ( -1 * $recordTime ) - ( [System.Math]::Pow(( ( [System.Math]::Pow($recordTime,2) ) - (4*$targetDistance) ),0.5) ) ) / -2 ) )

        $MaxChargeTime
    }

    $Time = [int64]($PuzzleInput[0] -replace '[\D]')
    $Distance = [int64]($PuzzleInput[1] -replace '[\D]')

    $WaysToWin = ( ( Get-MaxChargeTime $Time ($Distance+1) ) - ( Get-MinChargeTime $Time ($Distance+1) ) ) + 1
    
    # Return the answer.
    $WaysToWin
}



# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231206p2 $ExampleInput -Debug) -eq $ExampleAnswer2) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231206p2 $PuzzleInput
}
Else {$False}