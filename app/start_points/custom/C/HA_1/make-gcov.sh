#!/bin/bash 
#hidden_file

make CPPUTEST_USE_GCOV=Y  gcov

find . -name "*.cpp.gcov" | xargs cat
find . -name "*.c.gcov"| xargs cat
