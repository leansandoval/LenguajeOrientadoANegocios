       IDENTIFICATION DIVISION.
       PROGRAM-ID. UCONSP.
      *****************************************************************
      * PROGRAMA: UCONSP - CONSULTA DE USUARIO POR ID                *
      * DESCRIPCION: Permite buscar un usuario por su ID              *
      * TRANSACCION: UCON (pseudo-conversacional independiente)       *
      * MAPSET: UCONSM                                                *
      * AUTOR: KC03CA5                                                *
      * FECHA: 16/11/2025                                             *
      * VERSION: 3.0 - Mejorado estetica y descripcion de tipo        *
      *****************************************************************

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *---- Copybooks CICS ----
       COPY DFHAID.
       COPY DFHBMSCA.

      *---- Copia del mapa ----
       COPY UCONSM.

      *---- Copia de la estructura de usuario ----
       COPY USUARIO.

      *---- Variables de trabajo ----
       01  WS-VARIABLES.
           05  WS-RESP                PIC S9(8) COMP.
           05  WS-RESP2               PIC S9(8) COMP.
           05  WS-ID-TEMP             PIC X(10).
           05  WS-TIPO-DESC           PIC X(30).

      *---- Indicador de primera ejecución ----
       01  WS-PRIMERA-VEZ             PIC X(01) VALUE 'Y'.
           88  ES-PRIMERA-VEZ                   VALUE 'Y'.
           88  NO-ES-PRIMERA-VEZ                VALUE 'N'.

       LINKAGE SECTION.
       01  DFHCOMMAREA                PIC X(01).

       PROCEDURE DIVISION.

       MAIN-PROCESS.
      *---- Verificar si es la primera vez ----
           IF EIBCALEN = ZERO
               SET ES-PRIMERA-VEZ TO TRUE
               PERFORM ENVIAR-MAPA-INICIAL
           ELSE
               MOVE DFHCOMMAREA TO WS-PRIMERA-VEZ
               PERFORM PROCESAR-ENTRADA
           END-IF.

      *---- Retornar con transacción UCON para quedar en consulta ----
           EXEC CICS RETURN
               TRANSID('UCON')
               COMMAREA(WS-PRIMERA-VEZ)
               LENGTH(1)
           END-EXEC.

       ENVIAR-MAPA-INICIAL.
      *---- Limpiar solo el area de entrada ----
           MOVE LOW-VALUES TO UCONSMI.

      *---- Limpiar solo campos variables (datos del usuario) ----
           MOVE SPACES TO MENSAJEO NOMO APEO EMAO TIPO.

      *---- Mensaje inicial ----
           MOVE 'Ingrese el ID del usuario a consultar' TO MENSAJEO.

      *---- Posicionar cursor en campo ID ----
           MOVE -1 TO CAMPOIDL.

      *---- Enviar mapa completo con ERASE (incluye INITIAL del BMS) ---
           EXEC CICS SEND
               MAP('UCONSM')
               MAPSET('UCONSM')
               ERASE
               CURSOR
           END-EXEC.

      *---- Marcar que ya no es la primera vez ----
           SET NO-ES-PRIMERA-VEZ TO TRUE.

       PROCESAR-ENTRADA.
      *---- Recibir datos del mapa ----
           EXEC CICS RECEIVE
               MAP('UCONSM')
               MAPSET('UCONSM')
               RESP(WS-RESP)
           END-EXEC.

      *---- Verificar si hubo error en RECEIVE ----
           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR al recibir datos del mapa' TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Verificar teclas de atención ----
           EVALUATE TRUE
               WHEN EIBAID = DFHPF3
                   PERFORM VOLVER-MENU
               WHEN EIBAID = DFHCLEAR
                   PERFORM LIMPIAR-PANTALLA
               WHEN EIBAID = DFHENTER
                   PERFORM CONSULTAR-USUARIO
               WHEN OTHER
                   MOVE 'Tecla no valida. Use ENTER, CLEAR o PF3'
                       TO MENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       CONSULTAR-USUARIO.
      *---- Validar que se ingresó un ID ----
           IF CAMPOIDL = 0 OR CAMPOIDL = -1
               MOVE 'ERROR: Debe ingresar un ID para buscar'
                   TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Validar que el ID no sea cero ----
           IF CAMPOIDI = ZEROS
               MOVE 'ERROR: ID invalido. Debe ser mayor a cero'
                   TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Preparar clave para búsqueda ----
           MOVE CAMPOIDI TO USU-ID.

      *---- Leer registro usando EXEC CICS READ ----
           EXEC CICS READ
               FILE('USUDS')
               INTO(REG-USUARIO)
               RIDFLD(USU-ID)
               RESP(WS-RESP)
           END-EXEC.

      *---- Evaluar resultado de la lectura ----
           EVALUATE WS-RESP
               WHEN DFHRESP(NORMAL)
                   PERFORM MOSTRAR-USUARIO-ENCONTRADO
               WHEN DFHRESP(NOTFND)
                   PERFORM MOSTRAR-USUARIO-NO-ENCONTRADO
               WHEN DFHRESP(DISABLED)
                   MOVE 'ERROR: Archivo USUDS deshabilitado en CICS'
                       TO MENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN DFHRESP(NOTOPEN)
                   MOVE 'ERROR: Archivo USUDS no esta abierto'
                       TO MENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN OTHER
                   MOVE 'ERROR al leer archivo VSAM' TO MENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       MOSTRAR-USUARIO-ENCONTRADO.
      *---- Cargar datos del usuario en el mapa ----
           MOVE USU-NOMBRE   TO NOMO.
           MOVE USU-APELLIDO TO APEO.
           MOVE USU-EMAIL    TO EMAO.

      *---- Formatear tipo con descripción ----
           EVALUATE USU-TIPO
               WHEN 'A'
                   MOVE 'A (Administrador)' TO TIPO
               WHEN 'D'
                   MOVE 'D (Docente)' TO TIPO
               WHEN 'E'
                   MOVE 'E (Estudiante)' TO TIPO
               WHEN OTHER
                   MOVE USU-TIPO TO TIPO
           END-EVALUATE.

           MOVE 'Usuario encontrado correctamente' TO MENSAJEO.

      *---- Proteger el campo ID para mostrar resultado ----
           MOVE CAMPOIDI TO WS-ID-TEMP.
           MOVE WS-ID-TEMP TO CAMPOIDO.

      *---- Enviar solo los datos (mantiene estructura BMS) ----
           MOVE -1 TO CAMPOIDL.
           EXEC CICS SEND
               MAP('UCONSM')
               MAPSET('UCONSM')
               DATAONLY
               CURSOR
           END-EXEC.

       MOSTRAR-USUARIO-NO-ENCONTRADO.
      *---- Limpiar campos de datos ----
           MOVE SPACES TO NOMO APEO EMAO TIPO.
           MOVE 'Usuario no encontrado en el sistema' TO MENSAJEO.

      *---- Mantener el ID ingresado ----
           MOVE CAMPOIDI TO WS-ID-TEMP.
           MOVE WS-ID-TEMP TO CAMPOIDO.

      *---- Enviar mapa con mensaje ----
           MOVE -1 TO CAMPOIDL.
           EXEC CICS SEND
               MAP('UCONSM')
               MAPSET('UCONSM')
               DATAONLY
               CURSOR
               ALARM
           END-EXEC.

       LIMPIAR-PANTALLA.
      *---- Limpiar todos los campos ----
           MOVE SPACES TO CAMPOIDO NOMO APEO EMAO TIPO.
           MOVE 'Pantalla limpia. Ingrese nuevo ID' TO MENSAJEO.

      *---- Posicionar cursor en ID ----
           MOVE -1 TO CAMPOIDL.

      *---- Enviar solo datos ----
           EXEC CICS SEND
               MAP('UCONSM')
               MAPSET('UCONSM')
               DATAONLY
               CURSOR
           END-EXEC.

       ENVIAR-MAPA-ERROR.
      *---- Reenviar mapa con mensaje de error ----
           MOVE -1 TO CAMPOIDL.

           EXEC CICS SEND
               MAP('UCONSM')
               MAPSET('UCONSM')
               DATAONLY
               CURSOR
               ALARM
           END-EXEC.

       VOLVER-MENU.
      *---- Transferir control de vuelta al menú ----
           EXEC CICS XCTL
               PROGRAM('UMENUP')
           END-EXEC.
