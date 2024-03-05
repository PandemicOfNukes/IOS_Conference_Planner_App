<?php
$host = 'localhost';
$db = 'ProjetoP3';
$user = 'root';
$pass = '1234';

$connection = new mysqli($host, $user, $pass, $db);

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

$query = "SELECT P.PerguntaID, P.ArticleID, P.UserID, P.Pergunta, U.UserName 
            FROM Perguntas P
            JOIN Users U ON P.UserID = U.UserID";
$result = $connection->query($query);

if (!$result) {
    die("Query failed: " . $connection->error);
}

$perguntas = array();
while ($row = $result->fetch_assoc()) {
    $row['PerguntaID'] = (int)$row['PerguntaID'];
    $row['ArticleID'] = (int)$row['ArticleID'];
    $row['UserID'] = (int)$row['UserID'];
    $perguntas[] = $row;
}

$response = array(
    'status' => 'success',
    'perguntas' => $perguntas
);

header('Content-Type: application/json');
echo json_encode($response);

$connection->close();
?>
