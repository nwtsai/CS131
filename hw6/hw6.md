# Homework 6

## Report

### Consider 3 languages as a replacement to python
* OCaml
* Java
* Kotlin
* Project is about comparing languages for specifying a tensorflow model
* Each server in a server-herd application runs Tensorflow

### Tensorflow
* Machine learning framework
    * Specify model (target language)
    * Execute the model (optimized backend)
* Mainly targets python

### Simple Model

#### Specifying model in python
```
# Specifying model in python
a = tf.constant(3.0, dtype = tf.float32)
b = tf.constant(4.0)
total = a + b
print(total) # tensor("add", shape, type)
```
#### Executing the model
```
# Executing the model (which isn't run in python)
sess = tf.Session()
sess.run(total)
```

### Keras API Model

#### Code
```
# Specifying the model
model = tf.keras.Sequential[
    layers.Dense(64, activation = "relu", input_shape = (32, 1),
    layers.Dense(64, ...),
    layers.Dense(10, activation = "softmax")
]
model.compile(..., loss = "categorical crossentropy")
data = np.random.random((11000, 32))
labels = np.random.random((1000, 10))

# Executing the model
model.fit(data, labels, ...)
```

#### Observations
* We'd want to do a lot of this pre-processing in python when using tf

### Story for this Report
* Evaluating model has next to no overhead
* The bottleneck lies in:
    * tensorflow
        * Specifying model
        * Preprocessing data
    * server-herd architecture
        * python forces us to use a single thread
            * Other languages can offer multi-threaded solutions which could improve performance

#### Important Points
* Potential bottlenecks due to python
* Relevant language details for OCaml, Java, Kotlin
* How can we run on a client device as well?
    * For mobile users, we could have the computation run on their device to speed the model specification up
    * Which language allows you to target the right platform?
        * Google wrote a "tensorflow lite" that lets you evaluate tf models in Android (Java library) on the actual client's phone
* What features of a language are useful for this application?
    * Is multithreading possible?
    * Is it easier to not deal with mutating data?
    * Compilation vs. scripting
    * Dynamic vs. static type checking
        * All 3 languages are statically type checked
        * Python isn't
        * Can iterate really fast, but could run into bugs 
    * How easy and how safe is it to write a program in python?
    * Object-oriented programming
        * Objects might be costly
        * Creating a million objects
        * python vs. Java
            * Duck typing
            * Ease of developing with python objects

## Programing Assignment: Kotlin

### Details
* Cross platform
* Target: JavaScript, JVM (on Android), native (x86)
* Need to specify that we want to use a C library
* Multiple compilers
* Use libraries according to target
* Higher order functions
    * Map, reduce, fold
* Type inference (partial)
* "Smart" type casting
* Statically typed
* Interactive web-based app: www.play.kotlinlang.org

### Sample Code

```
fun main() {
    println("Hello, world!!!")

    // Creates a list of Ints where each value is double the index of each item
    var x = List(10) { x -> x * 2} // inferred type, x is the index of each element
    var xx : List<Int> = List(10) {xx -> xx * 2} // same as above with explicit type
    println("Int list: " + x)
    println("Identity of Int list: " + identity(x))
    println("Second Int list: " + xx)
    println("Sum of Int list: " + sumIntList(x))

    // Creates an immutable list
    var y = MutableList(1) {it} // it is the same as x -> x, each value takes on the index values
    y.add(1)
    println("Immutable list: " + y)

    // Immutable variable, val
    val a = 3
    println("Immutable variable: " + a)

    // Creates a list of Strings 
    var z = List(10) {z -> (z * 2).toString()}
    println("String list: " + z)

    // List interaction, n and m have same address so changing m modifies n too
    val m = MutableList(3) {it}
    m.add(5)
    val n : List<Int> = m
    println(n)
    m.add(6)
    println(n)
}

// Return the exact same list
fun identity(v : List<Any>) : List<Any> {
    return v
}

// Sum each item in the Int list
fun sumIntList(v: List<Int>) : Int {
    var sum = 0
    for (i in 0 until v.size) {
        sum += v[i]
    }
    return sum
}

fun sumIntList2(v: List<Int>) : Int {
    return v.reduce {
        acc,
        x -> acc + x
    }
}

fun filterGreaterThan10(v: List<Int>) : List<Int> {
    return v.filter {
        x -> x > 10
    }
}

fun filterIndex(v: List<Int>) : List<Int> {
    return v.filterIndexed {
        index,
        x -> x + index > 1
    }
}
```

### Makefile

```
check:
    kotlinc main.kt -include-runtime -d hello.jar
    java -jar hello.jar
```

* -include-runtime puts in the jar the whole kotlin runtime
* make check compiles and runs the file
