<# This format defines each node of the network individually. For example:

RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
Starting with AAA, you need to look up the next element based on the next left/right instruction in your input. In this example, start with AAA and go right (R) by choosing the right element of AAA, CCC. Then, L means to choose the left element of CCC, ZZZ. By following the left/right instructions, you reach ZZZ in 2 steps.

Of course, you might not find ZZZ right away. If you run out of left/right instructions, repeat the whole sequence of instructions as necessary: RL really means RLRLRLRLRLRLRLRL... and so on. For example, here is a situation that takes 6 steps to reach ZZZ:

LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
Starting at AAA, follow the left/right instructions. How many steps are required to reach ZZZ?
#>

$Day="08"

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\$Day\example_input.txt
$PuzzleInput = Get-Content .\2023\$Day\puzzle_input.txt

$ExampleAnswer = 2

function aoc20231208p1 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    # Parse the input.
    $Operation = $PuzzleInput[0]
    $Map = @{}

    ForEach ($Line in $PuzzleInput[2..($PuzzleInput.Count-1)] ) {
        
        $Node = $Line.Split("=").Trim(" ")[0]
        $Map.$Node = @($Line.Split("=")[1].Trim(" ()").Split(",").Trim(" "))
    }

    # Follow the map.
    function Get-NextNode {
        param (
            $Map,
            $CurrentNode,
            $Operation
        )

        Switch ($Operation) {
            "L" {$Map.$CurrentNode[0]}
            "R" {$Map.$CurrentNode[1]}
        }        
    }

    $Node = "AAA"

    While ($Node -ne "ZZZ") {

        $Node = Get-NextNode $Map $Node $Operation[$i++]

        $Counter++

        # If we run out of operations, go around again.
        If ($i -ge $Operation.Length) {$i = 0}
    }

    # Return the answer
    $Counter
}

# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231208p1 $ExampleInput -Debug) -eq $ExampleAnswer) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231208p1 $PuzzleInput
}
Else {$False}

<# --- Part Two ---
After examining the maps a bit longer, your attention is drawn to a curious fact: the number of nodes with names ending in A is equal to the number ending in Z! If you were a ghost, you'd probably just start at every node that ends with A and follow all of the paths at the same time until they all simultaneously end up at nodes that end with Z.

For example:

LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)

Here, there are two starting nodes, 11A and 22A (because they both end with A). As you follow each left/right instruction, use that instruction to simultaneously navigate away from both nodes you're currently on. Repeat this process until all of the nodes you're currently on end with Z. (If only some of the nodes you're on end with Z, they act like any other node and you continue as normal.) In this example, you would proceed as follows:

Step 0: You are at 11A and 22A.
Step 1: You choose all of the left paths, leading you to 11B and 22B.
Step 2: You choose all of the right paths, leading you to 11Z and 22C.
Step 3: You choose all of the left paths, leading you to 11B and 22Z.
Step 4: You choose all of the right paths, leading you to 11Z and 22B.
Step 5: You choose all of the left paths, leading you to 11B and 22C.
Step 6: You choose all of the right paths, leading you to 11Z and 22Z.
So, in this example, you end up entirely on nodes that end in Z after 6 steps.

Simultaneously start on every node that ends with A. How many steps does it take before you're only on nodes that end with Z?
 #>

$ExampleAnswer2 = 6
$ExampleInput2 = Get-Content .\2023\$Day\example_input2.txt

function aoc20231208p2 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

        # Parse the input.
        $Operations = $PuzzleInput[0]
        $Map = @{}
    
        ForEach ($Line in $PuzzleInput[2..($PuzzleInput.Count-1)] ) {
            
            $Node = $Line.Split("=").Trim(" ")[0]
            $Map.$Node = @($Line.Split("=")[1].Trim(" ()").Split(",").Trim(" "))
        }

        function Get-NextNode {
            param (
                $Map,
                $CurrentNode,
                $Operation
            )
    
            Switch ($Operation) {
                "L" {$Map.$CurrentNode[0]}
                "R" {$Map.$CurrentNode[1]}
            }        
        }
    
        # Seems we have to do some math again.
        # For any given combination of start point and operation sequence,
        # there is a certain number of hops before you end up back where you started,
        # ready to go around again.

        # Suppose Start Point 1 with our operations needs 20 hops before we are back
        # at Start Point 1 and back on Operation 1.

        # Suppose Start Point 2 with our operations needs 80 hops before we are back
        # at Start Point 1 and back on Operation 1.

        # The minimum number of steps will be the lowest common multiple, in this case, 80.
        # Start Point 1 did 4 whole loops, Start Point 2 went around just once.

        function Get-LoopSize {
            param (
                $Map,
                $StartNode,
                $ExitNodes,
                $Operations
            )

            $Node = $StartNode
            $i = 0
            
            # Repeat until we get to an exit node for the first time.
            While ($ExitNodes.Keys -notcontains $Node) {

                # Make the next hop.
                $Node = Get-NextNode $Map $Node $Operations[$i++]

                # If we used all our operations, go back around again.
                If ($i -ge $Operations.Length ) { $i=0 }           
            }
            
            # Make the next hop.
            $Node = Get-NextNode $Map $Node $Operations[$i++]
            If ($i -ge $Operations.Length ) { $i=0 } 
            $Counter = 1

            # Repeat until we get to an exit node for the second time.
            # And this time, measure the loop length.
            While ($ExitNodes.Keys -notcontains $Node) {

                # Make the next hop.
                $Node = Get-NextNode $Map $Node $Operations[$i++]

                $Counter++

                # If we used all our operations, go back around again.
                If ($i -ge $Operations.Length ) { $i=0 }           
            }


            # Return the loop length by comparing the counters.
            $Counter
        }

        # Get the start nodes and exit nodes.
        $StartNodes = $Map.Keys | Where-Object { $_ -match "A$"}
        $ExitNodes = @{}
        $Map.Keys | Where-Object { $_ -match "Z$"} | ForEach-Object {$ExitNodes.Keys += $_}
        

        # Get the loop size for each start node.
        $LoopSizes = $StartNodes |  
                ForEach-Object { Get-LoopSize $Map $_.ToString() $ExitNodes $Operations }
 
        
        # Get the lowest common multiple of the loop sizes.
        # Note that we start with i at 1.
        $LCM = $LoopSizes[0]
        For ($i = 1; $i -lt $LoopSizes.Count; $i++) {

            $LCM = Get-LCM $LCM $LoopSizes[$i]
        }
         
        # Return the answer
        $LCM
}

# Helper function to get the Greatest Common Divisor of 2 numbers.
function Get-GCD {
    param (
        [int64]$a,
        [int64]$b
    )

    while ($b -ne 0) {

        [int]$origB = $b

        $b = $a % $b

        $a = $origB
    }

    [System.Math]::Abs($a)
}

# Helper function to get the Lowest Common Multiple of 2 numbers, 
# by reference to the Greatest Common Divisor.
function Get-LCM {
    param (
        [int64]$a,
        [int64]$b
    )

    [SYstem.Math]::Abs($a * $b) / (Get-GCD $a $b)
}


# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231208p2 $ExampleInput2 -Debug) -eq $ExampleAnswer2) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231208p2 $PuzzleInput
}
Else {$False}