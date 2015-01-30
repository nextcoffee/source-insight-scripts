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
TMP_OUT_FILE="$2.tmp"
ANCHOR_FILE="$2.anchor"

# pick out markdown comments
sed -n "/^\/\*'/,/'\*\/$/{/^\/\*'/n; /'\*\/$/b; p}" $INPUT_FILE > $TMP_OUT_FILE

# gen anchor list
# sed -n '/^#\{1,6\}/{p}' $TMP_OUT_FILE | awk '{x=0; while(match($0 ,/^# */)){x=x+1; $0=substr($0,1+RLENGTH,length);} y=$0; gsub(/\W/, ""); p=""; while(x-1){p=p "  "; x=x-1} print p "* " "[" y "]" "(#"$0 ")"}' > $ANCHOR_FILE
sed -n '/^#\{1,6\}/{p}' $TMP_OUT_FILE | 
awk '
{
	x=0
	while(match($0 ,/^# */))
	{
		x=x+1
		$0=substr($0,1+RLENGTH,length)
	}

	y=$0
	gsub(/\W/, "")
	
	p=""
	while(x-1)
	{
		p=p "  "
		x=x-1
	}
	
	print p "* " "[" y "]" "(#"$0 ")"
}' > $ANCHOR_FILE

# setup anchor
awk '
{
	x=0
	while(match($0 ,/^# */))
	{
		x=x+1
		$0=substr($0,1+RLENGTH,length)
	}

	if(x==0)
	{
		print
		next
	}

	y=$0
	gsub(/\W/, "")

	anchor=$0

	print "<h" x " id=\"" anchor "\">" y "</h" x " >"
}' < $TMP_OUT_FILE > $OUTPUT_FILE

# copy anchor list to output
sed -i "1 r $ANCHOR_FILE" $OUTPUT_FILE

rm -rf $TMP_OUT_FILE
rm -rf $ANCHOR_FILE
