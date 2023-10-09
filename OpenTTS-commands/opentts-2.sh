#!/bin/bash

D_VOICE="larynx:southern_english_female-glow_tts"
D_SERVER="http://127.0.0.1:5500"

while getopts v:m:s:h ARGS
do
    case "${ARGS}" in
        v) A_VOICE=${OPTARG};;
        m) A_MESSAGE=${OPTARG};;
        s) A_SERVER=${OPTARG};;
	h) show_help;;

    esac
done

show_help() {

echo "Usage:"
echo "-v <voice>"
echo "-m message (or stdin)"
echo "-s server"
echo "-h this help"
echo ""
echo "Output format: rf64"

exit 1
}


[[ -z $A_MESSAGE ]] && A_MESSAGE=$(cat) 


VOICE=${A_VOICE:-${D_VOICE}}
MESSAGE=${A_MESSAGE:-${D_MESSAGE}}
SERVER=${A_SERVER:-${D_SERVER}}

# https://github.com/synesthesiam/opentts/blob/master/swagger.yaml

U="${SERVER}/api/tts?vocoder=high&denoiserStrength=0.03&cache=0"

curl -s --output - -X GET -G \
	--data-urlencode "voice=${VOICE}" \
	--data-urlencode "text=${MESSAGE}" \
	${U} 
        #| sox -q -t raw -b 16 -e signed -c 2 -r 8000 - -t wav - 2>/dev/null

