# Swift-Example: Bartenders Best Friend

A modular iOS application built with SwiftUI designed to help users discover, create, and manage cocktail recipes. This project serves as a comprehensive example of modern Swift development, focusing on state management, custom UI components, and interactive user experiences.

## Features

- **Recipe Submission Engine**: A dynamic interface for users to input new drink recipes, including ingredient lists and preparation steps.
- **Ingredient Management**: Logic-driven systems for managing a digital "pantry" or liquor cabinet to see what drinks can be made with available stock.
- **Cocktail Dash**: An interactive, game-inspired module designed to test knowledge or provide a quick-selection experience for users.
- **Favorites & Persistence**: A centralized data store that allows users to save and organize their favorite recipes across different sections of the app.

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: Shared Data Store for local recipe management.

## UI & Design System

The application features a distinct, playful aesthetic characterized by:
- **High-Contrast Design**: Utilizing bold color palettes and shadow effects for depth.
- **Custom Typography**: Integration of unique font families including *Pacifico*, *Yellowtail*, and *Nunito* to create a vibrant brand identity.
- **Dynamic Splash Screens**: Engaging entry sequences designed using SwiftUI animations.

## Key Components

### Recipe Creation
The `RecipeView` utilizes specialized logic to handle ingredient inputs and ensure protocol conformance for recipe data objects.

### State Management
The project implements a shared environment object to maintain consistency between the "Explore" and "Favorites" tabs, ensuring real-time updates when a user saves a drink.

## Getting Started

1. **Clone the repo**:
   ```bash
   git clone [https://github.com/seth-huffman/Swift-Example.git](https://github.com/seth-huffman/Swift-Example.git)