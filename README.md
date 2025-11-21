# LOAN_C2
Repositorio de la materia Lenguaje orientado a negocios 2025-2C

# Sistema de Gestión de Biblioteca Universitaria

## 📌 Descripción
Este proyecto es un sistema completo para la gestión de una biblioteca universitaria, desarrollado en COBOL sobre z/OS, con integración CICS/BMS, DB2 y JCL.  
Permite la gestión de usuarios, libros, préstamos y reportes, siguiendo una arquitectura modular y orientada a CRUD.

---

## 📌 Nomenclatura

### Verbo + Entidad
- **CREATE** → Alta  
- **READ** → Consulta sobre un unico registro
- **UPDATE** → Modificación  
- **DELETE** → Baja  
- **LIST** → Listado de todos los registro (agregar parametro para meter filtros si corresponde) 
- **PROCESS** → Procesos de negocio (préstamos, devoluciones, en general funciones complejas)  
- **REPORT** → Reportes/estadísticas  

### Entidades principales
- **USER** → Usuarios  
- **BOOK** → Libros  
- **LOAN** → Préstamos  
- **REPORT** → Reportes/estadísticas  

### Ejemplos de programas
**Usuarios**
- `CREATEUSER` → Alta de usuario  
- `READUSER` → Consulta de usuario  
- `UPDATEUSER` → Modificación de usuario  
- `DELETEUSER` → Baja de usuario  
- `LISTUSERS` → Listado de usuarios  

**Libros**
- `CREATEBOOK`, `READBOOK`, `UPDATEBOOK`, `DELETEBOOK`, `LISTBOOKS`  

**Préstamos**
- `CREATELOAN`, `READLOAN`, `UPDATELOAN`, `DELETELOAN`, `LISTLOANS`  
- `PROCESSLOAN` → Registrar préstamo  
- `RETURNLOAN` → Procesar devolución  
- `LISTLOANS` → Listado de préstamos activos  

**Reportes**
- `REPORTBOOKS` → Libros más prestados  
- `REPORTUSERS` → Usuarios con préstamos vencidos  
- `REPORTSTATS` → Estadísticas generales  
- `REPORTINV` → Inventario por categoría  

### Copybooks
- `CPY_USER` → Estructura de usuario  
- `CPY_BOOK` → Estructura de libro  
- `CPY_LOAN` → Estructura de préstamo  
- `CPY_CONST` → Constantes del sistema  
- `CPY_MSGS` → Mensajes de error  
- `CPY_LINREP` → Layouts de reportes  

---

## 📌 Estructura de carpetas del proyecto
```
/library_managment
│
├── /bms_maps                 # Mapas BMS (pantallas interactivas)
│   ├── USER_ADD_VIEW.bms          # Pantalla de alta de usuario
│   ├── USER_SHOW_VIEW.bms         # Pantalla de consulta de un usuario
│   ├── USER_UPDATE_VIEW.bms       # Pantalla de modificación de usuario
│   ├── USER_DELETE_VIEW.bms       # Pantalla de baja de usuario
│   ├── USER_LIST_VIEW.bms         # Pantalla de listado de usuarios
│   └── ...  
│
├── /cobol_batch              # Programas COBOL batch
│   ├── CARGINI.cbl           # Carga inicial de libros
│   ├── REPORTS.cbl           # Generación de reportes batch
│   └── ...                   
│
├── /cobol_cics               # Programas COBOL CICS interactivos
│   ├── CREATEUSER.cbl        # Alta de usuario
│   ├── READUSER.cbl          # Consulta de usuario
│   ├── UPDATEUSER.cbl        # Modificación de usuario
│   ├── DELETEUSER.cbl        # Baja de usuario
│   ├── LISTUSERS.cbl         # Listado de usuarios
│   └── ...                                
│
├── /copybooks                # Copybooks compartidos
│   ├── CPY_USER.cpy          # Estructura de usuario
│   └── ...  
│                 
├── /jcl                      # JCL para compilación y ejecución
│   ├── compile_batch.jcl     # Compilación de batch
│   ├── compile_cics.jcl      # Compilación de CICS
│   ├── run_batch.jcl         # Ejecución de batch
│   └── run_cics.jcl          # Ejecución de CICS
│
└── /sql_scripts              # Scripts SQL para DB2
    ├── create_tables.sql     # Creación de tablas
    ├── populate_data.sql     # Carga inicial de datos
    └── ...                   

```

## 📌 Convenciones
- **Archivos COBOL:** `.cbl`  
- **Copybooks:** `.cpy`  
- **Mapas BMS:** `.bms`  
- **JCL:** `.jcl`  
- **SQL:** `.sql`  
- **Reportes:** `.txt` o `.csv` según formato  
