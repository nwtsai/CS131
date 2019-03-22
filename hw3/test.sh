#!/bin/sh

# Compiling the main file
javac UnsafeMemory.java

# Echo mode is on
set -x

# Testing NULL
java UnsafeMemory Null 1 10000 6 5 6 3 0 3
java UnsafeMemory Null 2 10000 6 5 6 3 0 3
java UnsafeMemory Null 4 10000 6 5 6 3 0 3
java UnsafeMemory Null 8 10000 6 5 6 3 0 3
java UnsafeMemory Null 16 10000 6 5 6 3 0 3

java UnsafeMemory Null 1 100000 6 5 6 3 0 3
java UnsafeMemory Null 2 100000 6 5 6 3 0 3
java UnsafeMemory Null 4 100000 6 5 6 3 0 3
java UnsafeMemory Null 8 100000 6 5 6 3 0 3
java UnsafeMemory Null 16 100000 6 5 6 3 0 3

java UnsafeMemory Null 1 1000000 6 5 6 3 0 3
java UnsafeMemory Null 2 1000000 6 5 6 3 0 3
java UnsafeMemory Null 4 1000000 6 5 6 3 0 3
java UnsafeMemory Null 8 1000000 6 5 6 3 0 3
java UnsafeMemory Null 16 1000000 6 5 6 3 0 3

# Testing Synchronized
java UnsafeMemory Synchronized 1 10000 6 5 6 3 0 3
java UnsafeMemory Synchronized 2 10000 6 5 6 3 0 3
java UnsafeMemory Synchronized 4 10000 6 5 6 3 0 3
java UnsafeMemory Synchronized 8 10000 6 5 6 3 0 3
java UnsafeMemory Synchronized 16 10000 6 5 6 3 0 3

java UnsafeMemory Synchronized 1 100000 6 5 6 3 0 3
java UnsafeMemory Synchronized 2 100000 6 5 6 3 0 3
java UnsafeMemory Synchronized 4 100000 6 5 6 3 0 3
java UnsafeMemory Synchronized 8 100000 6 5 6 3 0 3
java UnsafeMemory Synchronized 16 100000 6 5 6 3 0 3

java UnsafeMemory Synchronized 1 1000000 6 5 6 3 0 3
java UnsafeMemory Synchronized 2 1000000 6 5 6 3 0 3
java UnsafeMemory Synchronized 4 1000000 6 5 6 3 0 3
java UnsafeMemory Synchronized 8 1000000 6 5 6 3 0 3
java UnsafeMemory Synchronized 16 1000000 6 5 6 3 0 3

# Testing Unsynchronized
java UnsafeMemory Unsynchronized 1 10000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 2 10000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 4 10000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 8 10000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 16 10000 6 5 6 3 0 3

java UnsafeMemory Unsynchronized 1 100000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 2 100000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 4 100000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 8 100000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 16 100000 6 5 6 3 0 3

java UnsafeMemory Unsynchronized 1 1000000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 2 1000000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 4 1000000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 8 1000000 6 5 6 3 0 3
java UnsafeMemory Unsynchronized 16 1000000 6 5 6 3 0 3

# Testing GetNSet
java UnsafeMemory GetNSet 1 10000 6 5 6 3 0 3
java UnsafeMemory GetNSet 2 10000 6 5 6 3 0 3
java UnsafeMemory GetNSet 4 10000 6 5 6 3 0 3
java UnsafeMemory GetNSet 8 10000 6 5 6 3 0 3
java UnsafeMemory GetNSet 16 10000 6 5 6 3 0 3

java UnsafeMemory GetNSet 1 100000 6 5 6 3 0 3
java UnsafeMemory GetNSet 2 100000 6 5 6 3 0 3
java UnsafeMemory GetNSet 4 100000 6 5 6 3 0 3
java UnsafeMemory GetNSet 8 100000 6 5 6 3 0 3
java UnsafeMemory GetNSet 16 100000 6 5 6 3 0 3

java UnsafeMemory GetNSet 1 1000000 6 5 6 3 0 3
java UnsafeMemory GetNSet 2 1000000 6 5 6 3 0 3
java UnsafeMemory GetNSet 4 1000000 6 5 6 3 0 3
java UnsafeMemory GetNSet 8 1000000 6 5 6 3 0 3
java UnsafeMemory GetNSet 16 1000000 6 5 6 3 0 3

# Testing BetterSafe
java UnsafeMemory BetterSafe 1 10000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 2 10000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 4 10000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 8 10000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 16 10000 6 5 6 3 0 3

java UnsafeMemory BetterSafe 1 100000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 2 100000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 4 100000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 8 100000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 16 100000 6 5 6 3 0 3

java UnsafeMemory BetterSafe 1 1000000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 2 1000000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 4 1000000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 8 1000000 6 5 6 3 0 3
java UnsafeMemory BetterSafe 16 1000000 6 5 6 3 0 3

# Echo mode is off
set +x
echo "Done!"
