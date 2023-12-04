<# #>

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\04\example_input.txt
$ExampleAnswer = 0
$PuzzleInput = Get-Content .\2023\04\puzzle_input.txt

function aoc20231203p1 {
    param (
        $PuzzleInput
    )


    # Return the answer
    $Total
}

# Test with the example input.
Write-Host "Testing code against example input:"
If (aoc20231204p1 $ExampleInput -eq $ExampleAnswer) {$True} Else {$False}

# Run against the puzzle input.
Write-Host "Running against puzzle input:"
aoc20231204p1 $PuzzleInput

<# --- Part Two ---
 #>

$ExampleAnswer2 = 0

function aoc20231203p2 {
    param (
        $PuzzleInput
    )

        # Return the answer.
        $Total
}



# Test with the example input.
Write-Host "Testing code against example input:"
If (aoc20231203p2 $ExampleInput -eq $ExampleAnswer2) {$True} Else {$False}

# Run against the puzzle input.
Write-Host "Running against puzzle input:"
aoc20231204p2 $PuzzleInput