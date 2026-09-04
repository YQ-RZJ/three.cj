# Function
## func intToCPointer\(T\)where T <: CType
```cj
public func intToCPointer < T >(int: T): CPointer < Unit > where T <: CType
```
Converts an integer type into a pointer

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>A temporary AutoFreePtr buffer holds and copies the integer value and is
released immediately; only the read-back pointer value is returned.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|int|T|The integer value (usually the integer representation of a pointer)|

Return: 

- The resulting CPointer<Unit>

## func makeAutoFree\(CPointer<T>\)where T <: CType
```cj
public func makeAutoFree < T >(p: CPointer < T >): AutoFreePtr < T > where T <: CType
```
Convenience factory for AutoFreePtr

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointer|

Return: 

- AutoFreePtr<T>

## func makeScopeGuard\(\(\)\->Unit\)
```cj
public func makeScopeGuard(callback:() -> Unit): ScopeGuard
```
Convenience factory for ScopeGuard

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Cleanup callback|

Return: 

- ScopeGuard

## func makeShared\(CPointer<T>\)where T <: CType
```cj
public func makeShared < T >(p: CPointer < T >): SharedPtr < T > where T <: CType
```
Convenience factory for SharedPtr (released via default LibC.free)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointer|

Return: 

- SharedPtr<T>

## func makeShared\(CPointer<T>,\(CPointer<T>\)\->Unit\)where T <: CType
```cj
public func makeShared < T >(p: CPointer < T >, deleter:(CPointer < T >) -> Unit): SharedPtr < T > where T <: CType
```
Convenience factory for SharedPtr (with a custom deleter)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointerdeleter Deleter function|
|deleter|(CPointer<T>)->Unit||

Return: 

- SharedPtr<T>

## func makeUnique\(CPointer<T>\)where T <: CType
```cj
public func makeUnique < T >(p: CPointer < T >): UniquePtr < T > where T <: CType
```
Convenience factory for UniquePtr (released via default LibC.free)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointer|

Return: 

- UniquePtr<T>

## func makeUnique\(CPointer<T>,\(CPointer<T>\)\->Unit\)where T <: CType
```cj
public func makeUnique < T >(p: CPointer < T >, deleter:(CPointer < T >) -> Unit): UniquePtr < T > where T <: CType
```
Convenience factory for UniquePtr (with a custom deleter)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointerdeleter Deleter function|
|deleter|(CPointer<T>)->Unit||

Return: 

- UniquePtr<T>

