<# #>

$Day="00"

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\$Day\example_input.txt
$PuzzleInput = Get-Content .\2023\$Day\puzzle_input.txt

$ExampleAnswer = 0

function aoc20231200p1 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )


    # Return the answer
    $Total
}

# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231200p1 $ExampleInput -Debug) -eq $ExampleAnswer) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231200p1 $PuzzleInput
}
Else {$False}

<# --- Part Two ---
 #>

$ExampleAnswer2 = 0

function aoc20231200p2 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

        # Return the answer.
        $Total
}



# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231200p2 $ExampleInput -Debug) -eq $ExampleAnswer2) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231200p2 $PuzzleInput
}
Else {$False}