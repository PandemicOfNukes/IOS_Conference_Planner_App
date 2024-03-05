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

$query = "DELETE FROM Perguntas WHERE PerguntaID = $perguntaID";

if ($connection->query($query) === TRUE) {
    $response = array('status' => 'success', 'message' => 'Pergunta deleted successfully');
} else {
    $response = array('status' => 'error', 'message' => 'Error deleting pergunta: ' . $connection->error);
}

header('Content-Type: application/json');
echo json_encode($response);

$connection->close();
?>
