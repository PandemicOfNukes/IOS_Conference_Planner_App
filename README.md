# IOS_Conference_Planner_App
A conference planner app for IOS. This was a college project due to this the service is written in my native language.

**WARNING**:THIS PROJECT HAS NOT BEEN TESTED FOR SECURITY VULNERABILITIES! PLEASE DO NOT USE IT IN PRODUCTION ENVIRONMENTS! I BEAR NO RESPONSIBILITY IF YOUR DATA IS STOLEN OR YOUR SERVER IS HACKED!

## Features

- User Authentication: Users can sign up and log in securely.
- Anonymous Login: Users are not forced to login or create an account (but they can't ask questions).
- Event Seeker: Users can see what events are planned for that day and the next ones. They can also search for days and events.
- Questions: Users can ask questions about the event.
- Event Manager: Admins can add, modify and delete events to a specific day.
- Question Manager: Admins can delete or modify questions made by Users.
- User Management: Admins can elevate Users to Admin they also can add, delete Users and they also can ban Users from asking questions.
- File Management; Admins can view what files (They can be added on the Event Manager
- Agenda: Admins can mark important dates.

## Requirements
1. MySQL (or any other relational database)
2. WebServer (I used XAMPP for testing purposes)
3. IOS (For the APP)

## Usage
1. Import the SQL DB File to your Database (CREATE_DATABASE.sql)
2. Put the HTML and PHP Files (BACKEND_FILES Folder) in your webserver and change the IP address in ContentView.swift (located in the FRONTEND_FILES Folder) to the right one
3. Compile the App using the files in FRONTEND_FILES Folder
4. Enjoy!

## Final Word
This was a college project, as you can see and its also my first project made in swift! Because of that im still inexperienced with swift (at least I could finally install MacOS in my Linux PC and it was fun) and somethings may not be fully optimizied. Nonetheless, Im proud with myself with this project.

**Final Mark (Given by my teacher):** 19/20

## License
This project is licensed under the MIT License.
