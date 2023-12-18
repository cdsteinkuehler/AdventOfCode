# Advent of Code Solutions

Solutions for the Advent of Code challenge written in bash

Conventions:
* Problem input should be downloaded to the file `input` in the same
  directory as the daily scripts
* Example input should be downloaded to the file `example` in the same
  directory as the daily scripts
* Provide a filename to run the examples, eg: `./script1.sh example`
* Launched w/o a filename, the scripts will read the file `input`

## 2023 Notes

### Day 6

Trivially solvable with the quadratic formula, but I was lazy and just
let my routine from part 1 chew on the data

### Day 17

This is the only problem I don't really have a workable solution for
using bash.  The heap implementation just seems to chew too much time
to run effectively, and I have yet to find a better algorithm.

The python and C code I have seen for this day run in a reasonable
amount of time, but the python solution still took several seconds for
part 2
