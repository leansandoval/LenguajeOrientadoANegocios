# Lenguaje Orientado a Negocios
Repositorio de la materia Lenguaje Orientado a Negocios (3677) UNLaM - Segundo Cuatrimestre 2025.

## Información de la Asignatura
* **Carrera**: Ingeniería en Informática
* **Asignatura**: Lenguaje Orientado a Negocios (3677)
* **Cuatrimestre**: Segundo Cuatrimestre
* **Año**: 2025
* **Grupo**: 3

## Trayecto - Gestión y Complementarias

* **Año académico**: Quinto Año - Primer Cuatrimestre
* **Responsable / Jefe de catedra**: Gonzalez, Adrian Gabriel
* **Carga horaria semanal**: 4 hs
* **Carga horaria total**: 64 hs
* **Modalidad**: Virtual
* **Correlativas anteriores**
  * Programación Avanzada (3652)
  * Arquitectura de Sistemas Software (3653)
  * Gestión de Proyectos (3661)

## Docentes
* Gonzalez, Adrian Gabriel

## Sistema de Gestión CICS - Mainframe

Este repositorio contiene aplicaciones COBOL para mainframe IBM z/OS con CICS, organizadas en dos módulos principales: gestión de libros y gestión de usuarios.

### Estructura del Proyecto

#### 📚 LIBROS
Sistema de gestión de biblioteca con funcionalidades de préstamos y consultas.

- **BMS**: Mapas de pantalla CICS
  - [`CMENU.BMS`](LIBROS/KC03C91.BMS.SOURCE/CMENU.BMS) - Menú principal del sistema
  
- **COPYLIB**: Librerías de copias COBOL
  - [`CONSTANT.CBL`](LIBROS/KC03C91.COBOL.COPYLIB/CONSTANT.CBL) - Constantes del sistema
  - [`LIBROS.CBL`](LIBROS/KC03C91.COBOL.COPYLIB/LIBROS.CBL) - Estructura de datos de libros
  - [`LINREP.CBL`](LIBROS/KC03C91.COBOL.COPYLIB/LINREP.CBL) - Líneas de reportes
  - [`MENSAJES.CBL`](LIBROS/KC03C91.COBOL.COPYLIB/MENSAJES.CBL) - Mensajes del sistema
  - [`MMENU.CBL`](LIBROS/KC03C91.COBOL.COPYLIB/MMENU.CBL) - Mapas de menú
  - [`PRESTAMO.CBL`](LIBROS/KC03C91.COBOL.COPYLIB/PRESTAMO.CBL) - Estructura de préstamos
  - [`USUARIO.CBL`](LIBROS/KC03C91.COBOL.COPYLIB/USUARIO.CBL) - Estructura de usuarios

- **SOURCE**: Programas fuente COBOL
  - [`CARGAINI.CBL`](LIBROS/KC03C91.COBOL.SOURCE/CARGAINI.CBL) - Carga inicial de datos
  - [`CMENU.CBL`](LIBROS/KC03C91.COBOL.SOURCE/CMENU.CBL) - Programa del menú principal

- **JCL**: Jobs de control
- **DATA**: [`DATA.ENTRADA`](LIBROS/DATA.ENTRADA) - Datos de entrada para carga inicial

#### 🧪 PRUEBA CICS
Entorno de pruebas para aplicaciones CICS.

- **BMS**: Mapas de pantalla de prueba
- **COPYLIB**: Librerías de copias de prueba
- **SOURCE**: Programas COBOL de prueba
- **JCL**: Jobs de prueba
- **LOAD**: Módulos compilados

#### 👥 USUARIOS
Sistema de gestión de usuarios.

- **DATA**: Archivos de datos de usuarios
- **BMS**: Mapas de pantalla para usuarios
- **COPYLIB**: Librerías de copias de usuarios
- **SOURCE**: Programas COBOL de usuarios
- **JCL**: Jobs de gestión de usuarios

### Tecnologías

- **COBOL** - Lenguaje de programación principal
- **CICS** - Customer Information Control System
- **BMS** - Basic Mapping Support para pantallas
- **JCL** - Job Control Language
- **VSAM** - Virtual Storage Access Method (archivos)
- **IBM z/OS** - Sistema operativo mainframe

### Convenciones de Nomenclatura

- **KC03C91**: Prefijo para el módulo de libros
- **KC03CA5**: Prefijo para el módulo de usuarios
- **.BMS**: Archivos de mapas de pantalla
- **.CBL**: Archivos fuente COBOL
- **.JCL**: Archivos de control de trabajos

### Desarrollo

#### Pre-requisitos
- Acceso a sistema mainframe IBM z/OS
- CICS Transaction Server
- Compilador COBOL Enterprise
- Zowe CLI (opcional, para deployment)

#### Configuración de Zowe

El proyecto incluye configuración para Zowe CLI que permite la interacción con el mainframe. Archivo de configuración `zowe.config.json`:

```json
{
    "$schema": "./zowe.schema.json",
    "profiles": {
        "zosmf": {
            "type": "zosmf",
            "properties": {
                "port": 10443
            },
            "secure": ["user", "password"]
        },
        "tsoZXPLore": {
            "type": "tso",
            "properties": {
                "account": "FB3",
                "codePage": "1047",
                "logonProcedure": "IZUFPROC"
            }
        },
        "ssh": {
            "type": "ssh",
            "properties": {
                "port": 22
            }
        },
        "rse": {
            "type": "rse",
            "properties": {
                "port": 6800,
                "basePath": "rseapi",
                "protocol": "https"
            }
        },
        "global_base": {
            "type": "base",
            "properties": {
                "host": "ZOS.KCTR.MARIST.EDU",
                "rejectUnauthorized": false
            },
            "secure": ["user", "password"]
        }
    },
    "defaults": {
        "zosmf": "zosmf",
        "tso": "tsoZXPLore",
        "ssh": "ssh",
        "rse": "rse",
        "base": "global_base"
    },
    "autoStore": true
}
```

**Configuración del entorno:**
- **Host**: ZOS.KCTR.MARIST.EDU
- **z/OSMF Port**: 10443
- **SSH Port**: 22
- **RSE Port**: 6800
- **TSO Account**: FB3
- **Code Page**: 1047

#### Estructura de Datos
Las estructuras de datos principales se definen en las copylibs:
- Libros y catálogo
- Préstamos y devoluciones
- Usuarios y permisos
- Mensajes del sistema

