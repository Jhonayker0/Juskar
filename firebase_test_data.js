// Script para agregar categorías iniciales a Firestore
// Puedes usar este código en la consola de Firebase

// Categorías de ejemplo para la panadería
const categorias = [
  {
    id: 'cupcakes',
    nombre: 'Cupcakes',
    color: 4294940928, // Rojo
  },
  {
    id: 'tortas',
    nombre: 'Tortas',
    color: 4294198070, // Naranja
  },
  {
    id: 'galletas',
    nombre: 'Galletas',
    color: 4293718464, // Amarillo
  },
  {
    id: 'panes',
    nombre: 'Panes',
    color: 4292465472, // Verde
  },
  {
    id: 'postres',
    nombre: 'Postres',
    color: 4291611852, // Azul
  },
  {
    id: 'chocolates',
    nombre: 'Chocolates',
    color: 4289374890, // Púrpura
  }
];

// Para agregar las categorías usando la consola de Firebase:
/*
1. Ve a Firebase Console > Firestore Database
2. Crea la colección 'categorias' si no existe
3. Para cada categoría, crea un documento con:
   - ID del documento: el valor de 'id' (ej: 'cupcakes')
   - Campos:
     - nombre (string): ej. 'Cupcakes'
     - color (number): ej. 4294940928
*/

// O si prefieres usar código JavaScript en la consola del navegador:
/*
categorias.forEach(async (categoria) => {
  await db.collection('categorias').doc(categoria.id).set({
    nombre: categoria.nombre,
    color: categoria.color,
    createdAt: firebase.firestore.FieldValue.serverTimestamp(),
    updatedAt: firebase.firestore.FieldValue.serverTimestamp()
  });
});
*/
