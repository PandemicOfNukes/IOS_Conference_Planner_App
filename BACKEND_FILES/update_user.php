<?php

$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "ProjetoP3";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$data = json_decode(file_get_contents("php://input"), true);

if ($data && isset($data['UserID'])) {
    $userID = intval($data['UserID']);
    $username = mysqli_real_escape_string($conn, $data['Username']);
    $isAdmin = isset($data['IsAdmin']) ? ($data['IsAdmin'] ? 1 : 0) : 0;
    $canSpeak = isset($data['CanSpeak']) ? ($data['CanSpeak'] ? 1 : 0) : 1;

    $sql = "UPDATE Users SET Username='$username', IsAdmin=$isAdmin, CanSpeak=$canSpeak WHERE UserID=$userID";
    error_log("SQL Query: " . $sql);


    if ($conn->query($sql) === TRUE) {
        $response = array('status' => 'success', 'message' => 'User updated successfully');
    } else {
        $response = array('status' => 'error', 'message' => 'Error updating user: ' . $conn->error);
    }
} else {
    $response = array('status' => 'error', 'message' => 'Invalid data received');
}

header('Content-Type: application/json');
echo json_encode($response);

$conn->close();

?>
