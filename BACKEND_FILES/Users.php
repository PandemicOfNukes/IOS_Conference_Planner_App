<?php

$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "ProjetoP3";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM Users";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $users = array();

    while ($row = $result->fetch_assoc()) {
        $row['UserID'] = intval($row['UserID']);
        $row['IsAdmin'] = boolval($row['IsAdmin']);
        $row['CanSpeak'] = boolval($row['CanSpeak']);
        $users[] = $row;
    }

    $response = array(
        'status' => 'success',
        'users' => $users
    );

    header('Content-Type: application/json');
    echo json_encode($response);
} else {
    $response = array('status' => 'error', 'message' => 'No users found');
    header('Content-Type: application/json');
    echo json_encode($response);
}

$conn->close();

?>
