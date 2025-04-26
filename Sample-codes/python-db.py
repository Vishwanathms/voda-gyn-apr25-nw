from flask import Flask, render_template_string
import pyodbc

app = Flask(__name__)

# Azure SQL Connection details
server = 'vish.database.windows.net'
database = 'Db01'
username = 'vishwaadmin'
password = 'Password123'

# Connection string (ODBC Driver 17/18 for SQL Server)
conn_str = f"""
DRIVER={{ODBC Driver 18 for SQL Server}};
SERVER={server};
DATABASE={database};
UID={username};
PWD={password};
Encrypt=yes;
TrustServerCertificate=yes;
Connection Timeout=30;
"""

@app.route('/')
def index():
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        cursor.execute("SELECT TOP 10 * FROM Employees")  # Replace with your table
        rows = cursor.fetchall()

        # Render as basic HTML table
        html = "<h2>Employee List</h2><table border='1'><tr>"
        for column in cursor.description:
            html += f"<th>{column[0]}</th>"
        html += "</tr>"
        for row in rows:
            html += "<tr>" + "".join(f"<td>{cell}</td>" for cell in row) + "</tr>"
        html += "</table>"
        return render_template_string(html)

    except Exception as e:
        return f"<h2>Database connection error:</h2><pre>{e}</pre>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
