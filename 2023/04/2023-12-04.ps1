<# As far as the Elf has been able to figure out, you have to figure out which of the numbers you have appear in the list of winning numbers. The first match makes the card worth one point and each match after the first doubles the point value of that card.

For example:

Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
In the above example, card 1 has five winning numbers (41, 48, 83, 86, and 17) and eight numbers you have (83, 86, 6, 31, 17, 9, 48, and 53). Of the numbers you have, four of them (48, 83, 17, and 86) are winning numbers! That means card 1 is worth 8 points (1 for the first match, then doubled three times for each of the three matches after the first).

Card 2 has two winning numbers (32 and 61), so it is worth 2 points.
Card 3 has two winning numbers (1 and 21), so it is worth 2 points.
Card 4 has one winning number (84), so it is worth 1 point.
Card 5 has no winning numbers, so it is worth no points.
Card 6 has no winning numbers, so it is worth no points.
So, in this example, the Elf's pile of scratchcards is worth 13 points.

Take a seat in the large pile of colorful cards. How many points are they worth in total?#>

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\04\example_input.txt
$ExampleAnswer = 13
$PuzzleInput = Get-Content .\2023\04\puzzle_input.txt

function aoc20231204p1 {
    param (
        $Scratchcards
    )

    [int32]$Total = 0

    ForEach ($Card in $Scratchcards) {

        [int32[]]$WinningNumbers = @()
        [int32[]]$GameNumbers = @()

        # Split each scratchcard into an array of winning numbers, and game numbers.
        # Break on the :, then the |, and get the second element,
        # trim, then split on spaces.
        $WinningNumbers = (($Card -split ':')[1].Trim(" ") -split '\|')[0].Trim(" ") -split '[\s]+'

        # Do the same for game numbers.
        $GameNumbers = (($Card -split ':')[1].Trim(" ") -split '\|')[1].Trim(" ") -split '[\s]+'

        # Find the matches.
        $Winners = $GameNumbers | Where-Object { $WinningNumbers -contains $_ }

        # Calculate the score for the card.
        # Matches will be empty if there are none.
        # If there is 1, 2^0 is 1.
        # If there are 2, 2^1 is 2.
        # etc.
        If ($Winners) {$Total += [System.Math]::Pow(2,$Winners.count-1)}
    }
    
    # Return the answer
    $Total
}

# Test with the example input.
Write-Host "Testing p1 code against example input:"
If (aoc20231204p1 $ExampleInput -eq $ExampleAnswer) {$True} Else {$False}

# Run against the puzzle input.
Write-Host "Running p1 against puzzle input:"
aoc20231204p1 $PuzzleInput

<# --- Part Two ---
Specifically, you win copies of the scratchcards below the winning card equal to the number of matches. So, if card 10 were to have 5 matching numbers, you would win one copy each of cards 11, 12, 13, 14, and 15.

Copies of scratchcards are scored like normal scratchcards and have the same card number as the card they copied. So, if you win a copy of card 10 and it has 5 matching numbers, it would then win a copy of the same cards that the original card 10 won: cards 11, 12, 13, 14, and 15. This process repeats until none of the copies cause you to win any more cards. (Cards will never make you copy a card past the end of the table.)

This time, the above example goes differently:

Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

Card 1 has four matching numbers, so you win one copy each of the next four cards: cards 2, 3, 4, and 5.
Your original card 2 has two matching numbers, so you win one copy each of cards 3 and 4.
Your copy of card 2 also wins one copy each of cards 3 and 4.
Your four instances of card 3 (one original and three copies) have two matching numbers, so you win four copies each of cards 4 and 5.
Your eight instances of card 4 (one original and seven copies) have one matching number, so you win eight copies of card 5.
Your fourteen instances of card 5 (one original and thirteen copies) have no matching numbers and win no more cards.
Your one instance of card 6 (one original) has no matching numbers and wins no more cards.
Once all of the originals and copies have been processed, you end up with 1 instance of card 1, 2 instances of card 2, 4 instances of card 3, 8 instances of card 4, 14 instances of card 5, and 1 instance of card 6. In total, this example pile of scratchcards causes you to ultimately have 30 scratchcards!

Process all of the original and copied scratchcards until no more scratchcards are won. Including the original set of scratchcards, how many total scratchcards do you end up with?
 #>

$ExampleAnswer2 = 30

function Measure-Winners {
    param (
        $Scratchcard
    )

    [int32]$Winners = 0

    [int32[]]$WinningNumbers = @()
    [int32[]]$GameNumbers = @()

    # Split each scratchcard into an array of winning numbers, and game numbers.
    # Break on the :, then the |, and get the second element,
    # trim, then split on spaces.
    $WinningNumbers = (($Scratchcard -split ':')[1].Trim(" ") -split '\|')[0].Trim(" ") -split '[\s]+'

    # Do the same for game numbers.
    $GameNumbers = (($Scratchcard -split ':')[1].Trim(" ") -split '\|')[1].Trim(" ") -split '[\s]+'

    # Find the matches and count them.
    $Winners += ($GameNumbers | Where-Object { $WinningNumbers -contains $_ }).Count
    
    # Return the answer
    $Winners
}

function aoc20231204p2 {
    param (
        $Scratchcards,
        [Switch]$Debug = $False,
        [Switch]$Verbose = $False
    )
    
    # Make a list of card IDs.
    $CardIDs = @(1..$ScratchCards.Count)
    $Pile = @()
    # Pile:
    # Card ID, Number of Winners, Number of copies

    # Count how many winners each card has.
    ForEach ($CardID in $CardIDs) {

        [int32]($Winners) = Measure-Winners ($Scratchcards[$CardID-1])
        
        # Start with 1 of each card in the pile.
        # Pile:
        # Card ID, Number of Winners, Number of copies
        # Assume 1 copy to start.
        $Pile += ,([int32]($CardID),[int32]($Winners),1)

    }

    # Process the pile of cards.
    ForEach ($Card in $Pile) {

        # For this card, see how many winners there are, 
        # see how many copies there are,
        # and increment the counts of subsequent cards.
        $CardID = $Card[0]
        $Winners = $Card[1]
        $Copies = $Card[2]

        If ($Winners -gt 0) {

            For ($i=$CardID; $i -le $CardID+$Winners-1; $i++) {

                # Increase the number of copies of subsequent cards,
                # by the number of copies of THIS card.
                $Pile[$i][2] += $Copies
            }
        }
    }

    # Return the number of cards on the Done Pile.
    ($Pile | ForEach-Object { $_[2] } | Measure-Object -Sum).Sum
}


# Test with the example input.
Write-Host "Testing p2 code against example input:"
If (aoc20231204p2 -Scratchcards $ExampleInput -eq $ExampleAnswer2) {$True} Else {$False}


# Run against the puzzle input.
Write-Host "Running p2 against puzzle input:"
aoc20231204p2 -Scratchcards $PuzzleInput