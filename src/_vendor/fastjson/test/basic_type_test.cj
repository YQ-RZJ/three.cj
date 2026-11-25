protected package three._vendor.fastjson.test

import std.unittest.*
import std.unittest.testmacro.*
import three._vendor.fastjson.*
import three._vendor.fastjson.macros.*
import std.collection.*
import std.convert.*

@Test
class BasicTypeTest {
    @TestCase
    func arrayListToJson() {
        let input = ArrayList<String>()
        input.add("123")
        input.add("456")
        input.add("789")
        @Assert(input.toJson(), #"["123","456","789"]"#)
    }

    @TestCase
    func arrayListFromJson() {
        const input = #"["123","456","789"]"#
        let b = ArrayList<String>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func hashMapToJson() {
        let input = HashMap<String, String>()
        input.add("key1", "value1")
        input.add("key2", "value2")
        input.add("key3", "value3")
        @Assert(input.toJson(), #"{"key1":"value1","key2":"value2","key3":"value3"}"#)
    }
    @TestCase
    func hashMapFromJson() {
        const input = #"{"key1":"value1","key2":"value2","key3":"value3"}"#
        let b = HashMap<String, String>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func stringToJson() {
        let input = "1234567890"
        @Assert(input.toJson(), #""1234567890""#)
    }
    @TestCase
    func stringFromJson() {
        const input = #""1234567890""#
        let b = String.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func boolToJson() {
        let input = true
        @Assert(input.toJson(), #"true"#)
    }
    @TestCase
    func boolFromJson() {
        const input = #"true"#
        let b = Bool.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func int64ToJson() {
        let input = 1234567890
        @Assert(input.toJson(), #"1234567890"#)
    }
    @TestCase
    func int64FromJson() {
        const input = #"1234567890"#
        let b = Int64.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func int32ToJson() {
        let input = 1234567890
        @Assert(input.toJson(), #"1234567890"#)
    }
    @TestCase
    func int32FromJson() {
        const input = #"1234567890"#
        let b = Int32.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func int16ToJson() {
        let input = 12345
        @Assert(input.toJson(), #"12345"#)
    }
    @TestCase
    func int16FromJson() {
        const input = #"12345"#
        let b = Int16.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func int8ToJson() {
        let input = 123
        @Assert(input.toJson(), #"123"#)
    }
    @TestCase
    func int8FromJson() {
        const input = #"123"#
        let b = Int8.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func arrayToJson() {
        let input = [1, 2, 3]
        @Assert(input.toJson(), #"[1,2,3]"#)
    }
    @TestCase
    func arrayFromJson() {
        const input = #"[1,2,3]"#
        let b = Array<Int64>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func hashSetToJson() {
        let input = HashSet<Int64>()
        input.add(1)
        input.add(2)
        input.add(3)
        @Assert(input.toJson(), #"[1,2,3]"#)
    }
    @TestCase
    func hashSetFromJson() {
        const input = #"[1,2,3]"#
        let b = HashSet<Int64>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func treeSetToJson() {
        let input = TreeSet<Int64>()
        input.add(1)
        input.add(2)
        input.add(3)
        @Assert(input.toJson(), #"[1,2,3]"#)
    }
    @TestCase
    func treeSetFromJson() {
        const input = #"[1,2,3]"#
        let b = TreeSet<Int64>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func treeMapToJson() {
        let input = TreeMap<String, Int64>()
        input.add("key1", 1)
        input.add("key2", 2)
        input.add("key3", 3)
        @Assert(input.toJson(), #"{"key1":1,"key2":2,"key3":3}"#)
    }
    @TestCase
    func treeMapFromJson() {
        const input = #"{"key1":1,"key2":2,"key3":3}"#
        let b = TreeMap<String, Int64>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func concurrentHashMapToJson() {
        let input = ConcurrentHashMap<String, Int64>()
        input.add("key1", 1)
        input.add("key2", 2)
        input.add("key3", 3)

        let input2 = ConcurrentHashMap<String, Int64>.fromJson(input.toJson())

        @Assert(input.size, input2.size)
        @Assert(input.get("key1").getOrThrow(), input2.get("key1").getOrThrow())
        @Assert(input.get("key2").getOrThrow(), input2.get("key2").getOrThrow())
        @Assert(input.get("key3").getOrThrow(), input2.get("key3").getOrThrow())
    }
    @TestCase
    func linkedListToJson() {
        let input = LinkedList<String>(["123", "456", "789"])
        @Assert(input.toJson(), #"["123","456","789"]"#)
    }
    @TestCase
    func linkedListFromJson() {
        const input = #"["123","456","789"]"#
        let b = LinkedList<String>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func arrayQueueToJson() {
        let input = ArrayQueue<String>()
        input.add("123")
        input.add("456")
        input.add("789")
        @Assert(input.toJson(), #"["123","456","789"]"#)
    }
    @TestCase
    func arrayQueueFromJson() {
        const input = #"["123","456","789"]"#
        let b = ArrayQueue<String>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func arrayDequeToJson() {
        let input = ArrayDeque<String>()
        input.addLast("123")
        input.addLast("456")
        input.addLast("789")
        @Assert(input.toJson(), #"["123","456","789"]"#)
    }
    @TestCase
    func arrayDequeFromJson() {
        const input = #"["123","456","789"]"#
        let b = ArrayDeque<String>.fromJson(input)
        @Assert(b.toJson(), input)
    }
    @TestCase
    func arrayStackToJson() {
        let input = ArrayStack<String>()
        input.add("123")
        input.add("456")
        input.add("789")
        @Assert(input.toJson(), #"["123","456","789"]"#)
    }
    @TestCase
    func arrayStackFromJson() {
        const input = #"["123","456","789"]"#
        let b = ArrayStack<String>.fromJson(input)
        @Assert(b.toJson(), input)
    }


}