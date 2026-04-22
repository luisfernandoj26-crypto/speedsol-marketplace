# .NET Company Standards (Enterprise)

## Arquitectura obligatoria
- Usar patr車n MVC
- Controllers sin l車gica de negocio
- La l車gica de negocio debe estar en Services
- Acceso a datos mediante Repositories (Azure SQL / DB)

---

## Naming conventions
- camelCase: variables y m谷todos  
- PascalCase: clases, propiedades y m谷todos p迆blicos  
- Interfaces con prefijo I (ej: IUserService)

---

## Logging (OBLIGATORIO)
- Usar ILogger<T>
- Registrar:
  - Errores (LogError)
  - Eventos importantes (LogInformation)
- No usar Console.WriteLine

---

## Manejo de errores
- Usar try/catch en Services
- No exponer errores internos al cliente
- Retornar mensajes controlados y seguros

---

## Estilo de c車digo
- C車digo en ingl谷s
- Comentarios en espa?ol claros y 迆tiles
- M谷todos peque?os, reutilizables y con una sola responsabilidad

---

## Seguridad
- No exponer credenciales ni API keys
- Validar inputs siempre
- Prevenir SQL Injection (usar par芍metros, nunca concatenaci車n)

---

## Nomenclatura

| Elemento                                   | Convenci車n    | Ejemplo                                             |
|-------------------------------------------|--------------|-----------------------------------------------------|
| Clases, interfaces, m谷todos, propiedades | PascalCase   | CustomerOrder, IShape, CalculateTotal()             |
| Variables y par芍metros                   | camelCase    | orderCount, customerName                            |
| Campos privados                          | _camelCase   | _connectionString                                   |
| Constantes p迆blicas                      | PascalCase   | public const double Pi = 3.14159;                   |
| Constantes privadas                      | _camelCase   | _maxRetries                                         |

---

## Estilo de C車digo
- Usar un solo estilo de llaves (Allman o K&R) sin mezclar
- Indentaci車n de 4 espacios, no tabs
- Usar var cuando el tipo sea evidente
- M谷todos async deben terminar en Async

---

## Organizaci車n de Clases
Orden recomendado:
1. Campos  
2. Propiedades  
3. Constructores  
4. M谷todos p迆blicos  
5. M谷todos privados  

---

## Buenas pr芍cticas
- Nombres descriptivos y orientados al dominio
- M谷todos cortos (Single Responsibility)
- Evitar comentarios innecesarios
- Usar documentaci車n XML en APIs p迆blicas
- Habilitar nullable reference types
- Validar par芍metros de entrada expl赤citamente

---

## Automatizaci車n
Definir reglas en .editorconfig para enforcement autom芍tico en IDEs.

---

# Stack Tecnol車gico

- Framework: .NET 9  
- Web: ASP.NET Core, Blazor Server  
- ORM: Entity Framework Core  
- DB: SQL Server, SQLite, InMemory  
- Auth: JWT + API Key interna  
- Mapping: AutoMapper  
- Realtime: SignalR  
- Storage: Azure Blob Storage  
- Logging: Serilog  
- Testing: xUnit + Moq  
- API Docs: Swagger / OpenAPI  

---

# Arquitectura y Patrones

## Capas

Controllers/        Endpoints y validaci車n
Services/           L車gica de negocio
Repositories/       Acceso a datos
Entities/           Modelos de dominio
DTOs/               Objetos de transferencia
Data/               DbContext
Security/           Autorizaci車n
BackgroundServices/ Procesos en segundo plano
Helpers/            Utilidades
Extensions/         Extensiones
Interfaces/         Contratos

# Patrones clave
Repository Pattern
Service Layer
DTO Pattern
AutoMapper centralizado
Multi-tenancy por OwnerId
Autorizaci車n por plan
Background Jobs con IHostedService
#Comunicaci車n
Frontend ↙ Backend: HTTP + JWT
Servicios internos: API Key
Tiempo real: SignalR
#Base de Datos
##Entornos
Producci車n: Azure SQL
Desarrollo: SQLite / InMemory
##Convenciones
Precisi車n decimal: 18,3
Migraciones con formato:
YYYYMMDDHHMM_Descripcion
#Prefijos de tablas
Prefijo	Dominio
Adm_	Administraci車n
Cus_	Clientes
Gen_	Gen谷rico
Par_	Par芍metros
Ten_	Tenant
View_	Reporting
API_View_	Integraciones