# IOS_Conference_Planner_App

A conference planner app for iOS. This was a college project, hence the service is written in my native language.

**WARNING:** THIS PROJECT HAS NOT BEEN TESTED FOR SECURITY VULNERABILITIES! PLEASE DO NOT USE IT IN PRODUCTION ENVIRONMENTS! I BEAR NO RESPONSIBILITY IF YOUR DATA IS STOLEN OR YOUR SERVER IS HACKED!

## Features

- User Authentication: Users can sign up and log in securely.
- Anonymous Login: Users are not forced to log in or create an account (but they can't ask questions).
- Event Seeker: Users can see what events are planned for the current day and the next ones. They can also search for specific days and events.
- Questions: Users can ask questions about the event.
- Event Manager: Admins can add, modify, and delete events for specific days.
- Question Manager: Admins can delete or modify questions made by Users.
- User Management: Admins can elevate Users to Admin status. They can also add, delete Users and ban Users from asking questions.
- File Management: Admins can view files (they can be added using the Event Manager).
- Agenda: Admins can mark important dates.

## Requirements

- MySQL (or any other relational database)
- WebServer (I used XAMPP for testing purposes)
- iOS (For the App)

## Usage

1. Import the SQL DB File (`CREATE_DATABASE.sql`) to your Database.
2. Put the HTML and PHP Files (`BACKEND_FILES` Folder) in your webserver and change the IP address in `ContentView.swift` (located in the `FRONTEND_FILES` Folder) to the correct one.
3. Compile the App using the files in the `FRONTEND_FILES` Folder.
4. Enjoy!

## Final Word

This was a college project, as you can see, and it's also my first project made in Swift! Because of that, I'm still inexperienced with Swift (at least I could finally install MacOS on my Linux PC, and it was fun), and some things may not be fully optimized. Nonetheless, I'm proud of myself with this project.

**Final Mark (Given by my teacher):** 19/20

## License

This project is licensed under the MIT License.
