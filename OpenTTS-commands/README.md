

Get a list of the voices available, make a sample of each

```for V in $(curl -s http://127.0.0.1:5500/api/voices |jq -r 'map_values(select(.language == "en"))|keys[]'); do OF=/tmp/tts-$V.wav; cat /tmp/text.txt | /tmp/tts2.sh -v $V >$OF ; echo "$OF"; sleep 1;done```

Play qall of the files

for i in $(ls /tmp/tts*.wav); do sleep 1;echo "Playing $i"; paplay --file-format=rf64  $i;done


