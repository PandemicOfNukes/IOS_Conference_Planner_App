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

$NomeCompleto = $data['NomeCompleto'];
$Email = $data['Email'];
$username = $data['username'];
$password = $data['password'];

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

$sql = "INSERT INTO Users (NomeCompleto,Email,Username, Passwd, IsAdmin, CanSpeak) VALUES ('$NomeCompleto','$Email','$username', '$hashedPassword', 0, 1)";

if ($conn->query($sql) === TRUE) {
    echo json_encode(array("success" => true));
} else {
    echo json_encode(array("success" => false, "error" => $conn->error));
}

$conn->close();
?>
