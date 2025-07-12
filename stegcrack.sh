#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

output="steg_pass.txt"

usage() {
    echo -e "${YELLOW}USAGE: $0 [-o outputfile] stegoFile wordlist.txt${NC}"
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

while getopts ":o:" opt; do
    case $opt in
        o) output="$OPTARG" ;;
        \?) echo -e "${RED}Invalid option: -$OPTARG${NC}"; usage ;;
        :) echo -e "${RED}Option -$OPTARG requires an argument.${NC}"; usage ;;
    esac
done

shift $((OPTIND -1))

if [[ $# -ne 2 ]]; then
    usage
fi

stegoFile="$1"
wordlist="$2"

if [[ ! -f "$stegoFile" ]]; then
    echo -e "${RED}Error: File '$stegoFile' not found.${NC}"
    exit 1
fi

if [[ ! -f "$wordlist" ]]; then
    echo -e "${RED}Error: Wordlist '$wordlist' not found.${NC}"
    exit 1
fi

while IFS= read -r password || [[ -n "$password" ]]; do
    [[ -z "$password" ]] && continue
    steghide extract -sf "$stegoFile" -p "$password" -xf "$output" -f &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "\n${GREEN}SUCCESS - Password found: $password${NC}"
        echo -e "${GREEN}Extracted to: $output${NC}"
        exit 0
    else
        echo -e "${RED}FAILED - $password${NC}"
    fi
done < "$wordlist"

echo -e "${RED}Password not found in the provided wordlist.${NC}"
exit 1
