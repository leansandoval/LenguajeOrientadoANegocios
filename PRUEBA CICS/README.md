
# 📘 Guía Completa de Ejecución CICS — Proyecto COBOL + MAPSET + VSAM

Este repositorio contiene los JCL, fuentes COBOL, definiciones CICS y archivos necesarios para compilar y ejecutar un programa COBOL con CICS, incluyendo:

- MAPSET
- Programa COBOL
- Transacción CICS
- Librería LOAD
- Archivo VSAM
- Menú interactivo desde terminal 3270

Esta guía combina información de ambos documentos provistos por el estudiante.

---

# 📂 Contenido

- Compilación del MAPSET y programa COBOL
- Configuración completa en CICS
- Definición del archivo VSAM
- Ejecución de la transacción
- Visualización del menú y lectura del VSAM
- Solución de errores comunes

---

# 🚀 1. Compilar MAPSET y Programa COBOL

1. Ejecutar el JCL:

   ```text
   TESTC  -> compila el MAPSET
   ```

2. Ejecutar el JCL:

   ```text
   CMPTEST -> compila el programa COBOL que usa el mapa
   ```

Después de esta etapa deben existir dos miembros en la librería `.LOAD`:

- `TESTC`  → MAPSET compilado  
- `TESTME` → PROGRAMA COBOL compilado  

---

# 🖥 2. Ingresar a CICS

1. Abrir una terminal 3270.  
2. Escribir:

   ```
   CICS
   ```

3. Presionar **TAB** y cargar la ruta completa a tu librería `.LOAD`.

---

# 🏗 3. Definir Recursos en CICS

Debés definir:

- Librería LOAD  
- Programa  
- Transacción  
- MAPSET  
- Archivo VSAM  
- Instalar y habilitar los recursos  

---

## 🔹 3.1 Definir Librería LOAD

```
CEDA DEFINE LIBRARY(KC03C91) GROUP(KC03C91)
```

Parámetros:

```
Library : KC03C91
Group   : KC03C91
Dsname  : KC03C91.LOAD
```

---

## 🔹 3.2 Definir Programa

Ejemplo para el programa del menú:

```
CEDA DEFINE PROGRAM(CMENU) GROUP(KC03C91)
```

Parámetros:

```
Program  : CMENU
Group    : KC03C91
Language : COBOL
Resident : NO
Usage    : NORMAL
```

---

## 🔹 3.3 Definir Transacción

```
CEDA DEFINE TRANSACTION(TPG3) GROUP(KC03C91)
```

Parámetros:

```
Transaction : TPG3
Program     : CMENU
Group       : KC03C91
```

---

## 🔹 3.4 Definir MAPSET

```
CEDA DEFINE MAPSET(MMENU) GROUP(KC03C91)
```

---

## 🔹 3.5 Definir Archivo VSAM (Nuevo)

Si el menú trabaja con un archivo VSAM (por ejemplo LIBROS generado por CARGAINI), debe definirse:

```
CEDA DEFINE FILE(LIBROS) GROUP(KC03C91)
```

El nombre debe coincidir con el DDNAME usado en el programa COBOL.

---

# 🔄 4. Instalar y Habilitar

```
CEDA INSTALL GROUP(KC03C91)
CEMT SET LIBRARY(KC03C91) ENABLED
CEMT SET PROGRAM(CMENU) NEWCOPY
```

---

# 🧪 5. Ejecutar la Transacción

En la pantalla inicial de CICS ingresar:

```
TPG3
```

Esto abrirá el menú principal del sistema.

---

# 📋 6. Funcionalidad del Menú

Según el segundo documento, el menú permite:

1. Consultar libros  
2. Listar libros  
3. Dar de alta un libro  
4. Salir  

La opción **1** permite consultar registros almacenados en el **archivo VSAM LIBROS**.

Este archivo debe haber sido generado previamente por el programa **CARGAINI**.

---

# 🛠 Solución de Errores Comunes

### ✔ Verificar si la librería existe

```
CEDA VIEW LIBRARY(KC03C91) GROUP(*)
```

Si aparece **NOT FOUND**, debe crearse.

### ✔ Crear librería LOAD

```
CEDA DEFINE LIBRARY(KC03C91) GROUP(KC03C91)
```

### ✔ Instalar y habilitar

```
CEDA INSTALL GROUP(KC03C91)
CEMT SET LIBRARY(KC03C91) ENABLED
```

---
