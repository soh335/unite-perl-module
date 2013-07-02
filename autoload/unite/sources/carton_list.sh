#!/bin/sh

if [ $1 ]; then
  cd $1
fi
find `carton exec -- perl -MCwd -e 'pop @INC; print join(q{ }, grep { -d } map { Cwd::abs_path($_) } @INC);'` -name '*.pm' -type f | xargs egrep -o 'package [a-zA-Z0-9:]+;' | perl -nle 's/package\s+(.*);/$1/; print' | sort | uniq
