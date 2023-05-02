#!/bin/bash

V_LANG=en
V_GENDER=male

SAY="Jeeves, I said, may I speak frankly?"

VOICES=()

# get list of voices

for V in $(wget -q -O - "localhost:5500//api/voices?language=${V_LANG}&?gender=${V_GENDER}"  |jq  keys[] |tr -d \")
 do
  VOICES+=(${V})
done

for VOICE in "${VOICES[@]}"
 do
  W_FILE="/tmp/voice-${V_LANG}-${V_GENDER}-${VOICE}.wav"
  wget -q "localhost:5500//api/tts?voice=${VOICE}&text=${SAY}" -O - > ${W_FILE}
  echo "${W_FILE}"
done

