if [ ! -f "$1" ]; then
	echo "invalid input file"
	exit 1
fi

if [ ! -n "$2" ]; then
	echo "no output file specified"
	exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"
ANCHOR_FILE="$2.anchor"

# pick out markdown comments
sed -n "/^\/\*'/,/'\*\/$/{/^\/\*'/n; /'\*\/$/b; p}" $INPUT_FILE > $OUTPUT_FILE

# auto gen anchor item
sed -n '/^#\{1,6\}/{p}' $OUTPUT_FILE > $ANCHOR_FILE

# h1 anchor
sed -i 's/^#  *\(.\+\)\W*$/* \[\1\](#\1)/' $ANCHOR_FILE

# h2 anchor
sed -i 's/^##  *\W*\(\w\+\).*/  * \[\1\](\1)/' $ANCHOR_FILE

# copy anchor list to output
sed -i "1 r $ANCHOR_FILE" $OUTPUT_FILE

# set anchor for h1
sed -i 's/^#  *\(.\+\)\W*$/<h1 id="\1">\1<\/h1>/' $OUTPUT_FILE

# clear anchor list

# set anchor for h2
sed -i 's/^##  *\W*\(\w\+\).*/<h2 id="\1">\1<\/h2>/' $OUTPUT_FILE

rm -rf $ANCHOR_FILE