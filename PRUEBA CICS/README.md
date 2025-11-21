
# 📘 Guía de Ejecución CICS — Proyecto COBOL + MAPSET

Este repositorio contiene los JCL, fuentes COBOL y definiciones necesarias para compilar y ejecutar un programa COBOL con CICS, utilizando un MAPSET previamente generado.  
El objetivo es documentar los pasos para:

1. Compilar el mapa (MAPSET)  
2. Compilar el programa COBOL que usa el mapa  
3. Definir los recursos en CICS  
4. Habilitar la librería `.LOAD`  
5. Ejecutar la transacción en un entorno CICS

---

## 📂 Contenido

- **JCL de compilación**
  - `TESTC` → compila el MAPSET  
  - `CMPTEST` → compila el programa COBOL  
- **Librerías de salida `.LOAD`**
  - `TESTC` (mapa compilado)  
  - `TESTME` (programa COBOL compilado)  
- **Guía paso a paso para ejecutar en CICS**

---

# 🚀 Pasos para Ejecutar el Programa en CICS

Los siguientes pasos están basados en la guía provista en el PDF original.

---

## 1️⃣ Compilar MAPSET y Programa COBOL

1. Ejecutar el JCL:

   ```text
   TESTC  -> compila el MAPSET
   ```

2. Ejecutar el JCL:

   ```text
   CMPTEST -> compila el programa COBOL que usa el mapa
   ```

Al finalizar, deberías tener **dos miembros en la librería `.LOAD`**:

- `TESTC`  → MAPSET compilado  
- `TESTME` → PROGRAMA COBOL compilado  

---

## 2️⃣ Ingresar a CICS

1. Abrir una terminal 3270  
2. Ejecutar:

   ```
   CICS
   ```

   *(sin loguearse)*

3. Presionar **TAB** para posicionarse en el campo de escritura  
4. Cargar la **ruta completa a tu librería `.LOAD`**

---

# 🏗 3️⃣ Definir Recursos en CICS

Debés definir:

- La **librería LOAD**
- El **programa**
- La **transacción**
- El **MAPSET**
- Y finalmente **instalar y habilitar todo**

---

## 🔹 3.1 Definir Librería

```
CEDA DEFINE LIBRARY(KC03C91) GROUP(KC03C91)
```

Completar:

```
Library : KC03C91
Group   : KC03C91
Dsname  : KC03C91.LOAD
```

---

## 🔹 3.2 Definir Programa

```
CEDA DEFINE PROGRAM(TESTME) GROUP(KC03C91)
```

Parámetros:

```
Program  : TESTME
Group    : KC03C91
Language : COBOL
Resident : NO
Usage    : NORMAL
```

---

## 🔹 3.3 Definir Transacción

```
CEDA DEFINE TRANSACTION(TEST) GROUP(KC03C91)
```

Parámetros:

```
Transaction : TEST
Program     : TESTME
Group       : KC03C91
```

---

## 🔹 3.4 Definir MAPSET

```
CEDA DEFINE MAPSET(TESTC) GROUP(KC03C91)
```

---

# 🔄 4️⃣ Instalar y Habilitar

```
CEDA INSTALL GROUP(KC03C91)
CEMT SET LIBRARY(KC03C91) ENABLED
CEMT SET PROGRAM(TESTME) NEWCOPY
```

---

# 🧪 5️⃣ Ejecutar la Transacción

En la pantalla inicial de CICS escribir:

```
TEST
```

Si todo está correcto, se cargará el programa COBOL con su pantalla MAPSET.

---

# 🛠 Solución de Errores Comunes

Si aparece **NOT FOUND** o error de carga, revisar:

## ✔ Opción 1: Verificar si la librería existe

```
CEDA VIEW LIBRARY(KC03C91) GROUP(*)
```

Si no existe → crearla.

## ✔ Opción 2: Crear la librería

```
CEDA DEFINE LIBRARY(KC03C91) GROUP(KC03C91)
```

Completar:

```
Library : KC03C91
Group   : KC03C91
Dsname  : KC03C91.LOAD
```

## ✔ Opción 3: Instalar y habilitar

```
CEDA INSTALL GROUP(KC03C91)
CEMT SET LIBRARY(KC03C91) ENABLED
```

---
