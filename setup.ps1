# SYNC CODIAL → SHAREPOINT M2R
# Decouverte automatique du schema Codial SQL Server
Write-Host "SYNC CODIAL M2R - Decouverte" -ForegroundColor Cyan

# Creer dossier de travail
New-Item -ItemType Directory -Force -Path "C:\M2R_Sync" | Out-Null

# Trouver toutes les bases SQL locales
Write-Host "[1/3] Recherche bases SQL..." -ForegroundColor Yellow
$dbs = @()
try { $dbs = sqlcmd -S localhost -Q "SELECT name FROM sys.databases WHERE name NOT IN ('master','tempdb','model','msdb')" -W -h-1 2>$null } catch {}
if (-not $dbs) { try { $dbs = sqlcmd -S ".\SQLEXPRESS" -Q "SELECT name FROM sys.databases WHERE name NOT IN ('master','tempdb','model','msdb')" -W -h-1 2>$null } catch {} }

Write-Host "Bases trouvees :"
$dbs | ForEach-Object { Write-Host "  · $_" }
$dbs | Out-File "C:\M2R_Sync\bases.txt"

# Pour chaque base, lister les tables
Write-Host "[2/3] Analyse des tables..." -ForegroundColor Yellow
foreach ($db in $dbs) {
    $db = $db.Trim()
    if ($db -and $db.Length -gt 1) {
        "=== BASE: $db ===" | Out-File "C:\M2R_Sync\schema.txt" -Append
        try {
            $tbls = sqlcmd -S localhost -d $db -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME" -W -h-1 2>$null
            $tbls | Out-File "C:\M2R_Sync\schema.txt" -Append
        } catch {
            try {
                $tbls = sqlcmd -S ".\SQLEXPRESS" -d $db -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME" -W -h-1 2>$null
                $tbls | Out-File "C:\M2R_Sync\schema.txt" -Append
            } catch { "Erreur acces $db" | Out-File "C:\M2R_Sync\schema.txt" -Append }
        }
        "" | Out-File "C:\M2R_Sync\schema.txt" -Append
    }
}

Write-Host "[3/3] Ouverture du schema..." -ForegroundColor Yellow
notepad "C:\M2R_Sync\schema.txt"
Write-Host "COPIEZ le contenu du Notepad dans le chat Claude !" -ForegroundColor Green