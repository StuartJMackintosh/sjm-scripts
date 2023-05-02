

# Code snippets and one-liners


## Email addresses from file

FNAME=email-addresses.txt; sed -r 's/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/\n&\n/ig;s/(^|\n)[^@]*(\n|$)/\n/g;s/^\n|\n$//g;/^$/d' ${FNAME}  | sort -u > clean-${FNAME}

## domain names from email addresses

FNAME=clean-email-addresses.txt; cat ${FNAME} | grep -Eiorh '(@[[:alnum:].-]+?\.[[:alpha:].]{2,4})'  | tr -d "@" |sort -u > domans-${FNAME}

## basic check to see if there is a website on a domain

FNAME=domans-clean-email-addresses.txt; for DOMAIN in $(cat ${FNAME}); do  wget --spider --server-response ${DOMAIN} 2>&1 | grep -q '200\ OK' ; if [ $? -eq 0 ]; then echo "$DOMAIN";fi ; done > websites-${FNAME}

