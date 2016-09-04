#!/bin/bash

# Colours <3
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Function to show the script's usage
function usage
{
    printf "Usage: ./tconv.sh -m atoh -i some_text"
    printf "\n\t-m, --mode\tMode, available modes: \n\t\t\t\trev  (Endianness)\n\t\t\t\tatoh (ASCII to Hex)\n\t\t\t\tatod (ASCII to Decimal)\n\t\t\t\tdtoa (Decimal to ASCII)\n\t\t\t\tdtoh (Decimal to Hex)\n\t\t\t\thtoa (Hex to ASCII)\n\t\t\t\thtod (Hex to Decimal)"
    printf "\n\t-i, --input\tThe ASCII/decimal/hex value you want to convert"
    printf "\n\t-h, --help\tShow help and exit\n"
    printf "\nTo read from a file, use: ./tconv.sh -m atoh -i \"\$(cat test.txt)\"\n"
}

while [ "$1" != "" ]; do
    case $1 in
        -m | --mode )           shift
                                mode=$1
                                ;;
        -i | --input )          shift
                                input=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

function rev
{
    input=$(echo ${input} | sed 's/0x//')
    printf "${BOLD}Input:\n\t${GREEN}${BOLD}0x${input}${RESET}\n"
    printf "${BOLD}Payload:${RESET}\n\t"
    echo -e "${GREEN}${BOLD}\\\x${input:0:2}\\\x${input:2:2}\\\x${input:4:2}\\\x${input:6:2}${RESET}"

    result1=$(echo ${input:6:2}${input:4:2}${input:2:2}${input:0:2})
    result2=$(echo "\\\x${input:6:2}\\\x${input:4:2}\\\x${input:2:2}\\\x${input:0:2}")
    printf "\n${BOLD}Reversed Input:${RESET}\n\t"
    echo -e "${RED}${BOLD}0x${result1}${RESET}"
    printf "${BOLD}Reversed Payload:${RESET}\n\t"
    echo -e "${RED}${BOLD}${result2}${RESET}"
}

function atoA
{
    printf "ASCII:\n\t${input}\n"
    printf "Decimal:\n\t"
    atod
    printf "Hex:\n\t"
    atoh
}

function dtoA
{
    printf "Decimal:\n\t${input}\n"
    printf "ASCII:\n\t"
    dtoa
    printf "Hex:\n\t"
    dtoh
}

function htoA
{
    printf "Hex:\n\t${input}\n"
    printf "ASCII:\n\t"
    htoa
    printf "Decimal:\n\t"
    htod
}

# ASCII to Decimal Conversion
function atod
{
    result=$(python -c "for i in \"${input}\": print ord(i)")
    echo ${result}
}

# ASCII to Hex Conversion
function atoh
{
    result=$(xxd -p <<< "${input}")
    echo "${result:0:${#result}-2}"
}

# Decimal to ASCII Conversion
function dtoa
{
    # I need to fix the spaces here!
    result=$(python -c "for i in \"${input}\".split(): print chr(int(i))")
    echo ${result}
}

# Decimal to Hex Conversion
function dtoh
{
    result=$(python -c "for i in \"${input}\".split(): print hex(int(i))" | sed 's/0x//' | tr -d [:space:])
    echo ${result}
}

# Hex to ASCII Conversion
function htoa
{
    if (( $(printf "${input}" | cut -c1-2) != "0x" )); then
    	input=$(printf "0x${input}")
    fi
    result=$(xxd -r -p <<< ${input})
    echo "${result}"
}

# Hex to Decimal Conversion
function htod
{
    input=$(echo -n ${input} | sed 's/0x//')
    result=$(python -c "print int(\"0x\"+\"${input}\", 0),;")
    echo "${result}"
}

# Modes
Modes[0]='rev'
Modes[1]='atoh'
Modes[2]='atod'
Modes[3]='dtoa'
Modes[4]='dtoh'
Modes[5]='htoa'
Modes[6]='htod'
Modes[7]='atoA'
Modes[8]='dtoA'
Modes[9]='htoA'


# Check if an implemented mode has been provided
match=0
for mod in "${Modes[@]}"; do
    if [[ $mod = "$mode" ]];
    then
        match=1
        break
    fi
done

# Check if the user provided all the required arguments and values
if [ "$mode" !=  "" ] && [ $match !=  0 ] && [ "$input" != "" ]
then
    ${mode}
else
    usage
fi
