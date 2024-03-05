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
$username = $data['username'];
$password = $data['password'];

$sql = $conn->prepare("SELECT * FROM Users WHERE Username = ? LIMIT 1");
$sql->bind_param("s", $username);
$sql->execute();

$result = $sql->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $storedPassword = $row['Passwd'];
    $userID = $row['UserID'];

    if (password_verify($password, $storedPassword)) {
        $isAdmin = $row['IsAdmin'];
        echo json_encode(array("success" => true, "isAdmin" => $isAdmin, "userID" => $userID, "message" => "Login successful"));
    } else {
        echo json_encode(array("success" => false, "error" => "Invalid credentials", "message" => "Password mismatch"));
    }
} else {
    echo json_encode(array("success" => false, "error" => "Invalid credentials", "message" => "User not found"));
}

$conn->close();
?>
