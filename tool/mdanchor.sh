# check arguments
if [ ! -f "$1" ]; then
	echo "invalid file"
	exit 1
fi

MD_FILE="$1"
TMP_FILE="$1.tmp"

# append a blank line befor all blocks
echo > $TMP_FILE

# gen anchor list
# sed -n '/^#\{1,6\}/{p}' $MD_FILE | awk '{x=0; while(match($0 ,/^# */)){x=x+1; $0=substr($0,1+RLENGTH,length);} y=$0; gsub(/\W/, ""); p=""; while(x-1){p=p "  "; x=x-1} print p "* " "[" y "]" "(#"$0 ")"}' > $TMP_FILE
sed -n '/^#\{1,6\}/{p}' $MD_FILE | 
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
}' >> $TMP_FILE

# append a blank line befor another block
echo >> $TMP_FILE

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
}' < $MD_FILE >> $TMP_FILE

# clear up temporary files
rm -rf $MD_FILE
mv $TMP_FILE $MD_FILE
