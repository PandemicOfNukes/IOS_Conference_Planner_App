<?php
$back = "http://localhost/Index.html";
if (isset($_POST['submit'])) {
    $articleID = $_POST['articleID'];

    $servername = "localhost";
    $username = "root";
    $password = "1234";
    $dbname = "ProjetoP3";

    $conn = new mysqli($servername, $username, $password, $dbname);

    if ($conn->connect_error) {
        echo "<a href='$back'>Voltar Atrás</a><br>";
        die("Conexão Falhou: " . $conn->connect_error);
    }

    $checkIDQuery = "SELECT * FROM Articles WHERE ArticleID = $articleID";
    $result = $conn->query($checkIDQuery);

    if ($result->num_rows == 0) {
        echo "<a href='$back'>Voltar Atrás</a><br>";
        die("Error: ArticleID does not exist.");
    }

    $pdfFileName = $_FILES['pdfFile']['name'];
    $targetFolder = 'PDF/';
    $targetPath = $targetFolder . $pdfFileName;
    move_uploaded_file($_FILES['pdfFile']['tmp_name'], $targetPath);

    $updateQuery = "UPDATE Articles SET PDF='$pdfFileName' WHERE ArticleID=$articleID";

    if ($conn->query($updateQuery) === TRUE) {
        echo "PDF updated successfully.";
        echo "<br>";
        echo "<a href='$back'>Voltar Atrás</a>";
    } else {
        echo "Error updating PDF: " . $conn->error;
        echo "<br>";
        echo "<a href='$back'>Voltar Atrás</a>";
    }

    $conn->close();
}
?>
