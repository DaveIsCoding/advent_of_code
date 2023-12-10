<# In Camel Cards, you get a list of hands, and your goal is to order them based on the strength of each hand. A hand consists of five cards labeled one of A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2. The relative strength of each card follows this order, where A is the highest and 2 is the lowest.

Every hand is exactly one type. From strongest to weakest, they are:

Five of a kind, where all five cards have the same label: AAAAA
Four of a kind, where four cards have the same label and one card has a different label: AA8AA
Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
High card, where all cards' labels are distinct: 23456
Hands are primarily ordered based on type; for example, every full house is stronger than any three of a kind.

If two hands have the same type, a second ordering rule takes effect. Start by comparing the first card in each hand. If these cards are different, the hand with the stronger first card is considered stronger. If the first card in each hand have the same label, however, then move on to considering the second card in each hand. If they differ, the hand with the higher second card wins; otherwise, continue with the third card in each hand, then the fourth, then the fifth.

So, 33332 and 2AAAA are both four of a kind hands, but 33332 is stronger because its first card is stronger. Similarly, 77888 and 77788 are both a full house, but 77888 is stronger because its third card is stronger (and both hands have the same first and second card).

To play Camel Cards, you are given a list of hands and their corresponding bid (your puzzle input). For example:

32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483

This example shows five hands; each hand is followed by its bid amount. Each hand wins an amount equal to its bid multiplied by its rank, where the weakest hand gets rank 1, the second-weakest hand gets rank 2, and so on up to the strongest hand. Because there are five hands in this example, the strongest hand will have rank 5 and its bid will be multiplied by 5.

So, the first step is to put the hands in order of strength:

32T3K is the only one pair and the other hands are all a stronger type, so it gets rank 1.
KK677 and KTJJT are both two pair. Their first cards both have the same label, but the second card of KK677 is stronger (K vs T), so KTJJT gets rank 2 and KK677 gets rank 3.
T55J5 and QQQJA are both three of a kind. QQQJA has a stronger first card, so it gets rank 5 and T55J5 gets rank 4.

Now, you can determine the total winnings of this set of hands by adding up the result of multiplying each hand's bid with its rank (765 * 1 + 220 * 2 + 28 * 3 + 684 * 4 + 483 * 5). So the total winnings in this example are 6440.

Find the rank of every hand in your set. What are the total winnings? #>

$Day="07"

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\$Day\example_input.txt
$PuzzleInput = Get-Content .\2023\$Day\puzzle_input.txt

$ExampleAnswer = 6440

function aoc20231207p1 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    function Measure-Hand {
        param (
            [string[]]$Cards,
            [string]$Hand
        )

        $Count = @{}

        ForEach ($Card in $Cards) {

            $Count.$Card = ($Hand -replace "[^$Card]").Length
        }
        
        # Determine the hand type based on counts of cards.
        If ( ($Count.Values | Measure-Object -Maximum).Maximum -eq 5 ) {"5oaK"}
        ElseIf ( ($Count.Values | Measure-Object -Maximum).Maximum -eq 4 ) {"4oaK"}
        ElseIf ( $Count.Values -contains 3 -and $Count.Values -contains 2 ) {"FH"}
        ElseIf ( $Count.Values -contains 3 ) {"3oaK"}
        ElseIf ( ($Count.Values | Where-Object { $_ -eq 2 } | Measure-Object).Count -eq 2 ) {"2Pair"}
        ElseIf ( $Count.Values -contains 2 ) {"1Pair"}
        Else {"HC"}

    }

    $CardRank = "A","K","Q","J","T","9","8","7","6","5","4","3","2"

    $HandRank = "5oaK","4oaK","FH","3oaK","2Pair","1Pair","HC"

    # Parse the input into Hands and Bids.
    $Cards = $PuzzleInput | ForEach-Object { ($_ -split '\s+')[0] }
    $Bids = $PuzzleInput | ForEach-Object { ($_ -split '\s+')[1] }
    
    # Build an array for the results.
    $Hands = @()

    # Parse each Hand into a hashtable.
    For ($i=0; $i -lt $Cards.Count; $i++) {

        $Hands += ,@{"Hand"=$Cards[$i]
                     "Bid"=$Bids[$i]}
        
        # Determine the primary rank of each hand.
        $Hands[-1].PrimaryRank = $HandRank.IndexOf( (Measure-Hand $CardRank $Cards[$i]))
    }
    

    # Sort the hands into order and calculate the winnings.
    $i = $Hands.Count
    ForEach ( $Hand in ($Hands | Sort-Object {$_.PrimaryRank},{$CardRank.IndexOf($_.Hand[0].ToString())},
                                                              {$CardRank.IndexOf($_.Hand[1].ToString())},
                                                              {$CardRank.IndexOf($_.Hand[2].ToString())},
                                                              {$CardRank.IndexOf($_.Hand[3].ToString())},
                                                              {$CardRank.IndexOf($_.Hand[4].ToString())}) ) {

        [int64]$Hand.OverallRank = $i--

        [int64]$Hand.Winnings = [int64]$Hand.Bid * [int64]$Hand.OverallRank
    }

    $Total = ($Hands.Winnings | Measure-Object -Sum).Sum

    # Return the answer
    $Total
}

# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231207p1 $ExampleInput -Debug) -eq $ExampleAnswer) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231207p1 $PuzzleInput
}
Else {$False}

<# --- Part Two ---
To make things a little more interesting, the Elf introduces one additional rule. Now, J cards are jokers - wildcards that can act like whatever card would make the hand the strongest type possible.

To balance this, J cards are now the weakest individual cards, weaker even than 2. The other cards stay in the same order: A, K, Q, T, 9, 8, 7, 6, 5, 4, 3, 2, J.

J cards can pretend to be whatever card is best for the purpose of determining hand type; for example, QJJQ2 is now considered four of a kind. However, for the purpose of breaking ties between two hands of the same type, J is always treated as J, not the card it's pretending to be: JKKK2 is weaker than QQQQ2 because J is weaker than Q.

Now, the above example goes very differently:

32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
32T3K is still the only one pair; it doesn't contain any jokers, so its strength doesn't increase.
KK677 is now the only two pair, making it the second-weakest hand.
T55J5, KTJJT, and QQQJA are now all four of a kind! T55J5 gets rank 3, QQQJA gets rank 4, and KTJJT gets rank 5.
With the new joker rule, the total winnings in this example are 5905.

Using the new joker rule, find the rank of every hand in your set. What are the new total winnings?
 #>

$ExampleAnswer2 = 5905

function aoc20231207p2 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    function Measure-Hand {
        param (
            [string[]]$Cards,
            [string]$Hand
        )

        $Count = @{}

        ForEach ($Card in $Cards) {

            $Count.$Card = ($Hand -replace "[^$Card]").Length
        }
        
        # Determine the hand type based on counts of cards, and handle Jokers.
        $Result = If ( ($Count.Values | Measure-Object -Maximum).Maximum -eq 5 ) {"5oaK"}
            ElseIf ( ($Count.Values | Measure-Object -Maximum).Maximum -eq 4 ) {"4oaK" }
            ElseIf ( $Count.Values -contains 3 -and $Count.Values -contains 2 ) {"FH"}
            ElseIf ( $Count.Values -contains 3 ) {"3oaK"}
            ElseIf ( ($Count.Values | Where-Object { $_ -eq 2 } | Measure-Object).Count -eq 2 ) {"2Pair"}
            ElseIf ( $Count.Values -contains 2 ) {"1Pair"}
            Else {"HC"}

        If ($Count.J -gt 0 -and $Count.J -lt 5) {
            
            Switch ($Result) {
                # If we have 5 of a kind, Jokers make no difference.
                "5oaK" { }

                # If we have 4 of a kind, a Joker makes it 5 of a kind.
                # And if we have 4 Jokers, they can all turn into the other card.
                "4oaK"{ $Result = "5oaK" }

                # If we have FH, we either have 2 or 3 Jokers.
                # Either way, it's now 5 of a kind.
                "FH"{ $Result = "5oaK" }

                # If we have 3 of a kind, add 1 Joker to make 4 of a kind.
                # We can't have 2 Jokers, as that would already be a FH.
                # If we have 3 Jokers, add them to one of the other cards to make 4 of a kind.
                "3oaK" { $Result = "4oaK"}

                # If we have 2 pairs, add a Joker to the strongest pair to make a FH.
                # If one of the pairs is Jokers, now we have 4 of a kind.
                "2Pair" { Switch ($Count.J) {

                    1 {$Result = "FH"}
                    2 {$Result = "4oaK"}
                    default { Write-Host "$_ doesn't handle "$Count.J"jokers." }
                    }
                }

                # If we have a pair, add a Joker to make 3 of a kind.
                # We can't have 2 Jokers, else we'd already have 2 pairs.
                # We can't have 3 Jokers, else we'd already have a full house.
                "1Pair" { $Result = "3oaK"}

                # Otherwise, add the Joker to the highest card to make a pair.
                # We can't have 2 Jokers, else we'd already have a pair.
                # We can't have 3 Jokers, else we'd already have a 3 of a kind.
                # We can't have 4 Jokers, else we'd already have a 4 of a kind.
                "HC" { $Result = "1Pair"}
            }
        }

        $Result
    }

    # Jacks are now Jokers.
    $CardRank = "A","K","Q","T","9","8","7","6","5","4","3","2","J"

    $HandRank = "5oaK","4oaK","FH","3oaK","2Pair","1Pair","HC"

    # Parse the input into Hands and Bids.
    $Cards = $PuzzleInput | ForEach-Object { ($_ -split '\s+')[0] }
    $Bids = $PuzzleInput | ForEach-Object { ($_ -split '\s+')[1] }
    
    # Build an array for the results.
    $Hands = @()

    # Parse each Hand into a hashtable.
    For ($i=0; $i -lt $Cards.Count; $i++) {

        $Hands += ,@{"Hand"=$Cards[$i]
                     "Bid"=$Bids[$i]}
        
        # Determine the primary rank of each hand.
        $Hands[-1].PrimaryRank = $HandRank.IndexOf( (Measure-Hand $CardRank $Cards[$i]))
    }
    

    # Sort the hands into order and calculate the winnings.
    $i = $Hands.Count
    ForEach ( $Hand in ($Hands | Sort-Object {$_.PrimaryRank},{$CardRank.IndexOf($_.Hand[0].ToString())},
                                                              {$CardRank.IndexOf($_.Hand[1].ToString())},
                                                              {$CardRank.IndexOf($_.Hand[2].ToString())},
                                                              {$CardRank.IndexOf($_.Hand[3].ToString())},
                                                              {$CardRank.IndexOf($_.Hand[4].ToString())}) ) {

        [int64]$Hand.OverallRank = $i--

        [int64]$Hand.Winnings = [int64]$Hand.Bid * [int64]$Hand.OverallRank
    }

    $Total = ($Hands.Winnings | Measure-Object -Sum).Sum

    # Return the answer
    $Total
}



# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231207p2 $ExampleInput -Debug) -eq $ExampleAnswer2) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231207p2 $PuzzleInput
}
Else {$False}