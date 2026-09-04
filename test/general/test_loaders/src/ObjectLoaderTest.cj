/**
 * @file ObjectLoaderTest
 * @brief test_loaders: ObjectLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.ObjectLoader 能力（对照 JS parse）：
 * - parse 场景 JSON：Group + Mesh 层级、材质/几何体字典解析
 * - parseTextures/parseMaterials 与 BufferGeometryLoader 联动
 */
package test_loaders

import std.unittest.*
import std.collection.*
import three.resource.loader.ObjectLoader
import three.scene.objects.Object3D
import three.scene.scenegraph.Group
import three.scene.entity.Mesh
import three.rendering.materials.MeshBasicMaterial

public class ObjectLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ObjectLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_scene(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_scene", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_parse_scene() {
        // 构造与 ObjectLoader JSON Object/Scene 格式一致的场景
        let loader = ObjectLoader()
        let json = HashMap<String, Any>()

        // geometries
        let geoData = HashMap<String, Any>()
        let attrs = HashMap<String, Any>()
        let posAttr = HashMap<String, Any>()
        posAttr.add("itemSize", Int64(3))
        posAttr.add("type", "Float32Array")
        posAttr.add("array", [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0])
        attrs.add("position", posAttr)
        let geoInner = HashMap<String, Any>()
        geoInner.add("attributes", attrs)
        let geo = HashMap<String, Any>()
        geo.add("uuid", "geo1")
        geo.add("type", "BufferGeometry")
        geo.add("data", geoInner)
        let geometries = Array<HashMap<String, Any>>(1, { _ => geo })
        json.add("geometries", geometries)

        // materials
        let mat = HashMap<String, Any>()
        mat.add("uuid", "mat1")
        mat.add("type", "MeshBasicMaterial")
        mat.add("color", Int64(0x00ff00))
        let materials = Array<HashMap<String, Any>>(1, { _ => mat })
        json.add("materials", materials)

        // object: Group with one Mesh child
        let meshObj = HashMap<String, Any>()
        meshObj.add("type", "Mesh")
        meshObj.add("uuid", "mesh1")
        meshObj.add("name", "box")
        meshObj.add("geometry", "geo1")
        meshObj.add("material", "mat1")
        let children = Array<HashMap<String, Any>>(1, { _ => meshObj })
        let groupObj = HashMap<String, Any>()
        groupObj.add("type", "Group")
        groupObj.add("uuid", "root1")
        groupObj.add("name", "root")
        groupObj.add("children", children)
        json.add("object", groupObj)

        // 对照 JS: parse(json, onLoad) — onLoad 回调拿到解析结果
        // 仓颉 lambda 不能捕获可变局部变量，用持有可变字段的辅助类承接结果
        let holder = ObjectHolder()
        loader.parse(json, { obj =>
            match (obj) {
                case o: Object3D => holder.obj = Some(o)
                case _ => ()
            }
        })

        match (holder.obj) {
            case None =>
                assertEqual("onLoad 被调用", "true", false, true)
                return
            case Some(parsed) =>
                assertEqual("解析出 Group", "true", parsed is Group, true)
                assertEqual("Group name == root", "true", parsed.name == "root", true)
                // 子对象 Mesh + 材质/几何体字典联动
                assertEqual("子对象数量", "true", parsed.children.size == 1, true)
                if (parsed.children.size == 1) {
                    let child = parsed.children[0]
                    assertEqual("子对象是 Mesh", "true", child is Mesh, true)
                    assertEqual("子对象 name == box", "true", child.name == "box", true)
                    match (child) {
                        case m: Mesh =>
                            match (m.material) {
                                case mb: MeshBasicMaterial =>
                                    assertEqual("材质 color 应用", "true", mb.color.getHex() == 0x00ff00, true)
                                case _ => assertEqual("材质类型", "true", false, true)
                            }
                        case _ => ()
                    }
                }
        }
    }
}

// 承接 onLoad 回调结果的辅助类（仓颉 lambda 需捕获引用类型）
public class ObjectHolder {
    public var obj: Option<Object3D> = None
    public init() {}
}
