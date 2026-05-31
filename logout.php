<?php
// logout.php  —  تسجيل الخروج
session_start();
session_destroy();
header('Location: login.php');
exit;
