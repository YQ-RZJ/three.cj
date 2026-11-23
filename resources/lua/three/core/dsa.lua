-- three/core/dsa.lua —— three.core.dsa 绑定模块
--
-- 需引擎侧先安装 dsa 绑定：
--     LuaBindingFactory.installPackage(vm, "three.core.dsa")
--
-- 已绑定类：Bvh / SpatialHashGrid / FenwickTree / UnionFind / SimplexNoise /
-- BitArray / FlockConfig / Boid / Flock
-- （泛型容器类 LruCache / RingBuffer / Queue / Stack / LinkedList / BinaryHeap 暂不绑定）

return require("three").core.dsa