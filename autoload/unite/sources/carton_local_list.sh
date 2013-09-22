#!/bin/sh

set -e
LIBPATH=`carton exec -- perl -e 'print join q{ }, grep { index($_, $ENV{PERL5LIB}) > -1 } @INC'`
find $LIBPATH -name '*.pm' -type f | xargs egrep -o 'package [a-zA-Z0-9:]+;' | perl -nle 's/package\s+(.*);/$1/; print' | uniq
