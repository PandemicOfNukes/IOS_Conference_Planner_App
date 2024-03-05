<?php

$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "ProjetoP3";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$userID = $_GET['userID']; 

$sql = "SELECT CanSpeak FROM Users WHERE UserID = $userID";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    $user['CanSpeak'] = boolval($user['CanSpeak']);

    $response = array(
        'status' => 'success',
        'canSpeak' => $user['CanSpeak']
    );

    header('Content-Type: application/json');
    echo json_encode($response);
} else {
    $response = array('status' => 'error', 'message' => 'User not found');
    header('Content-Type: application/json');
    echo json_encode($response);
}

$conn->close();

?>
