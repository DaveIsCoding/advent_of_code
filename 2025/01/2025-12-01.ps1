$puzzleinput = Get-Content ".\2025\01\2025-12-01_input.txt"
$example = Get-Content ".\2025\01\2025-12-01_example.txt"

# PART 1

# We start at 50
$dial = 50
$answer = 0
# Work through the instructions
ForEach ($instruction in $puzzleinput){

  # A turn to the left is a -
  # A turn to the right is a +
  if($instruction[0] -eq "L") {$move = 0 - [int]$instruction.Substring(1)}
  else{$move = [int]$instruction.Substring(1)}

  $dial = ($dial + $move)

  # If we went under 0, divide the result by 100 and keep the remainder
  # Then add (subtract) that to the dial
  # e.g. 50 - 260 = -210, 100 + -10 = 90 
  If ($dial -le 0) {$dial = 100 + $dial % 100}

  # If we went over 100, divide the result by 100 and keep the remainder
  # e.g. 50 + 260 = 310, == 10
  If ($dial -ge 100) {$dial = $dial % 100}

  # If the final result is 0, add one to the counter
  If ($dial -eq 0) {$answer++}

}

"Answer 1 is $answer"


# PART 2
# Now we need to also count how many times we go past 0
# So when we take the modulus, do we also increment the answer by the dividend?
# We start at 50
$dial = 50
$answer2 = 0
# Work through the instructions
ForEach ($instruction in $example){

  # A turn to the left is a -
  # A turn to the right is a +
  if($instruction[0] -eq "L") {$move = 0 - [int]$instruction.Substring(1)}
  else{$move = [int]$instruction.Substring(1)}

  # Each time we pass 0, increment the answer
  # Start by counting whole turns
  $answer2 += [int]([Math]::Abs($dialposition) / 100)
  
  # Check if the remainder is enough for another 0
  # e.g. -250, from 70, 70 - 50 = 20, no extra click
  # e.g. -250, from 20, 20 - 50 = -30, extra click
  if(($move -gt 0) -and ($dial + ($move % 100) -ge 100)) {$answer2++}
  if(($move -lt 0) -and ($dial - ([Math]::Abs($move) % 100) -le 0)) {$answer2++}
  

  # Now move the dial as per Part 1, ready for the next instruction
  $dial = ($dial + $move)
  If ($dial -le 0) {$dial = 100 + $dial % 100}
  If ($dial -ge 100) {$dial = $dial % 100}

}

"Answer 2 is $answer2"
