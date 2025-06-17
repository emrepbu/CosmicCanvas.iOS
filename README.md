# Cosmic Daily

An iOS app that brings NASA's Astronomy Picture of the Day to your iPhone and iPad. Discover stunning images of our universe with detailed explanations from NASA astronomers.

<img src="https://github.com/user-attachments/assets/bab85264-c563-4aab-b89e-ddfda73ea096" width="300" alt="CosmicCanvas.Logo"/>

## Features

### Core Features
- Daily astronomy pictures from NASA
- Beautiful native iOS design
- Dark mode support
- Offline support with smart caching
- Pull to refresh

### Image Features
- Full-screen image viewer
- Pinch to zoom
- High-resolution image support
- Video content support

### iPad Features
- Split-view layout
- In-place zoom gestures
- Optimized for all iPad sizes

## Requirements

- iOS 26.0+
- Xcode 26.0+
- Swift 6.0+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/CosmicCanvas.git
```

2. Open in Xcode:
```bash
cd CosmicCanvas
open CosmicCanvas.xcodeproj
```

3. Build and run (⌘R)

## NASA API Key

The app includes a demo API key. For unlimited requests:

1. Get your free key at [api.nasa.gov](https://api.nasa.gov)
2. Open Settings in the app
3. Enter your API key

## Project Structure

```
CosmicCanvas/
├── Models/          # Data models
├── Services/        # API and cache services  
├── ViewModels/      # Business logic
├── Views/           # SwiftUI views
└── Components/      # Reusable components
```

## Technologies

- **SwiftUI** - Modern declarative UI
- **MVVM** - Clean architecture pattern
- **Async/Await** - Modern concurrency
- **NASA APOD API** - Space imagery source
