<?php
$host = 'localhost';
$db = 'ProjetoP3';
$user = 'root';
$pass = '1234';

$connection = new mysqli($host, $user, $pass, $db);

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

$data = json_decode(file_get_contents("php://input"), true);

$perguntaID = $data['PerguntaID'];
$articleID = $data['ArticleID'];
$userID = $data['UserID'];
$pergunta = $data['Pergunta'];

$query = "UPDATE Perguntas SET ArticleID = $articleID, UserID = $userID, Pergunta = '$pergunta' WHERE PerguntaID = $perguntaID";

if ($connection->query($query) === TRUE) {
    $response = array('status' => 'success', 'message' => 'Pergunta updated successfully');
} else {
    $response = array('status' => 'error', 'message' => 'Error updating pergunta: ' . $connection->error);
}

header('Content-Type: application/json');
echo json_encode($response);

$connection->close();
?>
