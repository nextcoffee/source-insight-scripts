# check arguments
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

# pick out markdown comments
sed -n "/^\/\*'/,/'\*\/$/{/^\/\*'/n; /'\*\/$/b; p}" $INPUT_FILE > $OUTPUT_FILE
