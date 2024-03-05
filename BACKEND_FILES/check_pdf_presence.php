<?php
header('Content-Type: application/json');

if (isset($_GET['articleID'])) {
    $articleID = $_GET['articleID'];

    // Connect to your database
    $servername = "localhost";
    $username = "root";
    $password = "1234";
    $dbname = "ProjetoP3";

    $conn = new mysqli($servername, $username, $password, $dbname);

    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $checkPDFQuery = "SELECT PDF FROM Articles WHERE ArticleID = $articleID";
    $result = $conn->query($checkPDFQuery);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $pdfName = $row['PDF'];
        $pdfPresent = !empty($pdfName);
    } else {
        $pdfName = null;
        $pdfPresent = false;
    }

    $conn->close();
    
    echo json_encode(['pdfPresent' => $pdfPresent, 'pdfName' => $pdfName]);
} else {
    echo json_encode(['pdfPresent' => false, 'pdfName' => null]);
}
?>
