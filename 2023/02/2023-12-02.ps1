<# For example, the record of a few games might look like this:

Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
In game 1, three sets of cubes are revealed from the bag (and then put back again). The first set 
is 3 blue cubes and 4 red cubes; the second set is 1 red cube, 2 green cubes, and 6 blue cubes; 
the third set is only 2 green cubes.

The Elf would first like to know which games would have been possible if the bag contained only 
12 red cubes, 13 green cubes, and 14 blue cubes?

In the example above, games 1, 2, and 5 would have been possible if the bag had been loaded with 
that configuration. However, game 3 would have been impossible because at one point the Elf showed 
you 20 red cubes at once; similarly, game 4 would also have been impossible because the Elf showed 
you 15 blue cubes at once. If you add up the IDs of the games that would have been possible, 
you get 8.

Determine which games would have been possible if the bag had been loaded with only 12 red cubes, 
13 green cubes, and 14 blue cubes. What is the sum of the IDs of those games?#>

# Input from the site, they asked not to make automated requests.
$PuzzleInput = Get-Content .\2023\02\puzzle_input.txt

function aoc20231202p1() {
    param (
            $PuzzleInput
        )

    # Array for the list of game results.
    $Games = @()

    # Process each game.
    # Example game: Game 1: 20 green, 3 red, 2 blue; 9 red, 16 blue, 18 green; 6 blue, 19 red, 10 green; 12 red, 19 green, 11 blue
    ForEach ($Game in $PuzzleInput) {
        
        # Just keep the digits from the Game ID.
        $GameID = $Game.Split(":")[0] -replace '\D'

        # Array to hold the game results.
        $GameData = @()

        # Break the rest of the data into sets.
        # Example set: 9 red, 16 blue, 18 green
        $Sets = $Game.Split(":")[1].Split(";").Trim(" ")

        # Sets are not always in the same order, so we need a hashtable.
        ForEach ($Set in $Sets) {

            $SetData = @{}

            # Example Entry: 9 red
            ForEach ($Entry in $Set.Split(",").Trim(" ")) {

                # Add an entry for this set, cast the number of balls as an integer.
                $SetData += @{$Entry.Split(" ")[1]=[int32]$Entry.Split(" ")[0]}

                <# Example SetData:

                Name    Value
                ----    -----
                green    20
                red       3
                blue     16
                #>
            }

            # Append the set data to the game data.
            $GameData += ,($SetData)
        }

        

        $Games += ,(New-Object -TypeName PSCustomObject | 
                    Add-Member -Name "GameID" -MemberType NoteProperty -Value $GameID -PassThru | 
                    Add-Member -Name "GameData" -MemberType NoteProperty -Value $GameData -PassThru)

    }

    # Filter for valid sets.
    $MaxRed = 12
    $MaxGreen = 13
    $MaxBlue = 14

    $PossibleGames = $Games | Where-Object { ($_.GameData.Red | Measure-Object -Max).Maximum -le $MaxRed -and
                                             ($_.GameData.Green | Measure-Object -Max).Maximum -le $MaxGreen -and
                                             ($_.GameData.Blue | Measure-Object -Max).Maximum -le $MaxBlue}

    # Sum the IDs of possible games.
    $Total = ($PossibleGames.GameID | Measure-Object -Sum).Sum

    # Return the answer.
    $Total
}

aoc20231202p1 $PuzzleInput


<# Again consider the example games from earlier:

Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
In game 1, the game could have been played with as few as 4 red, 2 green, and 6 blue cubes. If any color had even one fewer cube, the game would have been impossible.
Game 2 could have been played with a minimum of 1 red, 3 green, and 4 blue cubes.
Game 3 must have been played with at least 20 red, 13 green, and 6 blue cubes.
Game 4 required at least 14 red, 3 green, and 15 blue cubes.
Game 5 needed no fewer than 6 red, 3 green, and 2 blue cubes in the bag.
The power of a set of cubes is equal to the numbers of red, green, and blue cubes multiplied together. The power of the minimum set of cubes in game 1 is 48. In games 2-5 it was 12, 1560, 630, and 36, respectively. Adding up these five powers produces the sum 2286.

For each game, find the minimum set of cubes that must have been present. What is the sum of the power of these sets? #>

function aoc20231202p2 {
    param (
        $PuzzleInput
    )

    # Array for the list of game results.
    $Games = @()

    # Process each game.
    # Example game: Game 1: 20 green, 3 red, 2 blue; 9 red, 16 blue, 18 green; 6 blue, 19 red, 10 green; 12 red, 19 green, 11 blue
    ForEach ($Game in $PuzzleInput) {
        
        # Array to hold the game results.
        $GameData = @()

        # Break the rest of the data into sets.
        # Example set: 9 red, 16 blue, 18 green
        $Sets = $Game.Split(":")[1].Split(";").Trim(" ")

        # Sets are not always in the same order, so we need a hashtable.
        ForEach ($Set in $Sets) {

            $SetData = @{}

            # Example Entry: 9 red
            ForEach ($Entry in $Set.Split(",").Trim(" ")) {

                # Add an entry for this set, cast the number of balls as an integer.
                $SetData += @{$Entry.Split(" ")[1]=[int32]$Entry.Split(" ")[0]}

                <# Example SetData:

                Name    Value
                ----    -----
                green    20
                red       3
                blue     16
                #>
            }

            # Append the set data to the game data.
            $GameData += ,($SetData)
        }

        
        # Determine the minimum number of balls for each game.
        $Games += ,(New-Object -TypeName PSCustomObject | 
                    Add-Member -Name "MinimumRed" -MemberType NoteProperty -Value ($GameData.Red | Measure-Object -Maximum).Maximum -PassThru |
                    Add-Member -Name "MinimumGreen" -MemberType NoteProperty -Value ($GameData.Green | Measure-Object -Maximum).Maximum -PassThru |
                    Add-Member -Name "MinimumBlue" -MemberType NoteProperty -Value ($GameData.Blue | Measure-Object -Maximum).Maximum -PassThru)
    }

    # Calculate the "power" of each game.
    $Games | ForEach-Object { $_ | Add-Member -Name "Power" -MemberType NoteProperty -Value ($_.MinimumRed * $_.MinimumGreen * $_.MinimumBlue) }

    $Total = ($Games.Power | Measure-Object -Sum).Sum

    # Return the answer.
    $Total
    
}

aoc20231202p2 $PuzzleInput