#!/bin/sh

find `perl -e 'pop @INC; print join(q{ }, @INC);'` -name '*.pm' -type f | xargs egrep -o 'package [a-zA-Z0-9:]+;' | perl -nle 's/package\s+(.*);/$1/; print' | sort | uniq
