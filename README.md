# General Connection Framework

Description...

## Use Cases

- Authentication (plugins)
- Combining multiple dependent requests
- Request queueing
- Retry logic

## Why Use GCF?

- Never have to write URLSession code in your app again (cuts down on network code)
- Will be fully tested (no buggy network code)
- Easier/quicker API integration
- Less fragile (no string parameters for creating a request)
- Supports standard completion block pattern or rx/observable pattern
- The client of the GCF owns the domain specific knowledge (actual url, parsed data models, etc), encouraging modular design

## Usage

### Creating Routables

```swift
// some code
```

### Creating a GCF

### Creating a GCF Plugin

### Using the GCF in Your App
