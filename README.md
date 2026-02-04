# librisys

A simple library management system built with Flutter and Firebase.

## Features

*   **User Authentication:**
    *   Email and password authentication (Login and Registration).
    *   Password reset functionality.
    *   Users can change their email address.
    *   Users can delete their account.
*   **Book Management:**
    *   View a list of your books on the home page.
    *   Add new books with details like name, author, price, ISBN, purchase date, quantity, and status.
    *   Edit existing book details.
    *   Delete books.
    *   Track the status of your books: "Want to Read", "Reading", or "Read".
*   **Search and Filter:**
    *   Search for books by name or author.
    *   See a running count of your total books.
*   **User Profile:**
    *   A profile page displaying the user's email address.

## Screenshots
<p align="center">
  <img src="https://github.com/user-attachments/assets/d06cb113-c975-48b8-8db0-c38a6db7905e" height="300" alt="Login">
  <img src="https://github.com/user-attachments/assets/976d0786-9ae2-44e7-9406-4c55fd0d9096" height="300" alt="Register">
  <img src="https://github.com/user-attachments/assets/61792d23-3d0c-4677-86c8-5bd3f6979582" height="300" alt="Book Add">
  <img src="https://github.com/user-attachments/assets/f18bd13c-0257-4218-b97f-8024c361775a" height="300" alt="Book List">
  <img src="https://github.com/user-attachments/assets/eb3c3092-b823-48d7-98ac-884737fde8c6" height="300" alt="Profile">
</p>

## Tech Stack

*   **Frontend:** Flutter
*   **Backend:** Firebase
    *   Firebase Authentication
    *   Cloud Firestore

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
*   A Firebase project.

### Installation

1.  Clone the repo:
    ```sh
    git clone https://github.com/your_username_/librisys.git
    ```
2.  Install packages:
    ```sh
    flutter pub get
    ```
3.  Set up Firebase:
    *   Create a Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/).
    *   Add an Android app to your Firebase project with the package name `com.wpalgo.librisys`.
    *   Download the `google-services.json` file and place it in the `android/app` directory.
    *   Add an iOS app to your Firebase project with the bundle ID `com.wpalgo.librisys`.
    *   Download the `GoogleService-Info.plist` file and place it in the `ios/Runner` directory.

4.  Run the app:
    ```sh
    flutter run
    ```

## Project Structure

```
librisys/
├── android
├── assets
├── build
├── ios
├── lib
│   ├── app
│   ├── constants
│   ├── controllers
│   ├── models
│   ├── pages
│   ├── utils
│   └── widgets
├── linux
├── macos
├── test
├── web
└── windows
```
