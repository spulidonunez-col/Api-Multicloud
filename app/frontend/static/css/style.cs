* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: #f5f7fa;
    padding: 20px;
}

.container {
    max-width: 1000px;
    margin: 0 auto;
    background: white;
    border-radius: 12px;
    padding: 30px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

h1 { color: #2c3e50; font-size: 2rem; }
.subtitle { color: #7f8c8d; margin-bottom: 20px; }

.form-container {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 30px;
}

.form-container h2 { font-size: 1.2rem; margin-bottom: 10px; }

#itemForm {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

#itemForm input {
    flex: 1;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 1rem;
}

#itemForm button {
    padding: 10px 25px;
    background: #3498db;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-weight: bold;
}

#itemForm button:hover { background: #2980b9; }

.items-container h2 { font-size: 1.2rem; margin-bottom: 10px; }

table {
    width: 100%;
    border-collapse: collapse;
}

th {
    background: #34495e;
    color: white;
    padding: 12px;
    text-align: left;
}

td {
    padding: 12px;
    border-bottom: 1px solid #ecf0f1;
}

tr:hover { background: #f8f9fa; }

.actions {
    display: flex;
    gap: 8px;
}

.btn-edit {
    background: #f39c12;
    color: white;
    border: none;
    padding: 5px 12px;
    border-radius: 4px;
    cursor: pointer;
}

.btn-delete {
    background: #e74c3c;
    color: white;
    border: none;
    padding: 5px 12px;
    border-radius: 4px;
    cursor: pointer;
}

.btn-edit:hover { background: #e67e22; }
.btn-delete:hover { background: #c0392b; }

.empty {
    text-align: center;
    color: #95a5a6;
    padding: 20px;
}