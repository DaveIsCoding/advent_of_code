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
        $Map,
        [Switch]$Debug = $False,
        [Switch]$Part2Mode = $False
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
    [int64[]]$StartPoint = [int64[]](Get-StartPoint $Map $StartPointChar)

    # The start point is connected to ==2 nodes.
    # Get each of those nodes.
    $Ends = Get-ConnectedNodes $StartPoint $Map
    
    # Keep track of where we came from.
    $Breadcrumb0 = @(($StartPoint),($Ends[0]))
    $Breadcrumb1 = @(($StartPoint),($Ends[1]))
    # For part 2
    $ConnectedPipes = ($StartPoint),($Ends[0]),($Ends[1])
    $i++

    # Check if the 2 ends are the same node.
    # If so, we closed the loop. How many steps did it take?
    While ( $Ends[0][0] -ne $Ends[1][0] -or $Ends[0][1] -ne $Ends[1][1] ) { 

        # If not, the ends are each also connected to ==2 nodes.
        # Are the other nodes the same node?
        [int64[]]$End0 = @(Get-NewEnd $Ends[0] $Map $Breadcrumb0[($i-1)])
        [int64[]]$End1 = @(Get-NewEnd $Ends[1] $Map $Breadcrumb1[($i-1)])

        $Ends = @(($End0),($End1))

        $Breadcrumb0 += ,($End0)
        $Breadcrumb1 += ,($End1)
        $ConnectedPipes += ,($End0)
        $ConnectedPipes += ,($End1)

        # Count how many steps it took.
        $i++
    }

    $Steps = $i
    
    # Return the either the answer, or the Breadcrumb list (for part 2).
    If ($Part2Mode) { $ConnectedPipes }
    Else { $Steps }
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
You quickly reach the farthest point of the loop, but the animal never emerges. Maybe its nest is within the area enclosed by the loop?

To determine whether it's even worth taking the time to search for such a nest, you should calculate how many tiles are contained within the loop. For example:

...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
The above loop encloses merely four tiles - the two pairs of . in the southwest and southeast (marked I below). The middle . tiles (marked O below) are not in the loop. Here is the same loop again with those regions marked:

...........
.S-------7.
.|F-----7|.
.||OOOOO||.
.||OOOOO||.
.|L-7OF-J|.
.|II|O|II|.
.L--JOL--J.
.....O.....
In fact, there doesn't even need to be a full tile path to the outside for tiles to count as outside the loop - squeezing between pipes is also allowed! Here, I is still within the loop and O is still outside the loop:

..........
.S------7.
.|F----7|.
.||OOOO||.
.||OOOO||.
.|L-7F-J|.
.|II||II|.
.L--JL--J.
..........
In both of the above examples, 4 tiles are enclosed by the loop.

Here's a larger example:

.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
The above sketch has many random bits of ground, some of which are in the loop (I) and some of which are outside it (O):

OF----7F7F7F7F-7OOOO
O|F--7||||||||FJOOOO
O||OFJ||||||||L7OOOO
FJL7L7LJLJ||LJIL-7OO
L--JOL7IIILJS7F-7L7O
OOOOF-JIIF7FJ|L7L7L7
OOOOL7IF7||L7|IL7L7|
OOOOO|FJLJ|FJ|F7|OLJ
OOOOFJL-7O||O||||OOO
OOOOL---JOLJOLJLJOOO
In this larger example, 8 tiles are enclosed by the loop.

Any tile that isn't part of the main loop can count as being enclosed by the loop. Here's another example with many bits of junk pipe lying around that aren't connected to the main loop at all:

FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
Here are just the tiles that are enclosed by the loop marked with I:

FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJIF7FJ-
L---JF-JLJIIIIFJLJJ7
|F|F-JF---7IIIL7L|7|
|FFJF7L7F-JF7IIL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
In this last example, 10 tiles are enclosed by the loop.

Figure out whether you have time to search for the nest by calculating the area within the loop. How many tiles are enclosed by the loop?
 #>

$ExampleAnswer2 = 10
$ExampleInput2 = Get-Content .\2023\$Day\example_input2.txt

function aoc20231210p2 {
    param (
        $PuzzleInput,
        [Switch]$Debug = $False
    )

    # Inner tiles are only those which are surrounded by
    # other inner tiles, and CONNECTED pipes.
    # Remember, there are also UNCONNECTED pipes.

    # Call the Part 1 code to get the connected pipe lists.
    $Connected = aoc20231210p1 $PuzzleInput -Part2Mode

    # Redraw the map.
    $Map = @()
    For ($y=0; $y -lt $PuzzleInput.Count; $y++) {

        $Row=""
        For ($x=0; $x -lt $PuzzleInput[$y].Length; $x++) {

            $Tile="0"
            ForEach ($Node in $Connected) { 
                $Node -join "-" | Where-Object { $_ -eq "$y-$x" } |  ForEach-Object { $Tile="+" }
            }
            $Row += $Tile
        }
        $Map += ,$Row
    }

    function Get-AdjacentTiles{
        param(
            $y,
            $x,
            $Array
        )
        # First Row.
        If ($y -eq 0) {

            # First column. 
            If ($x -eq 0) {
                $Array[$y][($x+1)]+$Array[($y+1)][$x..($x+1)]
            }
            ElseIf ($x -lt ($Array[$y].Length -1) ) {
                $Array[$y][($x-1),($x+1)]+$Array[($y+1)][($x-1)..($x+1)]
            }
            # Last column.
            Else{
                $Array[$y][($x-1)]+$Array[($y+1)][($x-1)..$x]
            } 
        }
        ElseIf ($y -lt ($Array.Count -1) ) {
            # First column. 
            If ($x -eq 0) {
                $Array[($y-1)][$x..($x+1)]+$Array[$y][($x+1)]+$Array[($y+1)][$x..($x+1)]
            }
            ElseIf ($x -lt ($Array[$y].Length -1) ) {
                $Array[($y-1)][($x-1)..($x+1)]+$Array[$y][($x-1),($x+1)]+$Array[($y+1)][($x-1)..($x+1)]
            }
            # Last column.
            Else{
                $Array[($y-1)][($x-1)..$x]+$Array[$y][($x-1)]+$Array[($y+1)][($x-1)..$x]
            } 
        }
        #Last row.
        Else {
            # First column.
            If ($x -eq 0) {
                $Array[($y-1)][$x..($x+1)]+$Array[$y][($x+1)]
            }
            ElseIf ($x -lt ($Array[$y].Length -1) ) {
                $Array[($y-1)][($x-1)..($x+1)]+$Array[$y][($x-1),($x+1)]
            }
            # Last column.
            Else{
                $Array[($y-1)][($x-1)..$x]+$Array[$y][($x-1)]
            }
        } 
    }

    For ($y=0; $y -lt $Map.Count; $y++) {

        For ($x=0; $x -lt $Map[$y].Length; $x++) {

            # If THIS tile is not a connected pipe,
            # and no adjacent tile is anything other than a + or the S,
            # increment the count of inner tiles.
            If ($Map[$y][$x] -notmatch "[S\+]" ) {

                If ( Get-AdjacentTiles $y $x $Map -replace '\s+' | Where-Object { $_ -notmatch "[S\+]" } ) { $Total++ }
            }
        }

    } 

    # Return the answer.
    $Total
}



# Test with the example input.
Write-Host "Testing code against example input:"
If ((aoc20231210p2 $ExampleInput2 -Debug) -eq $ExampleAnswer2) {$True

    # Run against the puzzle input.
    Write-Host "Running against puzzle input:"
    aoc20231210p2 $PuzzleInput
}
Else {$False}