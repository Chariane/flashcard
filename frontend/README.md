# Flashcards

A small Flutter app for studying with flashcards. Each card has a question and an answer.

## Features

- Show the answer to a question
- Move to the previous or next card
- Add, edit, and delete cards
- Save your collection locally on the current browser or device
- Switch between light and dark mode; the selection is remembered on the device

## Run the app in Chrome

Install Flutter, open a terminal in the frontend folder, and run:

    flutter pub get
    flutter run -d web-server --web-port=7357

When Flutter prints the local URL, open it in your regular Chrome browser. Keep using the same URL and port. This mode avoids Flutter's temporary Chrome debug profile, so the browser's local storage is retained after the app closes. Do not use `-d chrome` for this persistence check, because Flutter launches that target with a temporary browser profile.

In VS Code, select **Flashcards Web (stockage Chrome persistant)** as the launch configuration. Open the URL printed in the Debug Console in your regular Chrome browser.

## Local data storage

Flashcards are saved automatically using Flutter SharedPreferences. In Chrome, they are stored in the regular browser profile for this app. Your cards remain available after closing and reopening the app when you use the `web-server` run instructions above.

This is local storage, not an online account or cloud backup. The collection does not sync to another browser or device, and clearing the browser's site data can delete it. Keep using the same app address (including port) and the same Chrome profile to see the same collection.
