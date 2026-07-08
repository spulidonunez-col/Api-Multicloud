const API_URL = '/api/items';

// Cargar items al iniciar
document.addEventListener('DOMContentLoaded', loadItems);

// Formulario
document.getElementById('itemForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = document.getElementById('name').value.trim();
    const description = document.getElementById('description').value.trim();
    
    if (!name) return alert('El nombre es obligatorio');
    
    const response = await fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, description })
    });
    
    if (response.ok) {
        document.getElementById('itemForm').reset();
        loadItems();
    }
});

// Cargar items
async function loadItems() {
    const response = await fetch(API_URL);
    const items = await response.json();
    const tbody = document.getElementById('itemsBody');
    
    if (items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="empty">No hay items</td></tr>';
        return;
    }
    
    tbody.innerHTML = items.map(item => `
        <tr>
            <td>${item.id}</td>
            <td><strong>${item.name}</strong></td>
            <td>${item.description || '-'}</td>
            <td>${new Date(item.created_at).toLocaleDateString()}</td>
            <td class="actions">
                <button class="btn-edit" onclick="editItem(${item.id})">✏️</button>
                <button class="btn-delete" onclick="deleteItem(${item.id})">🗑️</button>
            </td>
        </tr>
    `).join('');
}

// Eliminar item
async function deleteItem(id) {
    if (!confirm('¿Eliminar este item?')) return;
    await fetch(`${API_URL}/${id}`, { method: 'DELETE' });
    loadItems();
}

// Editar item
async function editItem(id) {
    const newName = prompt('Nuevo nombre:');
    if (!newName) return;
    const newDesc = prompt('Nueva descripción:') || '';
    
    await fetch(`${API_URL}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: newName, description: newDesc })
    });
    loadItems();
}