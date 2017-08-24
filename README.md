# General Connection Framework

Description...

## Why Use GCF?

- Never have to write URLSession code in your app again (cuts down on network code)
- No more JSON parsing
- Will be fully tested (no buggy network code)
- Easier/quicker API integration
- Less fragile (no string literal parameters for creating a request)
- Supports standard completion block pattern or Rx/observable pattern
- The client of the GCF owns the domain specific knowledge (actual url, parsed data models, etc), encouraging modular design

## Features

- Modular
- Highly configurable
- Flexible plugin architecture
- Swift Decodable support
- Robust test coverage (ongoing)
- Authentication support (propsed)
- Credential management (proposed)
- Request queueing (proposed)
- Retry logic (proposed)

## Dependencies

- [RxSwift]

## Requirements

- iOS 9.0+
- Xcode 9
- Swift 4
- [CocoaPods]

## Installation

 - TBD

## Usage

### Creating Routables

```swift
// some code
```

### Creating a GCF

### Creating a GCF Plugin

### Using the GCF in Your App


[RxSwift]: https://github.com/ReactiveX/RxSwift/
[CocoaPods]: https://github.com/CocoaPods/CocoaPods
