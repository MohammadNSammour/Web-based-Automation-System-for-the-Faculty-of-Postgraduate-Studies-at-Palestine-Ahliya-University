# MPA - Graduate Studies Management (Palestine Ahliya University)

MPA is a lightweight PHP/MySQL multi-page application for managing graduate studies workflows: user login, role assignment, form submissions, notifications, and small admin utilities.

This README focuses on precise, step‑by‑step instructions to run the project correctly and to verify that form and user data are stored and handled properly.

---

## What this project does (short)

- Provides an AJAX login flow (login.php + login.js) with a session-backed CAPTCHA and role handling (students vs. employees).
- Stores users, employee roles, and submitted forms in MySQL (see Database Files/).

---

## Prerequisites (exact)

- Windows (recommended) or Linux/macOS
- XAMPP (Apache + PHP + MySQL/MariaDB) or any LAMP/WAMP stack
- PHP 7.4+ (PHP 8 recommended)
- PHP extensions: mysqli, mbstring, session
- Browser for testing (Chrome/Firefox/Edge)

---

## Exact Step-by-step Setup (Windows + XAMPP)

1) Install and start XAMPP

- Install XAMPP from https://www.apachefriends.org
- Start Apache and MySQL from XAMPP Control Panel.

2) Place project files

- Copy the project folder into C:\xampp\htdocs\MPA

3) Create and import database (recommended charset)

Option A — phpMyAdmin (GUI):

- Open http://localhost/phpmyadmin/ → New → create database mpa_db (utf8mb4)
- Import C:\xampp\htdocs\MPA\Database Files\Database.sql

Option B — CLI (precise commands):

```bash
cd "C:\xampp\mysql\bin"
mysql -u root -p
CREATE DATABASE mpa_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit
mysql -u root -p mpa_db < "C:\xampp\htdocs\MPA\Database Files\Database.sql"
```

4) Configure db.php

- Open db.php and set connection values. For development add strict mysqli reporting to surface SQL errors:

```php
<?php
$db_host = '127.0.0.1';
$db_user = 'root';
$db_pass = '';
$db_name = 'mpa_db';

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
$conn->set_charset('utf8mb4');
if ($conn->connect_error) die('DB connection error: '.$conn->connect_error);
?>
```

5) Create a test user (SQL snippet)

Run in phpMyAdmin SQL tab or MySQL CLI to create a known test user (adjust fields to match your schema):

```sql
INSERT INTO Users (UserName, Password, FirstName, LastName, UserType)
VALUES ('teststudent','testpass','Test','Student','Student');
```

Note: the current project compares passwords as plain text. See Security notes below for migrating to hashed passwords.

6) Open the app

- Visit http://localhost/MPA/login.php and log in with the test user above.

---

## How to verify data correctness (forms and users)

Follow these checks immediately after import and after a form submission to ensure integrity.

1) Verify users table

Run this query in phpMyAdmin or MySQL CLI:

```sql
SELECT UserID, UserName, FirstName, LastName, UserType FROM Users LIMIT 50;
```

Confirm that expected rows exist and that UserType values are as expected (Student or Employee).

2) Verify employee role mapping

```sql
SELECT e.UserID, e.EmployeeNumber, er.Role
FROM Employees e
JOIN Employee_Roles er ON er.EmployeeNumber = e.EmployeeNumber
LIMIT 50;
```

3) Verify a submitted form arrives in the DB

- Submit a form in the application UI, then run a query against the table that stores forms (replace Forms with actual table name):

```sql
SELECT * FROM Forms ORDER BY CreatedAt DESC LIMIT 10;
```

Check the relevant columns (user id, form fields, timestamps). If fields are empty or missing, inspect the server network request and the server-side handler.

4) Quick network-level test (simulate login)

Use curl to simulate the AJAX POST (adjust credentials):

```bash
curl -i -X POST -F "username=teststudent" -F "password=testpass" -F "captcha=1234" http://localhost/MPA/login.php
```

If you get a JSON response {"success":true} then server-side login accepted the test values.

If you get errors, enable PHP/SQL error reporting (see Troubleshooting).

---

## Recommended development / server settings (quick checklist)

- Enable mysqli strict reporting while developing: mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT) in db.php.
- Set connection charset to utf8mb4 and verify DB collation matches.
- Ensure session_start() is the first output in all scripts that rely on sessions.
- For dev only: enable display_errors = On and error_reporting = E_ALL in php.ini.
- Keep backups of the database before running migrations.

---

## Useful debugging tips (forms & user data)

- Browser DevTools → Network tab: inspect the POST request payload for form submissions and the JSON response.
- Server logs: C:\xampp\apache\logs\error.log (Windows).
- Add temporary logging inside server handlers (error_log or file logging) to capture incoming raw POST data for problematic forms.
- If using prepared statements (recommended), always bind and validate typed values.

Example: log incoming POST (temporary, remove in production):

```php
file_put_contents(__DIR__.'/tmp/post.log', print_r($_POST, true), FILE_APPEND);
```

---

## Security & data-integrity notes (must-do before production)

1) Password hashing

- Migrate passwords to PHP password_hash()/password_verify(). Example migration path:

  - Add migration script that reads each user password, if not hashed, replace with password_hash($plaintext, PASSWORD_DEFAULT).
  - Update login.php to use password_verify($entered, $storedHash).

2) Input validation & sanitization

- Enforce server-side validation for all form fields (types, lengths, required fields).
- Use prepared statements (already used) and explicit casts for numeric fields.

3) CSRF protection

- Add CSRF tokens to state-changing POST forms and verify them server-side.

4) Rate limiting

- Limit login attempts per IP or per account to reduce brute-force risk.

---

## Backups & migrations

- Backup DB daily (mysqldump):

```bash
mysqldump -u root -p mpa_db > mpa_db_$(date +%F).sql
```

- Keep a schema-only dump for migrations:

```bash
mysqldump -u root -p --no-data mpa_db > mpa_schema.sql
```

