# I/O files
DIR=$2
IN="$DIR/atp_in"
OUT1="$DIR/out1"
OUT2="$DIR/out2"
OUT="$DIR/out"
STATUS="$DIR/status"
ERROR="$DIR/error"
ERROR1="$DIR/error1"

# Running Z3 (4.0)
timeout $1 ./z3 -tptp DISPLAY_UNSAT_CORE=true ELIM_QUANTIFIERS=true PULL_NESTED_QUANTIFIERS=true \
-T:$1 $IN > $OUT1 2> $ERROR1
# Extracting status
grep "SZS status" $OUT1 > $STATUS 2> $ERROR
sed -i -e 's/^[ ]*SZS[ ]*status\(.*\)[ ]*for.*$/\1/' $STATUS 2> $ERROR
sed -i 's/ //g' $STATUS 2> $ERROR
# Extracting axioms
grep "^core" $OUT1 > $OUT2 2> $ERROR
sed -e 's/^core[(].*\[\(.*\)\][)].*/\1/' $OUT2 > $OUT1 2> $ERROR
tr "," "\n" < $OUT1 > $OUT2 2> $ERROR
tr -d " " < $OUT2 > $OUT 2> $ERROR
# Cleaning
rm -f $OUT1
rm -f $OUT2
