#!/bin/sh

test $# -ge 2 || exit 1

# cd to objtree
cd "$2" || exit 1

srctree="$1"

find -type d \
| while read; do
    d="$REPLY"

    src="$srctree/$d/Kbuild.src"
    dst="$d/Kbuild"
    if test -f "$src"; then
	echo "  CHK     $dst"

	s=`grep -h '^//kbuild:' "$srctree/$d"/*.c | sed 's^//kbuild:^^'`
	while read; do
	    test x"$REPLY" = x"INSERT" && REPLY="$s"
	    printf "%s\n" "$REPLY"
	done <"$src" >"$dst.$$.tmp"

	if test -f "$dst" && cmp -s "$dst.$$.tmp" "$dst"; then
	    rm "$dst.$$.tmp"
	else
	    echo "  GEN     $dst"
	    mv "$dst.$$.tmp" "$dst"
	fi
    fi

    src="$srctree/$d/Config.src"
    dst="$d/Config.in"
    if test -f "$src"; then
	echo "  CHK     $dst"

	s=`grep -h '^//config:' "$srctree/$d"/*.c | sed 's^//config:^^'`
	while read; do
	    test x"$REPLY" = x"INSERT" && REPLY="$s"
	    printf "%s\n" "$REPLY"
	done <"$src" >"$dst.$$.tmp"

	if test -f "$dst" && cmp -s "$dst.$$.tmp" "$dst"; then
	    rm "$dst.$$.tmp"
	else
	    echo "  GEN     $dst"
	    mv "$dst.$$.tmp" "$dst"
	fi
    fi

done

# Last read failed. This is normal. Don't exit with its error code:
exit 0