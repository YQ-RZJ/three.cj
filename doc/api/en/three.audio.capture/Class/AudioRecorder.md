# Class
## class AudioRecorder
```cj
public class AudioRecorder
```
Microphone audio recorder wrapping the ALC capture extension

### func close\(\)
```cj
public func close(): Unit
```
Closes the capture device and releases resources

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to alcCaptureCloseDevice(device).</p>

### func getAvailableSamples\(\)
```cj
public func getAvailableSamples(): Int32
```
Returns the number of sample frames currently available to read

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to alcGetIntegerv(device, ALC_CAPTURE_SAMPLES, 1, &n).</p>

Return: 

- Number of available frames (0 = no data yet)

### func getCaptureDevice\(\)
```cj
public func getCaptureDevice(): CPointer < Unit >
```
Returns the capture device handle

Return: 

- The ALC capture device handle

### func init\(\)
```cj
public init()
```


### func open\(UInt32,UInt32,Int32\)
```cj
public func open(frequency: UInt32, channels: UInt32, bufferSize!: Int32 = 8192): Bool
```
Opens the default capture device (microphone)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to alcCaptureOpenDevice(NULL, frequency, format, buffersize), executed on the audio thread.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|frequency|UInt32|Sample rate in Hz (e.g. 44100 / 48000)channels Channel count (1 = mono / 2 = stereo)bufferSize Internal buffer size in frames (recommended >= 4096)|
|channels|UInt32||
|bufferSize|Int32||

Return: 

- Whether the device was opened successfully

### func readSamples\(CPointer<UInt8>,Int32\)
```cj
public func readSamples(buffer: CPointer < UInt8 >, samples: Int32): Int32
```
Reads captured PCM data

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to alcCaptureSamples(device, buffer, samples); the data is 16-bit
interleaved PCM.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|CPointer<UInt8>|Target buffer (caller-allocated, size must be >= samples × channels × 2 bytes)samples Number of sample frames to read (<= getAvailableSamples())|
|samples|Int32||

Return: 

- Number of bytes actually read (samples × channels × 2)

### func start\(\)
```cj
public func start(): Bool
```
Starts capturing

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to alcCaptureStart(device).</p>

Return: 

- Whether capture has started (device opened)

### func stop\(\)
```cj
public func stop(): Unit
```
Stops capturing (keeps captured data, which can still be read)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to alcCaptureStop(device).</p>

### prop channels: UInt32
```cj
public prop channels: UInt32
```
Channel count

### prop format: UInt32
```cj
public prop format: UInt32
```
Sample format (AL_FORMAT_MONO16 / AL_FORMAT_STEREO16)

### prop frequency: UInt32
```cj
public prop frequency: UInt32
```
Sample rate in Hz

### prop opened: Bool
```cj
public prop opened: Bool
```
Whether the capture device is opened

### prop recording: Bool
```cj
public prop recording: Bool
```
Whether capturing is in progress

