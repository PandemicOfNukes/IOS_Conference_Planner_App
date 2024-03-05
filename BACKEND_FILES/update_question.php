<?php
$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "ProjetoP3";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['questionID']) && isset($data['updatedQuestion'])) {
        $questionID = intval($data['questionID']);
        $updatedQuestion = htmlspecialchars($data['updatedQuestion']);

        $query = "UPDATE Perguntas SET Pergunta = ? WHERE PerguntaID = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("si", $updatedQuestion, $questionID);
        $stmt->execute();

        $success = $stmt->affected_rows > 0;

        echo json_encode(['success' => $success]);
    } else {
        echo json_encode(['success' => false, 'error' => 'Invalid data']);
    }
} else {
    echo json_encode(['success' => false, 'error' => 'Invalid request method']);
}

$conn->close();
?>
