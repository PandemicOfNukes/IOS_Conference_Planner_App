<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "ProjetoP3";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$data = json_decode(file_get_contents("php://input"), true);

$userID = $data['userID'] ?? null;
$articleID = $data['articleID'] ?? null;
$questionText = $data['question'] ?? null;

if (empty($userID) || empty($articleID) || empty($questionText)) {
    echo json_encode(array("success" => false, "error" => "Invalid data", "message" => "Missing required fields, $userID, $articleID, $questionText"));
    exit;
}

$sql = $conn->prepare("INSERT INTO Perguntas (ArticleID, UserID, Pergunta) VALUES (?, ?, ?)");
$sql->bind_param("iss", $articleID, $userID, $questionText);

$response = array();

if ($sql->execute()) {
    $response['success'] = true;
    $response['message'] = "Question submitted successfully!";
} else {
    $response['success'] = false;
    $response['error'] = "Error submitting question: " . $sql->error;
}

echo json_encode($response);

$conn->close();
?>
