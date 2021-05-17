#!/bin/sh

to="some-email-address@domain.com"

if [ "$1" = "-to" ]
then
    to="$2"
    shift
    shift
fi

while [ -n "$1" ]
do
    if [ -e "$1" ]
    then
        echo "Mailing $1 to $to" 1>&2
        echo "Attached: $1" | mail -s "$1" -a "$1" "$to"
    else
        echo "Mailing STDIN as $1 to $to" 1>&2
        tmpdir=$(mktemp -p $HOME/tmp -d)
        cat > "$tmpdir/$1"
        (
            cd "$tmpdir"
            echo "Attachted: $1" | mail -s "$1" -a "$1" "$to"
        )
        rm -rf "$tmpdir"
    fi
    shift
done
