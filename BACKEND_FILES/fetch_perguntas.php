<?php
$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "ProjetoP3";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$userID = $_GET['userID'] ?? null;
$articleID = $_GET['articleID'] ?? null;

$response = array();

if ($userID && $articleID) {
    $sql = $conn->prepare("SELECT P.PerguntaID, P.ArticleID, P.UserID, P.Pergunta, U.UserName 
          FROM Perguntas P
          JOIN Users U ON P.UserID = U.UserID
          JOIN Schedules S ON P.ArticleID = S.ArticleID
          WHERE S.ArticleID = ? AND P.UserID = ?");
    $sql->bind_param("ii", $articleID, $userID);

    if ($sql->execute()) {
        $result = $sql->get_result();

        $perguntas = array();

        while ($row = $result->fetch_assoc()) {
            $perguntas[] = array(
                'PerguntaID' => (int)$row['PerguntaID'],
                'ArticleID' => (int)$row['ArticleID'],
                'UserID' => (int)$row['UserID'],
                'Pergunta' => $row['Pergunta'],
                'UserName' => $row['UserName']
            );
        }

        $response['status'] = 'success';
        $response['perguntas'] = $perguntas;
    } else {
        $response['error'] = "Error fetching questions: " . $sql->error;
    }

    $sql->close();
} else {
    $response['error'] = "Invalid user or article ID.";
}

$conn->close();

header('Content-Type: application/json');
echo json_encode($response);
?>
