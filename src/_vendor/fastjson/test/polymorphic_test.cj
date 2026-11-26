/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

protected package three._vendor.fastjson.test

import std.unittest.*
import std.unittest.testmacro.*
import three._vendor.fastjson.*
import three._vendor.fastjson.macros.*

// 多态根：polymorphic = true，fromJson 按 "kind" 字段分发
@JsonAdapter[polymorphic = true]
public open class PolyAnimal {
    public var name: String = ""
}

@JsonAdapter[polymorphic = true ; withSuperClass = PolyAnimal]
public class PolyDog <: PolyAnimal {
    public var bark: String = ""
}

@JsonAdapter[polymorphic = true ; withSuperClass = PolyAnimal]
public class PolyCat <: PolyAnimal {
    public var mew: Int64 = 0
}

// 子类层级中间类
@JsonAdapter[polymorphic = true ; withSuperClass = PolyAnimal]
public open class PolyBird <: PolyAnimal {
    public var wing: Int64 = 0
}

@JsonAdapter[polymorphic = true ; withSuperClass = PolyBird]
public class PolyParrot <: PolyBird {
    public var words: String = ""
}

@Test
func Test_Polymorphic_KindProp() {
    let dog = PolyDog()
    dog.name = "Rex"
    dog.bark = "woof"
    // kind prop 自动生成，虚分发返回实际类名
    @Assert(dog.kind, "PolyDog")
    let animal: PolyAnimal = dog
    @Assert(animal.kind, "PolyDog")
    let bird = PolyBird()
    @Assert(bird.kind, "PolyBird")
    let parrot = PolyParrot()
    @Assert(parrot.kind, "PolyParrot")
}

@Test
func Test_Polymorphic_ToJsonContainsKind() {
    let cat = PolyCat()
    cat.name = "Tom"
    cat.mew = 3
    let json = cat.toJson()
    // kind 始终是第一个字段
    @Assert(json.startsWith(#"{"kind":"PolyCat""#), true)
}

@Test
func Test_Polymorphic_DispatchFromRoot() {
    PolyAnimal.ensureJsonRegistered()
    PolyDog.ensureJsonRegistered()
    PolyCat.ensureJsonRegistered()
    PolyBird.ensureJsonRegistered()
    PolyParrot.ensureJsonRegistered()

    let dog = PolyDog()
    dog.name = "Rex"
    dog.bark = "woof"
    let json = dog.toJson()

    // 以根类型反序列化，应分发回具体子类
    let restored = PolyAnimal.fromJson(json)
    match (restored) {
        case d: PolyDog =>
            @Assert(d.name, "Rex")
            @Assert(d.bark, "woof")
        case _ =>
            @Assert(true, false)
    }
}

@Test
func Test_Polymorphic_DispatchNestedSubclass() {
    PolyAnimal.ensureJsonRegistered()
    PolyParrot.ensureJsonRegistered()
    PolyBird.ensureJsonRegistered()

    let parrot = PolyParrot()
    parrot.name = "Polly"
    parrot.wing = 2
    parrot.words = "hello"
    let json = parrot.toJson()

    let restored = PolyAnimal.fromJson(json)
    match (restored) {
        case p: PolyParrot =>
            @Assert(p.name, "Polly")
            @Assert(p.wing, 2)
            @Assert(p.words, "hello")
        case _ =>
            @Assert(true, false)
    }
}

@Test
func Test_Polymorphic_UnknownKindFallback() {
    PolyAnimal.ensureJsonRegistered()
    // 无 kind 字段的 JSON（旧格式）回退为根类型读取
    let restored = PolyAnimal.fromJson(#"{"name":"Old"}"#)
    @Assert(restored.name, "Old")
    match (restored) {
        case _: PolyDog => @Assert(true, false)
        case _: PolyAnimal => ()
    }
}

@Test
func Test_Polymorphic_ConcreteFromJson() {
    // 直接以子类类型反序列化（kind 字段被消费丢弃）
    let cat = PolyCat.fromJson(#"{"kind":"PolyCat","name":"Tom","mew":9}"#)
    @Assert(cat.name, "Tom")
    @Assert(cat.mew, 9)
    @Assert(cat.kind, "PolyCat")
}

// ========== 多层继承链测试（4层，模拟 Object3D -> Camera -> PerspectiveCamera -> ArrayCamera）==========

@JsonAdapter[polymorphic = true]
public open class PolyVehicle {
    public var brand: String = ""
}

@JsonAdapter[polymorphic = true ; withSuperClass = PolyVehicle]
public open class PolyCar <: PolyVehicle {
    public var doors: Int64 = 4
}

@JsonAdapter[polymorphic = true ; withSuperClass = PolyCar]
public open class PolySportsCar <: PolyCar {
    public var topSpeed: Float64 = 200.0
}

// 叶子类：非 open
@JsonAdapter[polymorphic = true ; withSuperClass = PolySportsCar]
public class PolyFerrari <: PolySportsCar {
    public var model: String = ""
}

@Test
func Test_Polymorphic_FourLevelInheritance() {
    PolyVehicle.ensureJsonRegistered()
    PolyCar.ensureJsonRegistered()
    PolySportsCar.ensureJsonRegistered()
    PolyFerrari.ensureJsonRegistered()

    // 测试各层级 kind 值
    let vehicle = PolyVehicle()
    @Assert(vehicle.kind, "PolyVehicle")

    let car = PolyCar()
    @Assert(car.kind, "PolyCar")

    let sports = PolySportsCar()
    @Assert(sports.kind, "PolySportsCar")

    let ferrari = PolyFerrari()
    ferrari.brand = "Ferrari"
    ferrari.model = "F8"
    ferrari.topSpeed = 340.0
    @Assert(ferrari.kind, "PolyFerrari")

    // 测试多态反序列化：从根类分发到叶子类
    let json = ferrari.toJson()
    let restored = PolyVehicle.fromJson(json)
    match (restored) {
        case f: PolyFerrari =>
            @Assert(f.brand, "Ferrari")
            @Assert(f.model, "F8")
            @Assert(f.topSpeed, 340.0)
            @Assert(f.kind, "PolyFerrari")
        case _ =>
            @Assert(true, false)
    }
}

@Test
func Test_Polymorphic_MiddleClassDispatch() {
    PolyVehicle.ensureJsonRegistered()
    PolyCar.ensureJsonRegistered()
    PolySportsCar.ensureJsonRegistered()

    // 从中间层级反序列化
    let car = PolyCar()
    car.brand = "Toyota"
    car.doors = 2
    let json = car.toJson()

    let restored = PolyVehicle.fromJson(json)
    match (restored) {
        case c: PolyCar =>
            @Assert(c.brand, "Toyota")
            @Assert(c.doors, 2)
            @Assert(c.kind, "PolyCar")
        case _ =>
            @Assert(true, false)
    }
}

// ========== 包含复杂类型字段测试 ==========

// 自定义类型：不实现 JsonStreamDeserializable 接口
public class CustomComponent {
    public var value: Int64 = 0
    public init(v: Int64) {
        this.value = v
    }
}

// 包含 @JsonIgnore 字段的多态类
@JsonAdapter[polymorphic = true]
public open class PolyEntity {
    public var id: Int64 = 0
    @JsonIgnore
    public var component: CustomComponent = CustomComponent(0)
}

@JsonAdapter[polymorphic = true ; withSuperClass = PolyEntity]
public class PolyPlayer <: PolyEntity {
    public var playerName: String = ""
}

@Test
func Test_Polymorphic_WithJsonIgnoreField() {
    PolyEntity.ensureJsonRegistered()
    PolyPlayer.ensureJsonRegistered()

    let player = PolyPlayer()
    player.id = 42
    player.playerName = "Alice"
    player.component = CustomComponent(999)

    let json = player.toJson()
    // @JsonIgnore 字段不应出现在 JSON 中
    @Assert(json.contains("component"), false)
    @Assert(json.contains("playerName"), true)

    // 反序列化
    let restored = PolyEntity.fromJson(json)
    match (restored) {
        case p: PolyPlayer =>
            @Assert(p.id, 42)
            @Assert(p.playerName, "Alice")
        case _ =>
            @Assert(true, false)
    }
}

// ========== 多个兄弟类分发测试 ==========

@Test
func Test_Polymorphic_SiblingClassDispatch() {
    PolyAnimal.ensureJsonRegistered()
    PolyDog.ensureJsonRegistered()
    PolyCat.ensureJsonRegistered()

    // 创建不同类型的实例
    let dog = PolyDog()
    dog.name = "Buddy"
    dog.bark = "woof"

    let cat = PolyCat()
    cat.name = "Whiskers"
    cat.mew = 5

    // 序列化
    let dogJson = dog.toJson()
    let catJson = cat.toJson()

    // 从根类反序列化，应正确分发到各自类型
    let restoredDog = PolyAnimal.fromJson(dogJson)
    let restoredCat = PolyAnimal.fromJson(catJson)

    match (restoredDog) {
        case d: PolyDog =>
            @Assert(d.name, "Buddy")
            @Assert(d.bark, "woof")
        case _ =>
            @Assert(true, false)
    }

    match (restoredCat) {
        case c: PolyCat =>
            @Assert(c.name, "Whiskers")
            @Assert(c.mew, 5)
        case _ =>
            @Assert(true, false)
    }
}

// ========== kind 字段为第一个字段的测试 ==========

@Test
func Test_Polymorphic_KindIsFirstField() {
    let dog = PolyDog()
    dog.name = "Rex"
    let json = dog.toJson()

    // kind 应该是第一个字段
    @Assert(json.startsWith(#"{"kind":"PolyDog""#), true)
}

// ========== 非 open 叶子类的 kind 覆盖测试 ==========

@Test
func Test_Polymorphic_NonOpenLeafKindOverride() {
    PolyAnimal.ensureJsonRegistered()
    PolyParrot.ensureJsonRegistered()

    let parrot = PolyParrot()
    parrot.name = "Polly"
    parrot.words = "Hello"

    // 验证非 open 子类的 kind 正确
    @Assert(parrot.kind, "PolyParrot")

    // 通过父类引用访问 kind
    let bird: PolyBird = parrot
    @Assert(bird.kind, "PolyParrot")

    let animal: PolyAnimal = parrot
    @Assert(animal.kind, "PolyParrot")
}
