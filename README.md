# Juskar - Aplicación de Repostería 🧁

Una aplicación móvil para gestionar pedidos de repostería, desarrollada con Flutter.

## 📱 Funcionalidades

### Pantallas Principales
- **Home Page**: Visualización de pedidos con filtros y búsqueda
- **Create Order**: Creación de nuevos pedidos (próximamente)
- **Categories**: Gestión de categorías personalizables

### Características Implementadas
- ✅ Interfaz oscura moderna
- ✅ Lista de pedidos con datos mockup
- ✅ Categorías de colores personalizables
- ✅ Botón de completado/pendiente para cada pedido
- ✅ Navegación con bottom navigation bar
- ✅ Diseño responsive

## 🏗️ Estructura del Proyecto

```
lib/
├── models/
│   ├── category.dart          # Modelo de categoría
│   └── order.dart            # Modelo de pedido
├── screens/
│   ├── home_page.dart        # Pantalla principal
│   ├── create_order_page.dart # Crear pedido
│   ├── categories_page.dart   # Gestión de categorías
│   └── main_layout.dart      # Layout principal con navegación
├── widgets/
│   └── order_card.dart       # Widget de tarjeta de pedido
├── services/
│   └── mock_data_service.dart # Servicio de datos de prueba
├── utils/
│   └── app_theme.dart        # Tema y colores de la app
└── main.dart                 # Punto de entrada
```

## 📦 Modelos de Datos

### Pedido (Order)
- **Título**: Nombre del pedido
- **Descripción**: Detalles del pedido
- **Fecha**: Fecha de entrega
- **Categoría**: Categoría asignada (con color)
- **Cliente**: Nombre del cliente
- **Contacto**: Teléfono de contacto
- **Tamaño**: Tamaño del pedido
- **Leyenda**: Texto para el pastel/producto
- **Edad**: Edad del cumpleañero (si aplica)
- **Valor**: Precio total
- **Abono**: Cantidad abonada
- **Domicilio**: Dirección de entrega
- **Completado**: Estado del pedido (true/false)

### Categoría (Category)
- **ID**: Identificador único
- **Nombre**: Nombre de la categoría
- **Color**: Color asociado a la categoría

## 🎨 Tema Visual

### Paleta de Colores
- **Fondo**: `#1E1E1E` (Negro oscuro)
- **Tarjetas**: `#2A2A2A` (Gris oscuro)
- **Color Primario**: `#7C7BFF` (Púrpura)
- **Texto Principal**: Blanco
- **Texto Secundario**: `#B0B0B0` (Gris claro)

### Categorías por Color
- **No confirmado**: Azul púrpura
- **Cupcake**: Rojo
- **Pendiente**: Naranja
- **Arequipe**: Rosa
- **Confirmado**: Verde turquesa
- **Chocolate**: Café

## 🚀 Datos de Prueba

La aplicación incluye datos mockup para visualizar la funcionalidad:
- 5 pedidos de ejemplo
- 6 categorías predefinidas
- Diferentes estados (completado/pendiente)

## 🔮 Próximas Implementaciones

1. **Funcionalidad de Búsqueda**: Filtrar pedidos por título o cliente
2. **Filtros Avanzados**: Por categoría, fecha, estado
3. **Formulario de Creación**: Pantalla completa para crear pedidos
4. **Edición de Pedidos**: Modificar pedidos existentes
5. **Gestión de Categorías**: Agregar, editar, eliminar categorías
6. **Integración con Firebase**: Base de datos en la nube
7. **Notificaciones**: Recordatorios de fechas de entrega
8. **Reportes**: Estadísticas de ventas y pedidos

## 🛠️ Tecnologías

- **Flutter**: Framework de desarrollo
- **Dart**: Lenguaje de programación
- **Provider**: Gestión de estado (preparado)
- **Material Design**: Componentes de interfaz

## 📋 Instalación

1. Clonar el repositorio
2. Ejecutar `flutter pub get`
3. Ejecutar `flutter run`

## 👨‍💻 Desarrollo

El proyecto está estructurado de manera modular para facilitar el desarrollo incremental. Cada funcionalidad se puede implementar de forma independiente.

### Estado Actual: v1.0 (Básico)
- ✅ Estructura base implementada
- ✅ Interfaz visual completada
- ✅ Datos mockup funcionando
- 🔄 Funcionalidades básicas de navegación

### Próxima Versión: v1.1 (Interactividad)
- 🎯 Búsqueda y filtros funcionales
- 🎯 Formulario de creación básico
- 🎯 Edición de categorías

---

**Desarrollado con ❤️ para el negocio de repostería Juskar**
