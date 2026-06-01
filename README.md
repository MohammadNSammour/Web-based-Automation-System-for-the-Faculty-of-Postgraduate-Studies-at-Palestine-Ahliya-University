# MPA — Graduate Studies Management (Palestine Ahliya University)

MPA is a lightweight PHP/MySQL multi-page application for managing graduate studies workflows.

This README is rebuilt to focus on the exact project startup order, the SQL files that must be imported, the login and form pages, and runtime requirements for the system.

---

## What this project includes

- `login.php` — login page and AJAX authentication endpoint
- `login.js` — login client logic, CAPTCHA refresh, and password visibility
- `form.php` — main form entry page
- `actionForm.php` — form interaction handler
- `getForm.php` — returns form definition/data via AJAX
- `saveForm.php` — saves form submissions
- `getStep.php` — multi-step form helper
- `notifications.php` — notifications page
- `getNotifications.php` — notifications AJAX endpoint
- `markNotifRead.php` — mark notification read
- `sendNotification.php` — send notifications
- `users.php` — user listing / admin page
- `db.php` — database connection configuration
- `thesis.php`, `serveThesis.php` — thesis-related pages
- SQL files in `Database Files/` for schema, forms, and test data

---

## Required environment

- Windows with XAMPP is recommended
- Apache + PHP + MySQL/MariaDB
- PHP 7.4 or newer (PHP 8 recommended)
- PHP extensions: `mysqli`, `mbstring`, `session`
- Browser for testing: Chrome, Firefox, Edge, or Safari

---

## Import order: first Database.sql, then SQL Forms, then Test data

This is the most important part.

1. Import `Database Files/Database.sql`
   - Creates the main database schema and core lookup tables.

2. Import `Database Files/Sql Forms/*.sql`
   - Adds the form definitions and form-specific tables.
   - Import these files in filename order, or use `All the forms.sql` if present.

3. Import `Database Files/Test.sql`
   - Loads test records used by the application.

If you import in the wrong order, you may get missing table or foreign key errors.

---

## Step-by-step setup (Windows + XAMPP)

1. Copy the project to XAMPP

- Place the folder in `C:\xampp\htdocs\MPA`

2. Start services

- Open XAMPP Control Panel
- Start `Apache` and `MySQL`

3. Create the database

### Option A — phpMyAdmin

- Open `http://localhost/phpmyadmin/`
- Create database `mpa_db` with utf8mb4 encoding
- Import `Database Files/Database.sql`
- Import each file from `Database Files/Sql Forms/` in order
- Import `Database Files/Test.sql`

### Option B — MySQL CLI

```powershell
cd "C:\xampp\mysql\bin"
mysql -u root -p
CREATE DATABASE mpa_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit
mysql -u root -p mpa_db < "C:\xampp\htdocs\MPA\Database Files\Database.sql"
```

Then import forms and test data:

```powershell
$files = Get-ChildItem "C:\xampp\htdocs\MPA\Database Files\Sql Forms\*.sql" | Sort-Object Name
foreach ($file in $files) {
  & "C:\xampp\mysql\bin\mysql.exe" -u root -p mpa_db < $file.FullName
}
& "C:\xampp\mysql\bin\mysql.exe" -u root -p mpa_db < "C:\xampp\htdocs\MPA\Database Files\Test.sql"
```

4. Configure `db.php`

Open `db.php` and set the database connection values for your environment.

Example:

```php
<?php
$db_host = '127.0.0.1';
$db_user = 'root';
$db_pass = '';
$db_name = 'mpa_db';

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
$conn->set_charset('utf8mb4');
if ($conn->connect_error) {
    die('DB connection error: ' . $conn->connect_error);
}
?>
```

5. Create or verify a login user

If your import does not include a working login, add one:

```sql
INSERT INTO Users (UserName, Password, FirstName, LastName, UserType)
VALUES ('teststudent','testpass','Test','Student','Student');
```

6. Open the login page

- Visit `http://localhost/MPA/login.php`
- Enter the test credentials and verify the application redirects after login

---

## Page categories

### Login and authentication

- `login.php`
- `login.js`
- `logout.php`

### Form interaction and user workflows

- `form.php`
- `actionForm.php`
- `getForm.php`
- `saveForm.php`
- `getStep.php`

### Notifications

- `notifications.php`
- `getNotifications.php`
- `markNotifRead.php`
- `sendNotification.php`
- `notifications.js`
- `notifications.css`

### Database and admin

- `db.php`
- `users.php`
- `thesis.php`
- `serveThesis.php`

---

## Runtime requirements and checks

- `mysqli` extension must be enabled
- `mbstring` extension must be enabled
- `session` support must be enabled
- `session.save_path` must be writable
- `upload_max_filesize` and `post_max_size` must support your largest uploads
- `max_input_vars` may need raising for very large forms
- `date.timezone` should be set in `php.ini`

Use a quick diagnostic file if needed:

```php
<?php
phpinfo();
```

Save this as `phpinfo.php` and open `http://localhost/MPA/phpinfo.php`.

---

## Verify the system works

1. Log in through `login.php`
2. Confirm redirect to `dashboard.php`
3. Open a form page and submit data
4. Verify the form record is saved in the database
5. Check that user rows exist in the `Users` table

### Verification queries

```sql
SELECT UserID, UserName, FirstName, LastName, UserType FROM Users LIMIT 50;
SELECT e.UserID, e.EmployeeNumber, er.Role
FROM Employees e
JOIN Employee_Roles er ON er.EmployeeNumber = e.EmployeeNumber
LIMIT 50;
SELECT * FROM Forms ORDER BY CreatedAt DESC LIMIT 10;
```

### Command-line login test

```bash
curl -i -X POST -F "username=teststudent" -F "password=testpass" -F "captcha=1234" http://localhost/MPA/login.php
```

---

## Notes

- The current password check is plaintext. Use `password_hash()` and `password_verify()` before production.
- Import `Database.sql` first, then `Sql Forms` files, then `Test.sql`.
- If form data is missing, inspect the browser Network tab and server logs.

---

## Next actions

If you want, I can also add:

- a Windows import script for all SQL files,
- `.env` support for `db.php`,
- or password hashing support in `login.php`.
