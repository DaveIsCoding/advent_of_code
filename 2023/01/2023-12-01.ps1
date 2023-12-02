<# --- Day 1: Trebuchet?! ---
Something is wrong with global snow production, and you've been selected to take a look. The Elves have even given you a map; on it, they've used stars to mark the top fifty locations that are likely to be having problems.
You've been doing this long enough to know that to restore snow operations, you need to check all fifty stars by December 25th.
Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!
You try to ask why they can't just use a weather machine ("not powerful enough") and where they're even sending you ("the sky") and why your map looks mostly blank ("you sure ask a lot of questions") and hang on did you just say the sky ("of course, where do you think snow comes from") when you realize that the Elves are already loading you into a trebuchet ("please hold still, we need to strap you in").
As they're making the final adjustments, they discover that their calibration document (your puzzle input) has been amended by a very young Elf who was apparently just excited to show off her art skills. Consequently, the Elves are having trouble reading the values on the document.
The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.
For example:
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.
Consider your entire calibration document. What is the sum of all of the calibration values? #>

# Input from the site, they asked not to make automated requests.
$PuzzleInput = Get-Content .\2023\01\puzzle_input.txt

Function 20231201p1($PuzzleInput){

  $Total = 0

  # Split the input into lines.
  $Lines = $PuzzleInput -split '\r?\n'

  # Clean the lines of non-digits.
  $CleanLines = $Lines | ForEach-Object { $_ -replace '[^\d]', '' }

  # Now we only want to keep the first and last digit of each line.
  # All strings in PowerShell are natively an array of characters.
  $Values = $CleanLines | ForEach-Object { $_[0]+$_[-1] }

  # Sum up the numbers, casting them as integers.
  $Values | ForEach-Object { $Total += [int32]$_ }

  $Total
}


# Now let's make it a one-liner.
Function 20231201p1OneLiner($PuzzleInput){
    $Total = 0
    $PuzzleInput -split '\r?\n' | 
      ForEach-Object { $_ -replace '[^\d]', '' } | 
        ForEach-Object { $_[0] + $_[-1] } |
          ForEach-Object { $Total += [int32]$_ }; $Total    
}


# Now let's golf it!
Function 20231201p1Golf1($p){

    # With spaces and newlines for readability, but they're not needed.
    # We'll use smaller variable names.
    $t = 0
    $p -split '\r?\n' |
    %{ $_ -replace '[^\d]','' } |
      %{ $_[0] + $_[-1] } |
        %{ $t += [int32]$_ }; $t
}

Function 20231201p1Golf2($p){

    $t = 0
    $p -split '\r?\n' |
    %{ $_ -replace '[^\d]','' } |
      %{ $_[0] + $_[-1] } |
        # Making PowerShell do math removes the need for the explicit cast from string to int32.  
        %{ $t += 0 + $_ }; $t
}


Function 20231201p1Golf3($p){

    $t = 0
    $p -split '\r?\n' |
      # The replace operator doesn't need the empty string.
      %{ $_ -replace '[^\d]' } |
        %{ $_[0] + $_[-1] } |
          %{ $t += 0 + $_ }; $t
}



Function 20231201p1Golf4($p){

    $t = 0
    $p -split '\r?\n' |
      # \D is smaller than [^\d]]
      %{ $_ -replace '\D' } |
        %{ $_[0] + $_[-1] } |
          %{ $t += 0 + $_ }; $t

}


Function 20231201p1Golf($p){
   
    $t = 0
    # Fully golfed one-liner, 64 characters: 
    $p-split'\r?\n'|%{$_-replace'\D'}|%{$_[0]+$_[-1]}|%{$t+=0+$_};$t
    #---|----|----|----|----|----|----|----|----|----|----|----|----|----|
    #   5   10   15   20   25   30   35   40   45   50   55   60   65   70
}

# Test
If ((20231201p1Golf $PuzzleInput) -eq 54644) { $True } 
Else { $False }


<# --- Part Two ---
Your calculation isn't quite right. It looks like some of the digits are actually spelled out with letters: one, two, three, four, five, six, seven, eight, and nine also count as valid "digits".

Equipped with this new information, you now need to find the real first and last digit on each line. For example:

two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
In this example, the calibration values are 29, 83, 13, 24, 42, 14, and 76. Adding these together produces 281.

What is the sum of all of the calibration values? #>

function 20231201p2 {
    param (
        [System.String[]]$PuzzleInput
    )
    
    $Total = 0

    # Split the input into lines.
    $Lines = $PuzzleInput -split '\r?\n'
   
    # Put a digit into each equivalent word.
    $DigitLines = $Lines | ForEach-Object { $_ -replace "one","o1ne" `
                                               -replace "two","t2wo" `
                                               -replace "three","t3hree" `
                                               -replace "four","f4our" `
                                               -replace "five","f5ive" `
                                               -replace "six","s6ix" `
                                               -replace "seven","s7even" `
                                               -replace "eight","e8ight" `
                                               -replace "nine","n9ine" }
  
    # Now we can safely remove non-digits.
    $CleanLines = $DigitLines | ForEach-Object { $_ -replace '\D', '' }

    # Now we only want to keep the first and last digit of each line.
    # All strings in PowerShell are natively an array of characters.
    $Values = $CleanLines | ForEach-Object { $_[0]+$_[-1] }
  
    # Sum up the numbers, casting them as integers.
    $Values | ForEach-Object { $Total += 0 + [int32]$_ }
  
    $Total

}

#Now let's make it into a one-liner.
function 20231201p2OneLiner {
    param (
        [System.String[]]$PuzzleInput
    )
    
    $Total = 0
    $PuzzleInput -split '\r?\n' `
             -replace "one","o1ne" `
             -replace "two","t2wo" `
             -replace "three","t3hree" `
             -replace "four","f4our" `
             -replace "five","f5ive" `
             -replace "six","s6ix" `
             -replace "seven","s7even" `
             -replace "eight","e8ight" `
             -replace "nine","n9ine" |
    ForEach-Object { $_ -replace '\D', '' } | 
      ForEach-Object { $_[0] + $_[-1] } |
        ForEach-Object { $Total += [int32]$_ }; $Total
}

# Now let's golf it!
function 20231201p2Golf1 {
    param (
        [System.String[]]$p
    )

    $t = 0

    # We don't need to keep the whole words, just the first and last character.
    $p -split '\r?\n' `
             -replace "one","o1e" `
             -replace "two","t2o" `
             -replace "three","t3e" `
             -replace "four","f4r" `
             -replace "five","f5e" `
             -replace "six","s6x" `
             -replace "seven","s7n" `
             -replace "eight","e8t" `
             -replace "nine","n9e" |
    ForEach-Object { $_ -replace '\D' } | 
      ForEach-Object { $_[0] + $_[-1] } |
        ForEach-Object { $t += 0 + $_ }; $t
}



function 20231201p2Golf2 {
    param (
        [System.String[]]$p
    )

    $t = 0

    # We only need to keep letters if they might start/end a number word.
    # e.g. one starts with O, two ends with O.
    # Six ends with X, But no number starts with X.
    $p -split '\r?\n' `
        -replace "one","o1e" `
        -replace "two","t2o" `
        -replace "three","t3e" `
        -replace "four","4" `
        -replace "five","5e" `
        -replace "six","6" `
        -replace "seven","7n" `
        -replace "eight","e8t" `
        -replace "nine","n9e" |
    ForEach-Object { $_ -replace '\D' } | 
      ForEach-Object { $_[0] + $_[-1] } |
        ForEach-Object { $t += 0 + $_ }; $t
}

function 20231201p2Golf3 {
    param (
        [System.String[]]$PuzzleInput
    )

    $Total = 0

    # A hashtable should be more efficient than multiple replace operators.
    $WordDigit = @{"one"="o1e"
                    "two"="t2o"
                    "three"="t3e"
                    "four"="4"
                    "five"="5e"
                    "six"="6"
                    "seven"="7n"
                    "eight"="e8t"
                    "nine"="n9e"}
    $Digits=$PuzzleInput
    ForEach ($Word in $WordDigit.Keys) { $Digits = $Digits -replace "$Word",($WordDigit["$Word"]) }

    $Digits -split '\r?\n' ` |
    ForEach-Object { $_ -replace '\D' } | 
      ForEach-Object { $_[0] + $_[-1] } |
        ForEach-Object { $Total += 0 + $_ }; $Total
}



function 20231201p2Golf4 {
    param (
        [System.String[]]$p
    )
    # Shrink the variable names again.

    $t = 0

    $h = @{"one"="o1e"
            "two"="t2o"
            "three"="t3e"
            "four"="4"
            "five"="5e"
            "six"="6"
            "seven"="7n"
            "eight"="e8t"
            "nine"="n9e"}
    ForEach ($w in $h.Keys) { $p = $p -replace "$w",($h["$w"]) }

    $p -split '\r?\n' ` |
      ForEach-Object { $_ -replace '\D' } | 
        ForEach-Object { $_[0] + $_[-1] } |
          ForEach-Object { $t += 0 + $_ }; $t
}

function 20231201p2Golf5 {
    param (
        [System.String[]]$p
    )
    # Shrink the variable names again, and condense the hashtable to a single line.

    $t = 0

    $h = @{"one"="o1e";"two"="t2o";"three"="t3e";"four"="4";"five"="5e";"six"="6";"seven"="7n";"eight"="e8t";"nine"="n9e"}
    ForEach ($w in $h.Keys) { $p = $p -replace "$w",($h["$w"]) }; $p -split '\r?\n' ` |
      ForEach-Object { $_ -replace '\D' } | 
        ForEach-Object { $_[0] + $_[-1] } |
          ForEach-Object { $t += 0 + $_ }; $t
}

function 20231201p2Golf6 {
    param (
        [System.String[]]$p
    )
    # One-liner.

    $t = 0

    $h=@{"one"="o1e";"two"="t2o";"three"="t3e";"four"="4";"five"="5e";"six"="6";"seven"="7n";"eight"="e8t";"nine"="n9e"};ForEach($w in $h.Keys){$p=$p-replace"$w",($h["$w"])};$p-split'\r?\n'|%{$_-replace'\D'}|%{$_[0]+$_[-1]}|%{$t+=0+$_};$t
}

function 20231201p2Golf {
    param (
        [System.String[]]$p
    )

    $t = 0

    # Fully golfed one-liner, 238 characters: 

    $h=@{"one"="o1e";"two"="t2o";"three"="t3e";"four"="4";"five"="5e";"six"="6";"seven"="7n";"eight"="e8t";"nine"="n9e"};ForEach($w in $h.Keys){$p=$p-replace"$w",($h["$w"])};$p-split'\r?\n'|%{$_-replace'\D'}|%{$_[0]+$_[-1]}|%{$t+=0+$_};$t
    #---|----|----|----|----|----|----|----|----|----|----|----|----|----|
    #   5   10   15   20   25   30   35   40   45   50   55   60   65   70
}

# Test
If ((20231201p2Golf $PuzzleInput) -eq 53348) { $True } 
Else { $False }