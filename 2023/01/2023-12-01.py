# Multiline comment hack:
'''
# --- Day 1: Trebuchet?! ---
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
Consider your entire calibration document. What is the sum of all of the calibration values?
'''
# Input from the site, they asked not to make automated requests.
with open('./2023/01/puzzle_input.txt', 'r') as file:
    # Read all lines into a list
    PUZZLE_INPUT = file.readlines()

import re

def aoc20231201p1(lines):
    
    # Clean the lines of non-digits.
    clean_lines = []
    for line in lines:
        clean_line = re.sub(r'\D', '', line)
        clean_lines.append(clean_line)

    # Now we only want to keep the first and last digit of each line.
    # All strings in Python are natively an array of characters.
    values = []
    for line in clean_lines:
        value = line[0] + line[-1]
        values.append(value)

    # Sum up the numbers, casting them as integers.
    #$Values | ForEach-Object { $Total += [int32]$_ }
    total = 0
    for value in values:
        total += (int(value))

    print(total)
    
aoc20231201p1(PUZZLE_INPUT)

# Multiline comment hack:
''' --- Part Two ---
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

What is the sum of all of the calibration values?'''

def aoc20231201p2(lines):
    
    # Insert the corresponding digit into numeric words.
    # We put it after the first letter in case two words collide.
    digit_lines = []
    for line in lines:
        digit_line = (line.replace("one", "o1ne")
                          .replace("two", "t2wo")
                          .replace("three", "t3hree")
                          .replace("four", "f4our")
                          .replace("five", "f5ive")
                          .replace("six", "s6ix")
                          .replace("seven", "s7even")
                          .replace("eight", "e8ight")
                          .replace("nine", "n9ine") )

        digit_lines.append(digit_line)

    # Clean the lines of non-digits.
    clean_lines = []
    for line in digit_lines:
        clean_line = re.sub(r'\D', '', line)
        clean_lines.append(clean_line)

    # Now we only want to keep the first and last digit of each line.
    # All strings in Python are natively an array of characters.
    values = []
    for line in clean_lines:
        value = line[0] + line[-1]
        values.append(value)

    # Sum up the numbers, casting them as integers.
    #$Values | ForEach-Object { $Total += [int32]$_ }
    total = 0
    for value in values:
        total += (int(value))

    print(total)

aoc20231201p2(PUZZLE_INPUT)    