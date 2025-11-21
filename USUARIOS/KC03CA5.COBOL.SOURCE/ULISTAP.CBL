       IDENTIFICATION DIVISION.
       PROGRAM-ID. ULISTAP.
      *****************************************************************
      * PROGRAMA: ULISTAP - LISTADO DE USUARIOS                      *
      * VERSION: 3.3 - Corregido envio inicial COMPLETO              *
      *****************************************************************

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *---- Copybooks CICS ----
       COPY DFHAID.
       COPY DFHBMSCA.

      *---- Copia del mapa ----
       COPY ULISTAM.

      *---- Copia de la estructura de usuario ----
       COPY USUARIO.

      *---- Variables de trabajo ----
       01  WS-RESP                PIC S9(8) COMP.
       01  WS-CONTADOR            PIC 9(2) VALUE ZERO.
       01  WS-RIDFLD              PIC 9(10) VALUE ZERO.
       01  WS-FIN-ARCHIVO         PIC X VALUE 'N'.
           88  FIN-ARCHIVO                 VALUE 'S'.
           88  HAY-MAS-DATOS               VALUE 'N'.
       01  WS-CONTINUAR           PIC X VALUE 'S'.
           88  SEGUIR-PROCESANDO           VALUE 'S'.

       PROCEDURE DIVISION.

       MAIN-PROCESS.
      *---- Siempre cerrar browse previo por si acaso ----
           EXEC CICS ENDBR
               FILE('USUDS')
               RESP(WS-RESP)
           END-EXEC.

      *---- Limpiar TODA la estructura del mapa ----
           MOVE LOW-VALUES TO ULISTAMO.
           MOVE SPACES TO MENSAJEO.

      *---- Iniciar nuevo browse ----
           MOVE ZERO TO WS-RIDFLD.
           SET HAY-MAS-DATOS TO TRUE.
           SET SEGUIR-PROCESANDO TO TRUE.

           EXEC CICS STARTBR
               FILE('USUDS')
               RIDFLD(WS-RIDFLD)
               KEYLENGTH(10)
               GTEQ
               RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR: No se puede acceder al archivo USUDS'
                   TO MENSAJEO
               EXEC CICS SEND
                   MAP('ULISTAM')
                   MAPSET('ULISTAM')
                   ERASE
               END-EXEC
               PERFORM VOLVER-MENU
           END-IF.

      *---- Leer primera página directamente en ULISTAMO ----
           PERFORM LEER-REGISTROS.
           PERFORM DETERMINAR-MENSAJE.

      *---- Enviar mapa completo con ERASE ----
           EXEC CICS SEND
               MAP('ULISTAM')
               MAPSET('ULISTAM')
               ERASE
           END-EXEC.

      *---- Loop de conversación ----
           PERFORM UNTIL NOT SEGUIR-PROCESANDO
               EXEC CICS RECEIVE
                   MAP('ULISTAM')
                   MAPSET('ULISTAM')
                   RESP(WS-RESP)
               END-EXEC

               EVALUATE EIBAID
                   WHEN DFHPF3
                       PERFORM CERRAR-BROWSE
                       PERFORM VOLVER-MENU
                   WHEN DFHENTER
                       IF FIN-ARCHIVO
                           MOVE 'Fin del archivo. PF3=VOLVER'
                               TO MENSAJEO
                           EXEC CICS SEND
                               MAP('ULISTAM')
                               MAPSET('ULISTAM')
                               DATAONLY
                           END-EXEC
                       ELSE
                           PERFORM LIMPIAR-FILAS
                           PERFORM LEER-REGISTROS
                           PERFORM DETERMINAR-MENSAJE
                           EXEC CICS SEND
                               MAP('ULISTAM')
                               MAPSET('ULISTAM')
                               DATAONLY
                           END-EXEC
                       END-IF
                   WHEN OTHER
                       MOVE 'Tecla no valida. Use ENTER o PF3'
                           TO MENSAJEO
                       EXEC CICS SEND
                           MAP('ULISTAM')
                           MAPSET('ULISTAM')
                           DATAONLY
                       END-EXEC
               END-EVALUATE
           END-PERFORM.

       LEER-REGISTROS.
      *---- Leer hasta 10 registros ----
           MOVE ZERO TO WS-CONTADOR.

           PERFORM UNTIL WS-CONTADOR >= 10 OR FIN-ARCHIVO
               EXEC CICS READNEXT
                   FILE('USUDS')
                   INTO(REG-USUARIO)
                   RIDFLD(WS-RIDFLD)
                   KEYLENGTH(10)
                   RESP(WS-RESP)
               END-EXEC

               IF WS-RESP = DFHRESP(NORMAL)
                   ADD 1 TO WS-CONTADOR
                   PERFORM RELLENAR-FILA
               ELSE
                   SET FIN-ARCHIVO TO TRUE
               END-IF
           END-PERFORM.

       DETERMINAR-MENSAJE.
      *---- Mensaje según estado ----
           IF FIN-ARCHIVO
               IF WS-CONTADOR = ZERO
                   MOVE 'No hay mas registros.'
                       TO MENSAJEO
               ELSE
                   MOVE 'Fin del archivo.'
                       TO MENSAJEO
               END-IF
           ELSE
               MOVE 'ENTER=Siguiente pagina | PF3=VOLVER'
                   TO MENSAJEO
           END-IF.

       LIMPIAR-FILAS.
      *---- Limpiar con SPACES para borrar contenido anterior ----
           MOVE SPACES TO USR-ID1O USR-NOM1O USR-APE1O
                          USR-MAI1O USR-TIP1O.
           MOVE SPACES TO USR-ID2O USR-NOM2O USR-APE2O
                          USR-MAI2O USR-TIP2O.
           MOVE SPACES TO USR-ID3O USR-NOM3O USR-APE3O
                          USR-MAI3O USR-TIP3O.
           MOVE SPACES TO USR-ID4O USR-NOM4O USR-APE4O
                          USR-MAI4O USR-TIP4O.
           MOVE SPACES TO USR-ID5O USR-NOM5O USR-APE5O
                          USR-MAI5O USR-TIP5O.
           MOVE SPACES TO USR-ID6O USR-NOM6O USR-APE6O
                          USR-MAI6O USR-TIP6O.
           MOVE SPACES TO USR-ID7O USR-NOM7O USR-APE7O
                          USR-MAI7O USR-TIP7O.
           MOVE SPACES TO USR-ID8O USR-NOM8O USR-APE8O
                          USR-MAI8O USR-TIP8O.
           MOVE SPACES TO USR-ID9O USR-NOM9O USR-APE9O
                          USR-MAI9O USR-TIP9O.
           MOVE SPACES TO USR-ID10O USR-NOM10O USR-APE10O
                          USR-MAI10O USR-TIP10O.

       RELLENAR-FILA.
           EVALUATE WS-CONTADOR
               WHEN 1
                   MOVE USU-ID       TO USR-ID1O
                   MOVE USU-NOMBRE   TO USR-NOM1O
                   MOVE USU-APELLIDO TO USR-APE1O
                   MOVE USU-EMAIL    TO USR-MAI1O
                   MOVE USU-TIPO     TO USR-TIP1O
               WHEN 2
                   MOVE USU-ID       TO USR-ID2O
                   MOVE USU-NOMBRE   TO USR-NOM2O
                   MOVE USU-APELLIDO TO USR-APE2O
                   MOVE USU-EMAIL    TO USR-MAI2O
                   MOVE USU-TIPO     TO USR-TIP2O
               WHEN 3
                   MOVE USU-ID       TO USR-ID3O
                   MOVE USU-NOMBRE   TO USR-NOM3O
                   MOVE USU-APELLIDO TO USR-APE3O
                   MOVE USU-EMAIL    TO USR-MAI3O
                   MOVE USU-TIPO     TO USR-TIP3O
               WHEN 4
                   MOVE USU-ID       TO USR-ID4O
                   MOVE USU-NOMBRE   TO USR-NOM4O
                   MOVE USU-APELLIDO TO USR-APE4O
                   MOVE USU-EMAIL    TO USR-MAI4O
                   MOVE USU-TIPO     TO USR-TIP4O
               WHEN 5
                   MOVE USU-ID       TO USR-ID5O
                   MOVE USU-NOMBRE   TO USR-NOM5O
                   MOVE USU-APELLIDO TO USR-APE5O
                   MOVE USU-EMAIL    TO USR-MAI5O
                   MOVE USU-TIPO     TO USR-TIP5O
               WHEN 6
                   MOVE USU-ID       TO USR-ID6O
                   MOVE USU-NOMBRE   TO USR-NOM6O
                   MOVE USU-APELLIDO TO USR-APE6O
                   MOVE USU-EMAIL    TO USR-MAI6O
                   MOVE USU-TIPO     TO USR-TIP6O
               WHEN 7
                   MOVE USU-ID       TO USR-ID7O
                   MOVE USU-NOMBRE   TO USR-NOM7O
                   MOVE USU-APELLIDO TO USR-APE7O
                   MOVE USU-EMAIL    TO USR-MAI7O
                   MOVE USU-TIPO     TO USR-TIP7O
               WHEN 8
                   MOVE USU-ID       TO USR-ID8O
                   MOVE USU-NOMBRE   TO USR-NOM8O
                   MOVE USU-APELLIDO TO USR-APE8O
                   MOVE USU-EMAIL    TO USR-MAI8O
                   MOVE USU-TIPO     TO USR-TIP8O
               WHEN 9
                   MOVE USU-ID       TO USR-ID9O
                   MOVE USU-NOMBRE   TO USR-NOM9O
                   MOVE USU-APELLIDO TO USR-APE9O
                   MOVE USU-EMAIL    TO USR-MAI9O
                   MOVE USU-TIPO     TO USR-TIP9O
               WHEN 10
                   MOVE USU-ID       TO USR-ID10O
                   MOVE USU-NOMBRE   TO USR-NOM10O
                   MOVE USU-APELLIDO TO USR-APE10O
                   MOVE USU-EMAIL    TO USR-MAI10O
                   MOVE USU-TIPO     TO USR-TIP10O
           END-EVALUATE.

       CERRAR-BROWSE.
           EXEC CICS ENDBR
               FILE('USUDS')
               RESP(WS-RESP)
           END-EXEC.

       VOLVER-MENU.
           EXEC CICS XCTL
               PROGRAM('UMENUP')
           END-EXEC.
