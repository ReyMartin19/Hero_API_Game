# 🦸‍♂️ Hero API Game - Flutter App

**Hero API Game** is a card-based battle game built with Flutter. Players face off against a bot using superhero cards fetched from a public API. Cards are compared by powerstats to determine the winner of each round, and dice mechanics add an element of chance for additional strategy.

---

## 🎮 Features

- 🔐 **Authentication**
  - Login system using Hero API credentials

- 🏠 **Homepage**
  - Displays a "Hero of the Day"

- 🃏 **Battle Comp**
  - 5-card decks for user and bot
  - Card vs card battles using powerstats
  - Dice mechanic triggered only by round winners
  - Cards removed after use to avoid repeats
  - Game ends when one deck runs out

- 🔍 **Search Page**
  - Search for heroes from the API
  - Bookmark favorite heroes

- 📌 **Bookmarks Page**
  - View and manage bookmarked heroes

- 🧠 **About Page**
  - Information about the game and developer

- 💾 **Persistence**
  - Local storage using SQLite for used cards
  - SharedPreferences for small data (e.g., API keys)

---

## 🛠️ Tech Stack

- **Flutter** (Dart)
- **SQLite** – local database for used cards
- **SharedPreferences** – lightweight local storage
- **Public Hero API** – data source for hero stats
- **Provider** – state management

---

## 🧩 How to Run

1. **Clone the Repository**

- git clone https://github.com/yourusername/hero-api-game.git
- cd hero-api-game
- code .
- flutter pub get
- flutter run
