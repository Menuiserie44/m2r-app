import pyodbc, requests, json, os
from datetime import datetime

HFSQL = "DRIVER={HFSQL};Server=SRV-M2R;Port=4900;Database=\\\\SRV-M2R\\CODIALSRV\\HFSQL\\BDD\\M2R;"
LOG = "C:\\M2R_Sync\\sync.log"
os.makedirs("C:\\M2R_Sync", exist_ok=True)

def log(msg):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{ts}] {msg}"
    print(line)
    open(LOG,"a",encoding="utf-8").write(line+"\n")

log("=== DEMARRAGE TEST CONNEXION HFSQL ===")
try:
    conn = pyodbc.connect(HFSQL, timeout=10)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM FP_M2RCHANTIER")
    cols = [d[0] for d in cursor.description]
    rows = cursor.fetchmany(3)
    log(f"OK! Colonnes: {cols}")
    for r in rows: log(str(r))
    conn.close()
except Exception as e:
    log(f"ERREUR: {e}")
    # Test avec chemin direct
    try:
        HFSQL2 = "DRIVER={HFSQL};Database=\\\\SRV-M2R\\CODIALSRV\\HFSQL\\BDD\\M2R;"
        conn2 = pyodbc.connect(HFSQL2, timeout=10)
        cursor2 = conn2.cursor()
        cursor2.execute("SELECT * FROM FP_M2RCHANTIER")
        cols2 = [d[0] for d in cursor2.description]
        log(f"OK methode2! Colonnes: {cols2}")
        conn2.close()
    except Exception as e2:
        log(f"ERREUR methode2: {e2}")
