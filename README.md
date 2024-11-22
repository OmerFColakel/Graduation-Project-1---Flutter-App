# ttstest

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


User Management Screen UI Specification
Overview
The User Management Screen allows administrators to manage users within the system. It provides functionalities for viewing, adding, and editing user details, as well as enabling or disabling user accounts. The screen contains a list of current users, and options to create new users or modify existing users.

Requirements
View Users: Display a list of users, including their username, email, and enabled status.
Add New User: Allow the creation of new users with specific details and roles.
Edit Existing User: Modify user details.
Enable/Disable Users: Toggle user account status.
Filter Disabled Users: Option to hide users who are disabled.
Components and Behavior
1. User List Table
Location: Left side of the page.
Components:
ID: Displays a unique identifier for each user.
User Name: Displays the username of the user.
Email: Displays the user's email address.
Enabled: A column that shows whether the user account is enabled or not (true/false).
Actions (Optional): This column could have icons or buttons for editing or deleting the user (depending on requirements, this can be added later).
Behavior:
Sorting: Users should be sortable by User Name, Email, or Enabled status by clicking on the column header.
Pagination: If there are many users, provide pagination at the bottom of the table to navigate between pages of users.
Hide Disabled Users Checkbox: If the user selects this checkbox, all users with the Enabled field set to false will be hidden from the table.
2. New User Form
Location: Right side of the page, beside the User List Table.
Components:
Username: A text input field for entering the username.
Display Name: A text input field for entering the user's display name.
Phone: A text input field for entering the user's phone number (optional).
Email: A text input field for entering the user's email address.
User Roles Dropdown: A dropdown menu to select the user’s role. Options:
Admin
SuperAdmin
Guest
Enabled Checkbox: A checkbox to set the user's status (enabled or disabled).
Behavior:
Default Role: The default role selected in the dropdown will be "Guest".
Field Validation: All fields (Username, Display Name, Email) must be validated. Email should follow the correct email format. The username must be unique.
Save User Button: A button labeled "Save User" will save the user information entered in the form.
If successful, a confirmation message should appear, and the form should reset.
If there is an error (e.g., invalid email, empty fields), a message should inform the user about the issue.
3. New User Button
Location: At the top left corner above the user list table.
Behavior:
When clicked, it opens the "New User Form" on the right side of the page.
The form should be empty, and the "Save User" button should be enabled.
4. Hide Disabled User Checkbox
Location: Near the top-left, just above the user list table.
Behavior:
When checked, the table will hide users whose Enabled status is false.
When unchecked, all users will be displayed, regardless of their enabled status.
5. Save User Button
Location: Bottom of the New User Form.
Behavior:
When clicked, it saves the details entered for the new user or updates an existing user’s details.
If successful, the new user is added to the table, and a success notification should be shown.
6. Table Filters and Search (Optional)
Location: Above the user list table.
Components:
A search box to filter users by username or email.
Behavior:
As the user types in the search box, the user list should dynamically update to show only matching users.
The search box should filter based on the User Name and Email columns.
UI Flow
Initial View:

The user sees the user list table with the existing users (AdminUser, TestUser).
The Hide Disabled User checkbox is unchecked by default, showing all users.
The New User button is visible for creating a new user.
Adding a New User:

The user clicks the New User button, and the New User Form appears.
The user fills out the form with required information (Username, Display Name, Email, etc.).
The user clicks the Save User button.
If valid, the new user is added to the list of users and displayed in the table.
If the form is invalid (e.g., missing email or username), an error message will be displayed.
Editing an Existing User:

The user can click on an edit button (if available in the UI) to open the form with pre-filled details of the selected user.
The user can modify the details and save the changes.
Hiding Disabled Users:

If the user checks the Hide Disabled User checkbox, users with Enabled: false will be hidden from the table.
Expected Behavior
Responsive Design: The layout should adapt to different screen sizes. On smaller screens, the user list table and form may stack vertically, with the form below the user list.
Error Handling: Provide error messages for invalid inputs in the form, such as invalid email format or duplicate usernames.
Success/Failure Notifications: Display notifications when a user is successfully added or when an error occurs.
Conclusion
This UI specification outlines the key components and behaviors needed for the user management screen, providing clarity for developers to implement the features efficiently. The focus should be on usability, simplicity, and clear interactions.
