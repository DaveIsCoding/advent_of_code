<# If you want to get out ahead of the animal, you should find the tile in the loop that is farthest from the starting position. Because the animal is in the pipe, it doesn't make sense to measure this by direct distance. Instead, you need to find the tile that would take the longest number of steps along the loop to reach from the starting point - regardless of which way around the loop the animal went.

In the first example with the square loop:

.....
.S-7.
.|.|.
.L-J.
.....
You can count the distance each tile in the loop is from the starting point like this:

.....
.012.
.1.3.
.234.
.....
In this example, the farthest point from the start is 4 steps away.

Find the single giant loop starting at S. How many steps along the loop does it take to get from the starting position to the point farthest from the starting position?
#>

$Day="10"

# Input from the site, they asked not to make automated requests.
$ExampleInput = Get-Content .\2023\$Day\example_input.txt
$PuzzleInput = Get-Content .\2023\$Day\puzzle_input.txt

$ExampleAnswer = 4

function aoc20231210p1 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    # First, let's build a logical map of the pipe network.
    $StartPointChar = "S"
    $ValidChar = "S","-","7","|","L","J"

    # Any pipe component at position[$x][$y] can be adjacent to 4 potential others between [$x-1][$y-1] and [$y+1][$y+1]

    # Our input is already in a 2D array, but it's [$y][$x], because it's lines, then characters.

    function Get-StartPoint {
        param(
            [string[]]$Array,
            [string]$StartPointChar
        )
        For ($y=0; $y -lt $Array.Count; $y++) {

            For ($x=0; $x -lt $Array[$y].Length; $x++) {

                If ($Array[$y][$x] -eq $StartPointChar ) { Return @([int64]$y,[int64]$x) }
            }
        }
    }


    function Test-Connected {
        param ([string]$a,
               [string]$b,
               [string]$Direction
        )

        # To be connected:
        # the b above a must be either |, 7, or F
        $Above = "S","|","7","F"

        # the b below a must be either |, J, or L
        $Below = "S","|","J","L"

        # the b to the left of a must be either -, F, or L
        $Left = "S","-","F","L"

        # the b to the right of a must be either -, 7, or J
        $Right = "S","-","7","J"

        Switch ($Direction) {
            
            # Is above b connected to below a?
            "Above"{
                If ($Above -contains $b -and $Below -contains $a) { $Connected = $True } Else { $Connected = $False }
            }

            # Is below b connected to above a?
            "Below" {
                If ($Below -contains $b -and $Above -contains $a) { $Connected = $True } Else { $Connected = $False }
            }

            # Is left b connected to right a?
            "Left" {
                If ($Left -contains $b -and $Right -contains $a) { $Connected = $True } Else { $Connected = $False }
            }

            # Is right b connected to left a?
            "Right" {
                If ($Right -contains $b -and $Left -contains $a) { $Connected = $True } Else { $Connected = $False }
            }

            Default { $Connected = $False }
        }
        $Connected
    }
    
    function Test-ValidAdjacent {
        param(
            [string[]]$Array,
            [int64]$y,
            [int64]$x
        )

        # Return an array of connected y,x coordinates.
        # We can't check beyond the limits of the array.
        $Connected = @()
        If ( ($y-1 -ge 0) -and ( Test-Connected $Array[$y][$x] $Array[$y-1][$x] "Above") )               { $Connected += ,[int64[]]@([int64]($y-1),[int64]$x) }
        If ( ($y+1 -lt $Array.Count) -and ( Test-Connected $Array[$y][$x] $Array[$y+1][$x] "Below") )     { $Connected += ,[int64[]]@([int64]($y+1),[int64]$x) }
        If ( ($x-1 -ge 0) -and ( Test-Connected $Array[$y][$x] $Array[$y][$x-1] "Left" ) )               { $Connected += ,[int64[]]@([int64]$y,[int64]($x-1)) }
        If ( ($x+1 -lt $Array[$y].Length) -and (Test-Connected $Array[$y][$x] $Array[$y][$x+1] "Right") ) { $Connected += ,[int64[]]@([int64]$y,[int64]($x+1)) }

        $Connected
    }


    function Get-ConnectedNodes {
        param (
            [int64[]]$StartPoint,
            [string[]]$Array
        )

        Test-ValidAdjacent $Array $StartPoint[0] $StartPoint[1]
    }

    function Get-NewEnd {
        param (
            [int64[]]$StartPoint,
            [string[]]$Array,
            $Previous
        )

        $NewEnds = Get-ConnectedNodes $StartPoint $Array
        
        (Compare-Object $NewEnds (,$Previous)).InputObject
    }



    # Get the coordinates of the Start Point.
    [int64[]]$StartPoint = [int64[]](Get-StartPoint $PuzzleInput $StartPointChar)

    # The start point is connected to ==2 nodes.
    # Get each of those nodes.
    $Ends = Get-ConnectedNodes $StartPoint $PuzzleInput
    
    # Keep track of where we came from.
    $Breadcrumb0 = @(($StartPoint),($Ends[0]))
    $Breadcrumb1 = @(($StartPoint),($Ends[1]))
    $i++

    # Check if the 2 ends are the same node.
    # If so, we closed the loop. How many steps did it take?
    While ( $Ends[0][0] -ne $Ends[1][0] -or $Ends[0][1] -ne $Ends[1][1] ) { 

        # If not, the ends are each also connected to ==2 nodes.
        # Are is the other node the same node?
        $Ends[0] = @(Get-NewEnd $Ends[0] $PuzzleInput $Breadcrumb0[($i-1)])
        $Ends[1] = @(Get-NewEnd $Ends[1] $PuzzleInput $Breadcrumb1[($i-1)])

        $Breadcrumb0 += ,($Ends[0])
        $Breadcrumb1 += ,($Ends[1])

        # Count how many steps it took.
        $i++
    }

    $Steps = $i
    
    # Return the answer
    $Steps
}

# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231210p1 $ExampleInput -Debug) -eq $ExampleAnswer) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231210p1 $PuzzleInput
}
Else {$False}

<# --- Part Two ---
 #>

$ExampleAnswer2 = 0

function aoc20231210p2 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    # Return the answer.
    $Total
}



# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231210p2 $ExampleInput -Debug) -eq $ExampleAnswer2) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231210p2 $PuzzleInput
}
Else {$False}