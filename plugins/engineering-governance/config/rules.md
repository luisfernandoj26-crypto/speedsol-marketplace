# .NET Company Standards (Enterprise)

## 🏗 Arquitectura obligatoria
- Usar patrón MVC
- Controllers sin lógica de negocio
- Business logic en Services
- Data Access en Repositories (Azure SQL / Azure DB)

## 🧩 Naming conventions
- camelCase: variables y métodos
- PascalCase: clases
- Interfaces con prefijo I (ej: IUserService)

## 📊 Logging (OBLIGATORIO)
- Usar ILogger<T>
- Registrar:
  - Errores (LogError)
  - Información crítica (LogInformation)
- No usar Console.WriteLine

## 🚨 Manejo de errores
- Usar try/catch en Services
- No exponer errores internos al cliente
- Retornar mensajes controlados y seguros

## 💻 Estilo de código
- Código en inglés
- Comentarios en español claros y útiles
- Métodos pequeños y reutilizables

## 🔐 Seguridad
- No exponer credenciales ni keys
- Validar inputs siempre
- Evitar SQL Injection