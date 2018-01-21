#!/bin/bash
OUTPUT="/dev/null"

if [[ $# -lt 1 ]]; then
    echo "USAGE:"
    echo "./make_compilers.sh compiler_path1 compiler_path2..."
	exit 1
fi

FAILS=0

for COMPILER in "$@"
do
	echo "Making compiler $COMPILER"
	time ( cd "$COMPILER" > "$OUTPUT" && make compiler > "$OUTPUT" )
	if [[ $? -ne 0 ]]; then
		echo "Can't make compiler:"
		echo "$COMPILER"
		((FAILS++))
	fi
done

echo "Total fails:"
echo "$FAILS/$#"

exit "$FAILS"
