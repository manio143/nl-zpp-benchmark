#!/bin/bash
NIANIO_COMPILER="mk_cache.exe"
NIANIO_OPTS="--deref --strict --c --O2 --profile"
C_COMPILER=gcc
C_OPTS="-std=c99 -O0 -ggdb -lm"
OUTPUT="/dev/null"
TMP="tmp"

if [[ $# -lt 2 ]]; then
    echo "USAGE:"
    echo "./benchmark.sh benchmark_folder compiler_path1 compiler_path2..."
	exit 1
fi

BENCHMARK=$(readlink -f $1)
if [[ $? -ne 0 ]]; then
	echo "Can't resolve benchmark path:"
	echo "$1"
	exit 1
fi

TMP=$(readlink -f $TMP)
if [[ $? -ne 0 ]]; then
	echo "Can't resolve tmp path:"
	exit 1
fi
mkdir "$TMP" > "$OUTPUT"
if [[ $? -ne 0 ]]; then
	echo "Can't make tmp folder:"
	exit 1
fi

shift

FAILS=0

for COMPILER in "$@"
do
	echo "Using compiler $COMPILER."
	echo "Compiling nianio to C..."
	time ( cd "$COMPILER" > "$OUTPUT" && ./$NIANIO_COMPILER nianio_lib "$BENCHMARK" --o "$TMP" $NIANIO_OPTS > "$OUTPUT" )
	if [[ $? -ne 0 ]]; then
		echo "Can't compile nianio to C."
		echo "$COMPILER"
		rm -rf $TMP/* > "$OUTPUT"
		((FAILS++))
		continue
	fi
	echo "Compiling C..."
	time ( cd "$COMPILER" > "$OUTPUT" && $C_COMPILER -o "$TMP"/main main_c.c "$TMP"/*.c native_lib_c/*.c -I"$TMP" -Inative_lib_c $C_OPTS > "$OUTPUT" )
	if [[ $? -ne 0 ]]; then
		echo "Can't compile C."
		echo "$COMPILER"
		rm -rf $TMP/* > "$OUTPUT"
		((FAILS++))
		continue
	fi
	echo "Running..."
	time $TMP/main > "$OUTPUT"
	if [[ $? -ne 0 ]]; then
		echo "Runtime error."
		echo "$COMPILER"
		((FAILS++))
		continue
	fi
	rm -rf $TMP/* > "$OUTPUT"
done
rm -rf "$TMP" > "$OUTPUT"
echo "Done. Fails:"
echo "$FAILS/$#"
exit "$FAILS"
