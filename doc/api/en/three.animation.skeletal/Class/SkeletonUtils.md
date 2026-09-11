# Class
## class SkeletonUtils
```cj
public class SkeletonUtils
```
Skeleton utility functions

### func findJointIndex\(SkeletonData,String\)
```cj
public static func findJointIndex(skeleton: SkeletonData, name: String): Int
```
Finds a joint index by name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|
|name|String|The joint name|

Return: 

- The joint index, or -1 if not found

### func getAncestors\(SkeletonData,Int\)
```cj
public static func getAncestors(skeleton: SkeletonData, jointIndex: Int): ArrayList < Int >
```
Returns the ancestor chain of a joint (from itself to the root, including itself)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|
|jointIndex|Int|The joint index|

Return: 

- The ancestor chain (from itself to the root)

### func getChildren\(SkeletonData,Int\)
```cj
public static func getChildren(skeleton: SkeletonData, jointIndex: Int): ArrayList < Int >
```
Returns the list of a joint's children

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|
|jointIndex|Int|The parent joint index|

Return: 

- The list of indices of the direct children

### func getJointDepth\(SkeletonData,Int\)
```cj
public static func getJointDepth(skeleton: SkeletonData, jointIndex: Int): Int
```
Returns the joint depth (distance to the root joint)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|
|jointIndex|Int|The joint index|

Return: 

- The depth value (the root joint is 0)

### func getLowestCommonAncestor\(SkeletonData,Int,Int\)
```cj
public static func getLowestCommonAncestor(skeleton: SkeletonData, jointA: Int, jointB: Int): Int
```
Returns the lowest common ancestor of two joints

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|
|jointA|Int|Joint A|
|jointB|Int|Joint B|

Return: 

- The lowest common ancestor index, or -1 if there is no common ancestor

### func getPathToJoint\(SkeletonData,Int\)
```cj
public static func getPathToJoint(skeleton: SkeletonData, jointIndex: Int): Array < Int >
```
Returns the path from the root to the specified joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|
|jointIndex|Int|The target joint index|

Return: 

- The path array (from the root to the target joint, including the target itself)

### func getRootJoints\(SkeletonData\)
```cj
public static func getRootJoints(skeleton: SkeletonData): ArrayList < Int >
```
Returns all root joints (joints with no parent)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|

Return: 

- The list of root joint indices

### func getStats\(SkeletonData\)
```cj
public static func getStats(skeleton: SkeletonData): String
```
Returns skeleton statistics

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|

Return: 

- A string description: joint count, maximum depth, root joint count

### func getSubtree\(SkeletonData,Int\)
```cj
public static func getSubtree(skeleton: SkeletonData, rootIndex: Int): Array < Int >
```
Returns all joint indices in the subtree (including itself)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|
|rootIndex|Int|The subtree root joint index|

Return: 

- The indices of all joints in the subtree (depth-first order)

### func isAncestor\(SkeletonData,Int,Int\)
```cj
public static func isAncestor(skeleton: SkeletonData, jointA: Int, jointB: Int): Bool
```
Checks whether jointA is an ancestor of jointB

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|SkeletonData|The skeleton|
|jointA|Int|The possible ancestor joint|
|jointB|Int|The possible descendant joint|

Return: 

- true if jointA is an ancestor of jointB (or jointA is jointB itself)

