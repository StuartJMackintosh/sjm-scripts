# Simple 5 line blockchain in bash for Linux & MacOS

## Preparation

You just need a terminal open on your Linux or Mac (maybe also Windows with WSL) and running ```bash```
  -  Bash is the GNU Project's shell—the Bourne Again SHell. This is an sh-compatible shell that incorporates useful features from the Korn shell (ksh) and the C shell (csh). It is intended to conform to the IEEE POSIX P1003.2/ISO 9945.2 Shell and Tools standard. It offers functional improvements over sh for both programming and interactive use. In addition, most sh scripts can be run by Bash without modification.

Additional preparitory resources

- [GNU/Linux and Richard Stallman (6:33)](https://www.youtube.com/watch?v=7twCCWjSnMg)
- [Shell script- Bash](https://learnxinyminutes.com/docs/bash/)
- [Video - HTML](https://www.w3schools.com/html/html5_video.asp)

## Tools

We will use the following tools:

variables
: places to store a thing in the computer for later

expansion
: get the output of one command, inside another

array
: a variable, for a list of items instead of just one

for loop
: run through each item in the array

## Commands

we will use the following commands: 

- ```read``` - to ask for input
- ```date``` - to get the current time to add to the block
- ```echo``` - to show us what is in the variable (like print) 
- ```shasum``` - to create a signature/stamp of our text 


## Line 1: Get input

First, lets enter some text using the ```read``` command and store in the ```INPUT``` variable

```bash

read -p "Type text here about love, then press enter > " INPUT
```

## Line 2: Create a block

Now we will add to the variable ```BLOCK```, the current date (using expansion, to run the date command, and include the output within the variable), then the contents of ```INPUT```

```bash
BLOCK="$(date +%T) $BLOCKSUM $INPUT"
```

## Line 3: Sum the block

To get a sum of our BLOCK, we use a 'SHA algorithm' (you can research if you want using this command:
- The program sha256sum is designed to verify data integrity using the SHA-256 (SHA-2 family with a digest length of 256 bits). SHA-256 hashes used properly can confirm both file integrity and authenticity.)

```bash
BLOCKSUM="$(echo -n $BLOCK | shasum -a 256 )"
```

## Line 4: Chain the block

Add the sum and block to the chain of blocks
```bash
BLOCKCHAIN+=("$BLOCKSUM $BLOCK")
```

## Line 5: Show the BlockChain

for each block in the chain, send to the screen what we have recorded using a for loop

```bash
for B in "${BLOCKCHAIN[@]}"; do echo Block: "$B"; done
```

# Script

As a script:

```bash
#!/bin/sh

clear

echo "Simple blockchain in bash"

# First, lets store some text in a block, following the date, and last block sum
read -p "Type text here, then press enter > " INPUT
BLOCK="$(date +%T) $BLOCKSUM $INPUT"
# next, we get a new sum from the block
BLOCKSUM=$(echo -n $BLOCK | shasum -a 256 )

Add the sum and block to the chain of blocks
BLOCKCHAIN+=("$BLOCKSUM $BLOCK")

# for each block in the chain, show what we have recorded
for B in "${BLOCKCHAIN[@]}"; do echo Block: "$B"; done

```
