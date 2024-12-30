# Dossier à traiter
$folderPath = "C:\Users\Bouhrara\Downloads"

# Fonction pour calculer le hash d'un fichier
function Get-FileHashValue {
    param (
        [string]$filePath
    )
    $hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
    $fileStream = [System.IO.File]::OpenRead($filePath)
    $hashBytes = $hashAlgorithm.ComputeHash($fileStream)
    $fileStream.Close()
    return [BitConverter]::ToString($hashBytes) -replace '-'
}

# Créer une table de hachage pour stocker les hachages des fichiers déjà traités
$hashTable = @{}

# Variables pour compter les fichiers analysés et les doublons supprimés
$fileCount = 0
$duplicateCount = 0

# Obtenir le chemin du répertoire où le script est exécuté
$currentDirectory = Get-Location

# Fichier log pour enregistrer les fichiers supprimés
$date = Get-Date -Format "yyyyMMdd"
$logFilePath = "$currentDirectory\deleted_files_log_$date.txt"

# Créer le fichier log et ajouter un en-tête
"Log des fichiers supprimes - $date" | Out-File -FilePath $logFilePath -Encoding UTF8
"---------------------------------------------------" | Out-File -FilePath $logFilePath -Append

# Obtenir tous les fichiers dans le dossier
$files = Get-ChildItem -Path $folderPath -File -Recurse

# Traiter chaque fichier
foreach ($file in $files) {
    $fileCount++

    # Calculer le hash du fichier
    $fileHash = Get-FileHashValue -filePath $file.FullName

    # Vérifier si le hash existe déjà dans la table de hachage
    if ($hashTable.ContainsKey($fileHash)) {
        # Si le hash existe déjà, supprimer le fichier en double
        $duplicateCount++
        Write-Host "Fichier en double trouve et supprime: $($file.FullName)"
        Remove-Item -Path $file.FullName -Force

        # Ajouter le fichier supprimé au fichier log
        $file.FullName | Out-File -FilePath $logFilePath -Append
    } else {
        # Si le hash est unique, l'ajouter à la table
        $hashTable[$fileHash] = $file.FullName
        Write-Host "Fichier unique trouve: $($file.FullName)"
    }
}

# Résumé à la fin de l'exécution
Write-Host "Traitement termine."
Write-Host "Nombre de fichiers analyses: $fileCount"
Write-Host "Nombre de doublons supprimes: $duplicateCount"
Write-Host "Les fichiers supprimes ont ete enregistres dans: $logFilePath"
