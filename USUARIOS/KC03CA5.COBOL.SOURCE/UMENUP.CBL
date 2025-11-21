       IDENTIFICATION DIVISION.
       PROGRAM-ID. UMENUP.
      *****************************************************************
      * PROGRAMA: UMENUP - MENU PRINCIPAL DE GESTION DE USUARIOS     *
      * DESCRIPCION: Menu principal que permite acceder a las         *
      *              diferentes funcionalidades del gestor            *
      * TRANSACCION: USER                                             *
      * MAPSET: UMENUM                                                *
      * AUTOR: KC03CA5                                                *
      * FECHA: 14/11/2025                                             *
      * VERSION: 2.1 - Mejorado cursor y estetica                     *
      *****************************************************************

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *---- Copybooks CICS ----
       COPY DFHAID.

      *---- Copia del mapa ----
       COPY UMENUM.

      *---- Variables de trabajo ----
       01  WS-VARIABLES.
           05  WS-OPCION              PIC X(01).
           05  WS-RESP                PIC S9(8) COMP.
           05  WS-RESP2               PIC S9(8) COMP.

      *---- Mensajes del sistema ----
       01  WS-MENSAJES.
           05  WS-MSG-DESPEDIDA       PIC X(50) VALUE
               'Gracias por usar el Sistema de Gestion'.
           05  WS-MSG-LONGITUD        PIC S9(4) COMP VALUE 50.

      *---- Indicador de primera ejecucion ----
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

      *---- Retornar con TRANSID para pseudo-conversacional ----
           EXEC CICS RETURN
               TRANSID('USER')
               COMMAREA(WS-PRIMERA-VEZ)
               LENGTH(1)
           END-EXEC.

       ENVIAR-MAPA-INICIAL.
      *---- Limpiar el mapa ----
           MOVE LOW-VALUES TO UMENUMI.

      *---- Mensaje inicial vacio (ya esta en el BMS) ----
           MOVE SPACES TO MENSAJEO.

      *---- Enviar mapa con borrado de pantalla ----
      *---- El IC en el BMS ya posiciona el cursor ----
           EXEC CICS SEND
               MAP('UMENUM')
               MAPSET('UMENUM')
               ERASE
           END-EXEC.

      *---- Marcar que ya no es la primera vez ----
           SET NO-ES-PRIMERA-VEZ TO TRUE.

       PROCESAR-ENTRADA.
      *---- Recibir datos del mapa ----
           EXEC CICS RECEIVE
               MAP('UMENUM')
               MAPSET('UMENUM')
               RESP(WS-RESP)
           END-EXEC.

      *---- Verificar teclas de atencion ----
           EVALUATE TRUE
               WHEN EIBAID = DFHPF3
                   PERFORM SALIR-APLICACION
               WHEN EIBAID = DFHCLEAR
                   PERFORM ENVIAR-MAPA-INICIAL
               WHEN EIBAID = DFHENTER
                   PERFORM VALIDAR-OPCION
               WHEN OTHER
                   MOVE 'Tecla no valida. Use ENTER o PF3' TO MENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       VALIDAR-OPCION.
      *---- Validar que se ingreso una opcion ----
           IF OPCIONL = 0 OR OPCIONI = SPACES
               MOVE 'Debe ingresar una opcion (1-6)' TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Obtener opcion ingresada ----
           MOVE OPCIONI TO WS-OPCION.

      *---- Ejecutar opcion seleccionada ----
           EVALUATE WS-OPCION
               WHEN '1'
                   PERFORM OPCION-ALTA
               WHEN '2'
                   PERFORM OPCION-CONSULTA
               WHEN '3'
                   PERFORM OPCION-MODIFICACION
               WHEN '4'
                   PERFORM OPCION-BAJA
               WHEN '5'
                   PERFORM OPCION-LISTADO
               WHEN '6'
                   PERFORM SALIR-APLICACION
               WHEN OTHER
                   MOVE 'Opcion invalida (1-6). Intente nuevamente'
                       TO MENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       OPCION-ALTA.
      *---- Transferir control a programa de alta ----
           EXEC CICS XCTL
               PROGRAM('UALTAP')
               RESP(WS-RESP)
           END-EXEC.

      *---- Si falla el XCTL ----
           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR: Programa UALTAP no disponible' TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
           END-IF.

       OPCION-CONSULTA.
      *---- Transferir control a programa de consulta ----
           EXEC CICS XCTL
               PROGRAM('UCONSP')
               RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR: Programa UCONSP no disponible' TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
           END-IF.

       OPCION-MODIFICACION.
      *---- Transferir control a programa de modificacion ----
           EXEC CICS XCTL
               PROGRAM('UMODIP')
               RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR: Programa UMODIP no disponible' TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
           END-IF.

       OPCION-BAJA.
      *---- Transferir control a programa de baja ----
           EXEC CICS XCTL
               PROGRAM('UBAJAP')
               RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR: Programa UBAJAP no disponible' TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
           END-IF.

       OPCION-LISTADO.
      *---- Transferir control a programa de listado ----
           EXEC CICS XCTL
               PROGRAM('ULISTAP')
               RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR: Programa ULISTAP no disponible'
                   TO MENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
           END-IF.

       ENVIAR-MAPA-ERROR.
      *---- Reenviar mapa con mensaje de error ----
      *---- El cursor ya esta en OPCION por defecto ----
           MOVE SPACES TO OPCIONI.

           EXEC CICS SEND
               MAP('UMENUM')
               MAPSET('UMENUM')
               DATAONLY
               ALARM
           END-EXEC.

       SALIR-APLICACION.
      *---- Mensaje de despedida ----
           EXEC CICS SEND TEXT
               FROM(WS-MSG-DESPEDIDA)
               LENGTH(WS-MSG-LONGITUD)
               ERASE
               FREEKB
           END-EXEC.

      *---- Retornar sin TRANSID para terminar ----
           EXEC CICS RETURN END-EXEC.
