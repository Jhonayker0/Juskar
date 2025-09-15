# Datos iniciales para Firestore

## Colección: categorias

Crea una nueva colección llamada "categorias" y agrega estos documentos:

### Documento 1 (ID: cupcakes)
```json
{
  "id": "cupcakes",
  "nombre": "Cupcakes",
  "color": 4294940928
}
```

### Documento 2 (ID: tortas)
```json
{
  "id": "tortas",
  "nombre": "Tortas",
  "color": 4294198070
}
```

### Documento 3 (ID: galletas)
```json
{
  "id": "galletas",
  "nombre": "Galletas",
  "color": 4293718464
}
```

### Documento 4 (ID: panes)
```json
{
  "id": "panes",
  "nombre": "Panes",
  "color": 4292465472
}
```

### Documento 5 (ID: postres)
```json
{
  "id": "postres",
  "nombre": "Postres",
  "color": 4291611852
}
```

## Instrucciones para agregar en Firestore:

1. Ve a tu consola de Firebase: https://console.firebase.google.com/
2. Selecciona tu proyecto
3. Ve a Firestore Database
4. Haz clic en "Iniciar colección"
5. Nombre de la colección: `categorias`
6. Para cada documento:
   - ID del documento: usa los IDs especificados arriba
   - Campos: agrega cada campo con su tipo correspondiente:
     - id: string
     - nombre: string  
     - color: number

## Notas sobre los colores:
Los números de color corresponden a:
- 4294940928 = Rojo
- 4294198070 = Naranja  
- 4293718464 = Amarillo
- 4292465472 = Verde
- 4291611852 = Azul

## Estructura simplificada:
✅ Sin campo "description" 
✅ Campo "nombre" en lugar de "name"
✅ Colección "categorias" en lugar de "categories"
