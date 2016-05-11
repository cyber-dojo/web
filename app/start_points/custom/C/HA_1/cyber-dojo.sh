export CPPUTEST_HOME=$CYBERDOJO_HOME/cpputest
t0=$(date +%s%3N)
make
t1=$(date +%s%3N)
echo "Build time (ms) $(($t1 - $t0))"

