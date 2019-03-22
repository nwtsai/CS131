/**
 * HOMEWORK 6
 */

fun everyNth(L: List<Any>, N: Int) : List<Any> {

	// Return empty list with edge case inputs
	if (L.size == 0 || N <= 0) {
		return emptyList()
	}

	// Filter every Nth starting from the (N-1)st element
	return L.filterIndexed {
		index, _ -> index % N == N - 1
	}
}

fun main() {
	val list0 = List(0) {x -> x + 1}
	val list1 = List(5) {x -> x + 1}
	val list2 = List(6) {x -> x + 1}
	val list3 = List(100) {x -> (x + 1) * 2.0}
	val list4 = listOf("hi", "my", "name", "is", "Nathan", "and", "I", "really",
		"like", "to", "eat", "popcorn", "chicken", "in", "the", "morning", "or",
		"at", "night", "when", "the", "stars", "shine", "the", "brightest")

	print("Test 0: ")
	val test0 = everyNth(list0, 5)
	val sol0 = List(0) {it}
	println(test0.equals(sol0) && test0.size == list0.size / 5)

	print("Test 1: ")
	val test1 = everyNth(list1, -1)
	val sol1 = List(0) {it}
	println(test1.equals(sol1))

	print("Test 2: ")
	val test2 = everyNth(list1, 0)
	val sol2 = List(0) {it}
	println(test2.equals(sol2))

	print("Test 3: ")
	val test3 = everyNth(list1, 100)
	val sol3 = List(0) {it}
	println(test3.equals(sol3) && test3.size == list1.size / 100)

	print("Test 4: ")
	val test4 = everyNth(list1, 2)
	val sol4 = listOf(2, 4)
	println(test4.equals(sol4) && test4.size == list1.size / 2)

	print("Test 5: ")
	val test5 = everyNth(list1, 3)
	val sol5 = listOf(3)
	println(test5.equals(sol5) && test5.size == list1.size / 3)

	print("Test 6: ")
	val test6 = everyNth(list1, 5)
	val sol6 = listOf(5)
	println(test6.equals(sol6) && test6.size == list1.size / 5)

	print("Test 7: ")
	val test7 = everyNth(list2, 3)
	val sol7 = listOf(3, 6)
	println(test7.equals(sol7) && test7.size == list2.size / 3)

	print("Test 8: ")
	val test8 = everyNth(list2, 4)
	val sol8 = listOf(4)
	println(test8.equals(sol8) && test8.size == list2.size / 4)

	print("Test 9: ")
	val test9 = everyNth(list3, 1)
	val sol9 = list3
	println(test9.equals(sol9) && test9.size == list3.size / 1)

	print("Test 10: ")
	val test10 = everyNth(list3, 10)
	val sol10 = listOf(20.0, 40.0, 60.0, 80.0, 100.0, 120.0, 140.0, 160.0,
		180.0, 200.0)
	println(test10.equals(sol10) && test10.size == list3.size / 10)

	print("Test 11: ")
	val test11 = everyNth(list3, 27)
	val sol11 = listOf(54.0, 108.0, 162.0)
	println(test11.equals(sol11) && test11.size == list3.size / 27)

	print("Test 12: ")
	val test12 = everyNth(list4, 3)
	val sol12 = listOf("name", "and", "like", "popcorn", "the", "at", "the",
		"the")
	println(test12.equals(sol12) && test12.size == list4.size / 3)

	print("Test 13: ")
	val test13 = everyNth(list4, 7)
	val sol13 = listOf("I", "in", "the")
	println(test13.equals(sol13) && test13.size == list4.size / 7)

	print("Test 14: ")
	val test14 = everyNth(list4, 12)
	val sol14 = listOf("popcorn", "the")
	println(test14.equals(sol14) && test14.size == list4.size / 12)

	print("Test 15: ")
	val test15 = everyNth(list4, 25)
	val sol15 = listOf("brightest")
	println(test15.equals(sol15) && test15.size == list4.size / 25)
}
