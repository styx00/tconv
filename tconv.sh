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
    printf "\n\t-m, --mode\tMode, available modes:
                            rev  (Reverse Endianness)
                            atoh (ASCII to Hex)
                            atod (ASCII to Decimal)
                            dtoa (Decimal to ASCII)
                            dtoh (Decimal to Hex)
                            htoa (Hex to ASCII)
                            htod (Hex to Decimal)"
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
    result=$(xxd -p <<< "${input}" | tr -d \\n)
    echo "${result:0:${#result}-2}"
}

# Decimal to ASCII Conversion
function dtoa
{
    # I need to fix the spaces here!
    for n in ${input}
    do
        if [ $n -eq $n 2>/dev/null ]; then
            if [[ $n -gt 256 ]] || [[ $n -lt 0 ]]; then
                check="failedRange"
            fi
        else
            check="failedType"
        fi
    done

    if [[ ${check} == "failedRange" ]]; then
        echo "The provided input contains reference(s) to non-ASCII characters."
    elif [[ ${check} == "failedType" ]]; then
        echo "The provided input contains non-Decimal characters."
    else
        result=$(python -c "for i in \"${input}\".split(): print chr(int(i))")
        echo ${result}
    fi
}

# Decimal to Hex Conversion
function dtoh
{
    for n in ${input}
    do
        if [ $n -ne $n 2>/dev/null ]; then
            check="failedType"
        fi
    done

    if [[ ${check} == "failedType" ]]; then
        echo "The provided input contains non-Decimal characters."
    else
        result=$(python -c "for i in \"${input}\".split(): print hex(int(i))" | sed 's/0x//g')
        echo ${result}
    fi
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
    input=$(echo -n ${input} | sed 's/0x//g')
    result=$(python -c "for i in \"${input}\".split(): print int(\"0x\"+i, 0),;")
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
