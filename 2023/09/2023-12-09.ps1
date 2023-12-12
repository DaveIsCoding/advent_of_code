<# 0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
To best protect the oasis, your environmental report should include a prediction of the next value in each history. To do this, start by making a new sequence from the difference at each step of your history. If that sequence is not all zeroes, repeat this process, using the sequence you just generated as the input sequence. Once all of the values in your latest sequence are zeroes, you can extrapolate what the next value of the original history should be.

In the above dataset, the first history is 0 3 6 9 12 15. Because the values increase by 3 each step, the first sequence of differences that you generate will be 3 3 3 3 3. Note that this sequence has one fewer value than the input sequence because at each step it considers two numbers from the input. Since these values aren't all zero, repeat the process: the values differ by 0 at each step, so the next sequence is 0 0 0 0. This means you have enough information to extrapolate the history! Visually, these sequences can be arranged like this:

0   3   6   9  12  15
  3   3   3   3   3
    0   0   0   0
To extrapolate, start by adding a new zero to the end of your list of zeroes; because the zeroes represent differences between the two values above them, this also means there is now a placeholder in every sequence above it:

0   3   6   9  12  15   B
  3   3   3   3   3   A
    0   0   0   0   0
You can then start filling in placeholders from the bottom up. A needs to be the result of increasing 3 (the value to its left) by 0 (the value below it); this means A must be 3:

0   3   6   9  12  15   B
  3   3   3   3   3   3
    0   0   0   0   0
Finally, you can fill in B, which needs to be the result of increasing 15 (the value to its left) by 3 (the value below it), or 18:

0   3   6   9  12  15  18
  3   3   3   3   3   3
    0   0   0   0   0
So, the next value of the first history is 18.

Finding all-zero differences for the second history requires an additional sequence:

1   3   6  10  15  21
  2   3   4   5   6
    1   1   1   1
      0   0   0
Then, following the same process as before, work out the next value in each sequence from the bottom up:

1   3   6  10  15  21  28
  2   3   4   5   6   7
    1   1   1   1   1
      0   0   0   0
So, the next value of the second history is 28.

The third history requires even more sequences, but its next value can be found the same way:

10  13  16  21  30  45  68
   3   3   5   9  15  23
     0   2   4   6   8
       2   2   2   2
         0   0   0
So, the next value of the third history is 68.

If you find the next value for each history in this example and add them together, you get 114.

Analyze your OASIS report and extrapolate the next value for each history. What is the sum of these extrapolated values?#>

$Day="09"

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\$Day\example_input.txt
$PuzzleInput = Get-Content .\2023\$Day\puzzle_input.txt

$ExampleAnswer = 114

function aoc20231209p1 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    function Get-DeltaSequence {
        param(
            [int64[]]$Sequence
        )
        For ($i=1; $i -lt $Sequence.Count; $i++) {
            $Sequence[$i]-$Sequence[$i-1]
        }
    }

    ForEach ($Line in $PuzzleInput) {

        [int64[]]$Sequence = [int64[]]($Line -split '\s+')

        # Build an array starting with sequence.
        # Add the Delta Sequence to the next row.
        [int64[]]$DeltaSequence = Get-DeltaSequence $Sequence
        $Triangle = @($Sequence,($DeltaSequence))

        While ($Triangle[-1] | Where-Object {$_ -ne 0}) {

            $DeltaSequence = Get-DeltaSequence $DeltaSequence

            $Triangle += ,$DeltaSequence

        }

        # Once we reached a sequence of all 0s, 
        # add the next value to each row,
        # starting at the bottom.
        For ($i = ($Triangle.count - 1); $i -gt 0; $i--) {

            $Triangle[$i-1] += ,($Triangle[$i][-1] + $Triangle[$i-1][-1])
        }

        $NextValue = $Triangle[0][-1]
        
        $Total += $NextValue
    }

    
    # Return the answer
    $Total
}

# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231209p1 $ExampleInput -Debug) -eq $ExampleAnswer) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231209p1 $PuzzleInput
}
Else {$False}

<# --- Part Two ---
For each history, repeat the process of finding differences until the sequence of differences is entirely zero. Then, rather than adding a zero to the end and filling in the next values of each previous sequence, you should instead add a zero to the beginning of your sequence of zeroes, then fill in new first values for each previous sequence.

In particular, here is what the third example history looks like when extrapolating back in time:

5  10  13  16  21  30  45
  5   3   3   5   9  15
   -2   0   2   4   6
      2   2   2   2
        0   0   0
Adding the new values on the left side of each sequence from bottom to top eventually reveals the new left-most history value: 5.

Doing this for the remaining example data above results in previous values of -3 for the first history and 0 for the second history. Adding all three new values together produces 2.

Analyze your OASIS report again, this time extrapolating the previous value for each history. What is the sum of these extrapolated values?
 #>

$ExampleAnswer2 = 2

function aoc20231209p2 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    function Get-DeltaSequence {
        param(
            [int64[]]$Sequence
        )
        For ($i=1; $i -lt $Sequence.Count; $i++) {
            $Sequence[$i]-$Sequence[$i-1]
        }
    }

    ForEach ($Line in $PuzzleInput) {

        [int64[]]$Sequence = [int64[]]($Line -split '\s+')

        # Build an array starting with sequence.
        # Add the Delta Sequence to the next row.
        [int64[]]$DeltaSequence = Get-DeltaSequence $Sequence
        $Triangle = @($Sequence,($DeltaSequence))

        While ($Triangle[-1] | Where-Object {$_ -ne 0}) {

            $DeltaSequence = Get-DeltaSequence $DeltaSequence

            $Triangle += ,$DeltaSequence

        }

        # Once we reached a sequence of all 0s, 
        # add the previous value to each row,
        # starting at the bottom.
        
        # The last row MUST have 0.
        $Triangle[-1] = @(0) + $Triangle[-1]

        # The penultimate row MUST have the same value as the current first one.
        $Triangle[-2] = @($Triangle[-2][0])+$Triangle[-2]
        
        For ($i = ($Triangle.count - 2); $i -ge 0; $i--) {

            # For remaining rows, it's first value - next row, first  value
            $Triangle[$i] = @(($Triangle[$i][0] - $Triangle[$i+1][0])) + $Triangle[$i]
        }

        $FirstValue = $Triangle[0][0]
        
        $Total += $FirstValue
    }

    
    # Return the answer
    $Total
}



# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231209p2 $ExampleInput -Debug) -eq $ExampleAnswer2) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231209p2 $PuzzleInput
}
Else {$False}