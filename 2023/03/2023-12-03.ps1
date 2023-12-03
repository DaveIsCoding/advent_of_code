<# The engine schematic (your puzzle input) consists of a visual representation of the engine. There are lots of numbers and symbols you don't really understand, but apparently any number adjacent to a symbol, even diagonally, is a "part number" and should be included in your sum. (Periods (.) do not count as a symbol.)

Here is an example engine schematic:

467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..

In this schematic, two numbers are not part numbers because they are not adjacent to a symbol: 114 (top right) and 58 (middle right). Every other number is adjacent to a symbol and so is a part number; their sum is 4361.

Of course, the actual engine schematic is much larger. What is the sum of all of the part numbers in the engine schematic? ?#>

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\03\example_input.txt
$ExampleAnswer = 4361
$PuzzleInput = Get-Content .\2023\03\puzzle_input.txt

function aoc20231203p1 {
    param (
        $Schematic,
        # A list of strings can be natively used like an array anyway.
        # $Schematic[0][0] is line 0, character 0.
        # $Schematic[9][3] is line 9, character 3.
        
        [System.Boolean]$ReturnPartNumbers = $False # Code re-use for part 2.
    )

    # Used to store the potential part numbers, and their start/end coordinates.
    # e.g.
    # 467, 0,0, 0,3
    # 35, 2,2, 2,3
    $PotentialPartNumbers = @()
    $ValidPartNumbers = @()

    # Get the start and end YX (yes, YX) coordinates of each potential part number.
    # Iterate through each line.
    For ($y  = 0; $y -lt $Schematic.Count; $y++) {

        # Iterate through each character.
        For ($x = 0; $x -lt $Schematic[$y].Length; $x++) {

            # Check for digits.
            # Add discovered digits into a string.
            If ($Schematic[$y][$x] -match '\d') { 
                
                # If this is the first digit found, add a new entry to the list of potential part numbers
                # and mark the start coordinates of this number.
                If (!$Digits) { $PotentialPartNumbers += ,@($null,($y,$x),($y,$x)) }
                
                # For subsequent digits, update the ending coordinates.
                Else { $PotentialPartNumbers[-1][2] = @($y,$x) }

                # Add this digit to a string.
                [System.String]$Digits += $Schematic[$y][$x]
            }

            # If it's not a digit, add the string (if any) to the potential list, then clear the string.
            # Mark the ending coordinate on the previous character.
            Else { If ($Digits) {
                    $PotentialPartNumbers[-1][0] = $Digits
                    Remove-Variable Digits}
            }

            # If we have reached the end of the line, the string must end, to prevent rollovers.
            If ($x -eq $Schematic[$y].Length -1) {
                If ($Digits) {
                    $PotentialPartNumbers[-1][0] = $Digits
                    Remove-Variable Digits}
            }
        }

    }

    # For each potential part number, determine the list of adjacent coordinates to test.
    ForEach ($PotentialPartNumber in $PotentialPartNumbers) {

        # Use the range operator to specify a range from the line before to the line after.
        # But we can't go below 0 or past the last line.
        # 35, 2,2, 2,3
        $Yrange = [System.Math]::Max($PotentialPartNumber[1][0]-1,0)..[System.Math]::Min($PotentialPartNumber[2][0]+1,$Schematic.Count-1)

        # Use the range operator to specify a range from the character before to the character after.
        # But we can't go below 0 or past the end of the line.
        # 35, 2,2, 2,3
        $Xrange = [System.Math]::Max($PotentialPartNumber[1][1]-1,0)..[System.Math]::Min($PotentialPartNumber[2][1]+1,$Schematic[$PotentialPartNumber[1][0]].Length-1)

        # Test each adjacent coordinate for a symbol.
        :TestValues ForEach ($yValue in $Yrange) {
            ForEach ($xValue in $Xrange) {
                If ($Schematic[$yValue][$xValue] -notmatch '[\d\.]') {
                    
                    # As soon as we find one, the part number is valid, add it to a list.
                    $ValidPartNumbers += ,@([int32]$PotentialPartNumber[0],$PotentialPartNumber[1],$PotentialPartNumber[2])

                    # And don't bother checking the rest.
                    Break TestValues
                }
            }
        }
    }

    # Add up the valid part numbers.
    # Use ForEach-Object to just get the part number, not the coordinates.
    $Total = ($ValidPartNumbers | ForEach-Object {$_[0]} | Measure-Object -Sum).Sum

    # Return the answer, or the part numbers (for re-use with part 2.)
    If (!$ReturnPartNumbers) {$Total} Else {$ValidPartNumbers}
}

# Test with the example input.
Write-Host "Testing code against example input:"
If (aoc20231203p1 $ExampleInput -eq $ExampleAnswer) {$True} Else {$False}

# Run against the puzzle input.
Write-Host "Running against puzzle input:"
aoc20231203p1 $PuzzleInput

<# --- Part Two ---
The missing part wasn't the only issue - one of the gears in the engine is wrong. A gear is any * symbol that is adjacent to exactly two part numbers. Its gear ratio is the result of multiplying those two numbers together.

This time, you need to find the gear ratio of every gear and add them all up so that the engineer can figure out which gear needs to be replaced.

Consider the same engine schematic again:

467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..

In this schematic, there are two gears. The first is in the top left; it has part numbers 467 and 35, so its gear ratio is 16345. The second gear is in the lower right; its gear ratio is 451490. (The * adjacent to 617 is not a gear because it is only adjacent to one part number.) Adding up all of the gear ratios produces 467835.

What is the sum of all of the gear ratios in your engine schematic? #>

$ExampleAnswer2 = 467835

function aoc20231203p2 {
    param (
        $Schematic,
        # A list of strings can be natively used like an array anyway.
        # $Schematic[0][0] is line 0, character 0.
        # $Schematic[9][3] is line 9, character 3.
        
        $PartNumbers # Built by the p1 function.
    )

    # Used to store the potential gear coordinates.
    # e.g.
    # 2,3
    $PotentialGears = @()
    $PotentialPartNumbers = @()
    $GearRatios = @()

    # Get the YX (yes, YX) coordinates of each potential gear.
    # Iterate through each line.
    For ($y  = 0; $y -lt $Schematic.Count; $y++) {

        # Iterate through each character.
        For ($x = 0; $x -lt $Schematic[$y].Length; $x++) {

            # Check for gears.
            # Make a list of the coordinates of each one.
            If ($Schematic[$y][$x] -eq "*") { 
                
                # Mark the coordinates of this potential gear.
                $PotentialGears += ,@($y,$x)
            }
        }

    }

    # For each potential gear, determine the list of adjacent coordinates to test.
    ForEach ($PotentialGear in $PotentialGears) {

        # Test each gear's coordinates against the part number coordinates.
        ForEach ($PartNumber in $PartNumbers)  {

            # 467, 0,0, 0,3
            If ($PartNumber[1][0] -ge $PotentialGear[0]-1 -and # If it's previous line, or after
                $PartNumber[2][0] -le $PotentialGear[0]+1 -and # and next line, or before
                $PartNumber[2][1] -ge $PotentialGear[1]-1 -and # and the last digit is the previous character, or after
                $PartNumber[1][1] -le $PotentialGear[1]+1 ) {  # and the first digit is the next character, or before

                    # Then add this part number to the list.
                    $PotentialPartNumbers += ,$PartNumber[0]

            }
        }
        
        # If we have found exactly 2 matches, calculate the ratio, and add it to the total.
        If ($PotentialPartNumbers.Count -eq 2) {$GearRatios += ,($PotentialPartNumbers[0] * $PotentialPartNumbers[1]) }

        # Reset ready for the next gear.
        Clear-Variable PotentialPartNumbers
    }

    # Calculate the total of the gear ratios.
    $Total = ($GearRatios | Measure-Object -Sum).Sum

    # Return the answer.
    $Total
}

# Test with the example input.
Write-Host "Testing code against example input:"
If (aoc20231203p2 $ExampleInput (aoc20231203p1 $ExampleInput -ReturnPartNumbers $True) -eq $ExampleAnswer2) {$True} Else {$False}

# Run against the puzzle input.
Write-Host "Running against puzzle input:"
aoc20231203p2 $PuzzleInput (aoc20231203p1 $PuzzleInput -ReturnPartNumbers $True)