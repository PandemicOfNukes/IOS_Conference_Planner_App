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

    $deleteQuestionsSql = "DELETE FROM Perguntas WHERE UserID = $userID";
    if ($conn->query($deleteQuestionsSql) !== TRUE) {
        $response = array('status' => 'error', 'message' => 'Error deleting associated questions: ' . $conn->error);
        sendResponse($response);
    }

    $deleteUserSql = "DELETE FROM Users WHERE UserID = $userID";
    if ($conn->query($deleteUserSql) === TRUE) {
        $response = array('status' => 'success', 'message' => 'User and associated data deleted successfully');
    } else {
        $response = array('status' => 'error', 'message' => 'Error deleting user: ' . $conn->error);
    }
} else {
    $response = array('status' => 'error', 'message' => 'Invalid data received');
}

header('Content-Type: application/json');
echo json_encode($response);

$conn->close();

function sendResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
?>
