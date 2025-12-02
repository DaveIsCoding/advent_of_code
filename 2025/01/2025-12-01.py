from os import replace


Day="01"

# Input from the site, they asked not to make automated requests.
with open("C:/Users/daveh/OneDrive/IT/Advent_of_Code/advent_of_code/2025/01/2025-12-01_example.txt", "r") as f:
    ExampleInput = f.readlines()
with open("C:/Users/daveh/OneDrive/IT/Advent_of_Code/advent_of_code/2025/01/2025-12-01_input.txt", "r") as f:
    PuzzleInput = f.readlines()

# PART 1
# We start at 50
dial = 50
answer = 0

for instruction in PuzzleInput:

    instruction = instruction.replace("\n", "")

    if instruction[0] == "L":
        move = 0 - int(instruction[1:])
    else:
        move = int(instruction[1:])
    dial = dial + move

    if dial < 0:
        dial = 100 + dial % 100

    if dial > 99:
        dial = dial % 100
    
    if dial == 0:
        answer += 1

print("Part 1:", answer)
