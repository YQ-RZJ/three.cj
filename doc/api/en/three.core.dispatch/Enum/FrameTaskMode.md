# Enum
## enum FrameTaskMode
```cj
public enum FrameTaskMode
```
Frame task mode

### CONSUME
```cj
CONSUME
```
CONSUME: each run pops one parameter for execution, auto-ends when the parameter queue is empty

### LOOP
```cj
LOOP
```
LOOP: each run calls next() without consuming parameters; the callback decides when to stop this frame

### ONCE
```cj
ONCE
```
ONCE: executes the callback once then auto-unregisters; no parameter queue used

