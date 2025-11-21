       IDENTIFICATION DIVISION.
       PROGRAM-ID. UALTAP.
      ******************************************************************
      * PROGRAMA: UALTAP - ALTA DE USUARIOS                            *
      * DESCRIPCION: Permite dar de alta un nuevo usuario              *
      * TRANSACCION: UALT (pseudo-conversacional independiente)        *
      * MAPSET: UALTAM                                                 *
      ******************************************************************

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *---- Copybooks CICS ----
       COPY DFHAID.
       COPY DFHBMSCA.

      *---- Copia del mapa ----
       COPY UALTAM.

      *---- Copia de la estructura de usuario ----
       COPY USUARIO.

      *---- Variables de trabajo ----
       01  WS-VARIABLES.
           05  WS-RESP                PIC S9(8) COMP.
           05  WS-RESP2               PIC S9(8) COMP.
           05  WS-ULTIMO-ID           PIC 9(10) VALUE ZERO.
           05  WS-NUEVO-ID            PIC 9(10) VALUE ZERO.
           05  WS-EMAIL-TEMP          PIC X(50).
           05  WS-EMAIL-INPUT         PIC X(50).
           05  WS-ID-DISPLAY          PIC Z(9)9.

      *---- Registro temporal para busqueda de email ----
       01  REG-TEMP.
           05  TEMP-ID                PIC 9(10).
           05  TEMP-NOMBRE            PIC X(30).
           05  TEMP-APELLIDO          PIC X(30).
           05  TEMP-EMAIL             PIC X(50).
           05  TEMP-TIPO              PIC X(1).
           05  FILLER                 PIC X(79).

      *---- Indicador de primera ejecución ----
       01  WS-PRIMERA-VEZ             PIC X(01) VALUE 'Y'.
           88  ES-PRIMERA-VEZ                   VALUE 'Y'.
           88  NO-ES-PRIMERA-VEZ                VALUE 'N'.

      *---- Control de browse para email ----
       01  WS-EMAIL-ENCONTRADO        PIC X VALUE 'N'.
           88  EMAIL-YA-EXISTE                  VALUE 'S'.
           88  EMAIL-DISPONIBLE                 VALUE 'N'.

       LINKAGE SECTION.
       01  DFHCOMMAREA                PIC X(01).

       PROCEDURE DIVISION.

       MAIN-PROCESS.
      *---- Verificar si es la primera vez ----
           IF EIBCALEN = ZERO
               SET ES-PRIMERA-VEZ TO TRUE
      *---- Obtener ID disponible ANTES de mostrar pantalla ----
               PERFORM OBTENER-NUEVO-ID
               PERFORM ENVIAR-MAPA-INICIAL
           ELSE
               MOVE DFHCOMMAREA TO WS-PRIMERA-VEZ
               PERFORM PROCESAR-ENTRADA
           END-IF.

      *---- Retornar con transacción UALT para quedar en alta ----
           EXEC CICS RETURN TRANSID('UALT') COMMAREA(WS-PRIMERA-VEZ)
               LENGTH(1)
           END-EXEC.

       ENVIAR-MAPA-INICIAL.
      *---- Limpiar el área de entrada ----
           MOVE LOW-VALUES TO UALTAMI.

      *---- Formatear y mostrar el ID que se asignara ----
           MOVE WS-NUEVO-ID TO WS-ID-DISPLAY.
           MOVE WS-ID-DISPLAY TO LIDVALO.

      *---- Limpiar mensaje ----
           MOVE SPACES TO LMENSAJEO.

      *---- Mensaje inicial con ID visible ----
           STRING 'Proximo ID disponible: ' WS-ID-DISPLAY
               '. Complete los datos del usuario'
               DELIMITED BY SIZE INTO LMENSAJEO
           END-STRING.

      *---- Posicionar cursor en campo NOMBRE ----
           MOVE -1 TO LNOMINPL.

      *---- Enviar mapa completo con ERASE ----
           EXEC CICS SEND MAP('UALTAM') MAPSET('UALTAM') ERASE CURSOR
           END-EXEC.

      *---- Marcar que ya no es la primera vez ----
           SET NO-ES-PRIMERA-VEZ TO TRUE.

       PROCESAR-ENTRADA.
      *---- Recibir datos del mapa ----
           EXEC CICS RECEIVE MAP('UALTAM') MAPSET('UALTAM') RESP(WS-RESP)
           END-EXEC.

      *---- Verificar si hubo error en RECEIVE ----
           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR al recibir datos del mapa' TO LMENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Verificar teclas de atención ----
           EVALUATE TRUE
               WHEN EIBAID = DFHPF3
                   PERFORM VOLVER-MENU
               WHEN EIBAID = DFHCLEAR
                   PERFORM LIMPIAR-FORMULARIO
               WHEN EIBAID = DFHENTER
                   PERFORM PROCESAR-ALTA
               WHEN OTHER
                   MOVE 'Tecla no valida. Use ENTER, CLEAR o PF3'
                       TO LMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       PROCESAR-ALTA.
      *---- Validar campos ----
           PERFORM VALIDAR-CAMPOS.

      *---- Si hay error, salir SIN CAMBIAR EL ID ----
           IF LMENSAJEO NOT = SPACES AND LMENSAJEO NOT = LOW-VALUES
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Verificar si el email ya existe ----
           PERFORM VERIFICAR-EMAIL-UNICO.

           IF EMAIL-YA-EXISTE
               MOVE 'ERROR: El email ya esta registrado en el sistema'
                   TO LMENSAJEO
      *---- Salir SIN CAMBIAR EL ID ----
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- El ID ya fue obtenido previamente, verificar que siga siendo valido
           IF WS-NUEVO-ID = ZERO
               PERFORM OBTENER-NUEVO-ID
               IF WS-NUEVO-ID = ZERO
                   MOVE 'ERROR: No se pudo generar ID'
                       TO LMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
                   EXIT PARAGRAPH
               END-IF
           END-IF.

      *---- Grabar usuario con el ID mostrado ----
           PERFORM GRABAR-USUARIO.

       VALIDAR-CAMPOS.
           MOVE SPACES TO LMENSAJEO.

      *---- Validar NOMBRE ----
           IF LNOMINPL = 0 OR LNOMINPL = -1
               MOVE 'ERROR: NOMBRE es obligatorio' TO LMENSAJEO
               EXIT PARAGRAPH
           END-IF.

           IF LNOMINPI = SPACES
               MOVE 'ERROR: NOMBRE no puede estar vacio' TO LMENSAJEO
               EXIT PARAGRAPH
           END-IF.

      *---- Validar APELLIDO ----
           IF LAPEINPL = 0 OR LAPEINPL = -1
               MOVE 'ERROR: APELLIDO es obligatorio' TO LMENSAJEO
               EXIT PARAGRAPH
           END-IF.

           IF LAPEINPI = SPACES
               MOVE 'ERROR: APELLIDO no puede estar vacio' TO LMENSAJEO
               EXIT PARAGRAPH
           END-IF.

      *---- Validar EMAIL ----
           IF LMAILINPL = 0 OR LMAILINPL = -1
               MOVE 'ERROR: EMAIL es obligatorio' TO LMENSAJEO
               EXIT PARAGRAPH
           END-IF.

           IF LMAILINPI = SPACES
               MOVE 'ERROR: EMAIL no puede estar vacio' TO LMENSAJEO
               EXIT PARAGRAPH
           END-IF.

      *---- Validar TIPO ----
           IF LTIPOINPL = 0 OR LTIPOINPL = -1
               MOVE 'ERROR: TIPO es obligatorio' TO LMENSAJEO
               EXIT PARAGRAPH
           END-IF.

           IF LTIPOINPI NOT = 'A' AND
              LTIPOINPI NOT = 'D' AND
              LTIPOINPI NOT = 'E'
               MOVE 'ERROR: TIPO debe ser A, D o E.'
                   TO LMENSAJEO
               EXIT PARAGRAPH
           END-IF.

       VERIFICAR-EMAIL-UNICO.
      *---- Iniciar browse desde el principio ----
           MOVE ZERO TO TEMP-ID.
           SET EMAIL-DISPONIBLE TO TRUE.

           EXEC CICS STARTBR FILE('USUDS') RIDFLD(TEMP-ID)
              KEYLENGTH(10) GTEQ RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
      *---- Si no hay registros, el email esta disponible ----
               SET EMAIL-DISPONIBLE TO TRUE
               EXIT PARAGRAPH
           END-IF.

      *---- Normalizar email ingresado para comparacion ----
           MOVE SPACES TO WS-EMAIL-INPUT.
           MOVE LMAILINPI TO WS-EMAIL-INPUT.
           INSPECT WS-EMAIL-INPUT CONVERTING
               'abcdefghijklmnopqrstuvwxyz' TO
               'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.

      *---- Recorrer archivo buscando email duplicado ----
           PERFORM UNTIL WS-RESP NOT = DFHRESP(NORMAL)
              EXEC CICS READNEXT FILE('USUDS') INTO(REG-TEMP)
                 RIDFLD(TEMP-ID) KEYLENGTH(10) RESP(WS-RESP)
              END-EXEC

               IF WS-RESP = DFHRESP(NORMAL)
      *---- Normalizar email del registro ----
                   MOVE TEMP-EMAIL TO WS-EMAIL-TEMP
                   INSPECT WS-EMAIL-TEMP CONVERTING
                       'abcdefghijklmnopqrstuvwxyz' TO
                       'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      *---- Comparar emails (case insensitive) ----
                   IF WS-EMAIL-TEMP = WS-EMAIL-INPUT
                       SET EMAIL-YA-EXISTE TO TRUE
                       PERFORM CERRAR-BROWSE-EMAIL
                       EXIT PARAGRAPH
                   END-IF
               END-IF
           END-PERFORM.

      *---- Cerrar browse ----
           PERFORM CERRAR-BROWSE-EMAIL.
           SET EMAIL-DISPONIBLE TO TRUE.

       CERRAR-BROWSE-EMAIL.
           EXEC CICS ENDBR FILE('USUDS') RESP(WS-RESP)
           END-EXEC.

       OBTENER-NUEVO-ID.
      *---- Iniciar en ZERO para leer todos los registros ----
           MOVE ZERO TO WS-ULTIMO-ID.
           MOVE ZERO TO WS-NUEVO-ID.

           EXEC CICS STARTBR FILE('USUDS') RIDFLD(WS-ULTIMO-ID)
              KEYLENGTH(10) GTEQ RESP(WS-RESP)
           END-EXEC.

      *---- Si archivo vacio, comenzar en 1 ----
           IF WS-RESP = DFHRESP(NOTFND) OR
              WS-RESP = DFHRESP(ENDFILE)
               MOVE 1 TO WS-NUEVO-ID
               EXIT PARAGRAPH
           END-IF.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 1 TO WS-NUEVO-ID
               EXIT PARAGRAPH
           END-IF.

      *---- Recorrer hasta encontrar el ultimo registro ----
           PERFORM UNTIL WS-RESP NOT = DFHRESP(NORMAL)
              EXEC CICS READNEXT FILE('USUDS') INTO(REG-USUARIO)
                 RIDFLD(WS-ULTIMO-ID) KEYLENGTH(10) RESP(WS-RESP)
              END-EXEC

              IF WS-RESP = DFHRESP(NORMAL)
                 MOVE USU-ID TO WS-ULTIMO-ID
              END-IF
           END-PERFORM.

      *---- Cerrar browse ----
           EXEC CICS ENDBR FILE('USUDS') RESP(WS-RESP2)
           END-EXEC.

      *---- Incrementar el ultimo ID encontrado ----
           IF WS-ULTIMO-ID > ZERO
               COMPUTE WS-NUEVO-ID = WS-ULTIMO-ID + 1
           ELSE
               MOVE 1 TO WS-NUEVO-ID
           END-IF.

       GRABAR-USUARIO.
      *---- Mover datos del mapa a la estructura VSAM ----
           MOVE WS-NUEVO-ID TO USU-ID.
           MOVE LNOMINPI  TO USU-NOMBRE.
           MOVE LAPEINPI  TO USU-APELLIDO.
           MOVE LMAILINPI TO USU-EMAIL.
           MOVE LTIPOINPI TO USU-TIPO.

      *---- Grabar en VSAM ----
           EXEC CICS WRITE FILE('USUDS') FROM(REG-USUARIO)
               RIDFLD(USU-ID) KEYLENGTH(10) RESP(WS-RESP)
           END-EXEC.

      *---- Evaluar resultado ----
           EVALUATE WS-RESP
               WHEN DFHRESP(NORMAL)
      *---- Guardar ID grabado para mensaje ----
                   MOVE WS-NUEVO-ID TO WS-ID-DISPLAY
      *---- Obtener el SIGUIENTE ID para la proxima alta ----
                   PERFORM OBTENER-NUEVO-ID
      *---- Formatear NUEVO ID para display ----
                   MOVE WS-NUEVO-ID TO WS-ID-DISPLAY
                   MOVE WS-ID-DISPLAY TO LIDVALO
      *---- Mensaje de exito con ID grabado (no el nuevo) ----
                   COMPUTE WS-ULTIMO-ID = WS-NUEVO-ID - 1
                   MOVE WS-ULTIMO-ID TO WS-ID-DISPLAY
                   STRING
                       'Usuario creado exitosamente con ID: '
                       WS-ID-DISPLAY
                       DELIMITED BY SIZE
                       INTO LMENSAJEO
                   END-STRING
                   PERFORM ENVIAR-MAPA-EXITO
               WHEN DFHRESP(DUPREC)
      *---- ID duplicado - Obtener nuevo ID ----
                   PERFORM OBTENER-NUEVO-ID
                   MOVE WS-NUEVO-ID TO WS-ID-DISPLAY
                   MOVE WS-ID-DISPLAY TO LIDVALO
                   MOVE 'ID duplicado. Nuevo ID obtenido. Reintente'
                       TO LMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN DFHRESP(DISABLED)
                   MOVE 'ERROR: Archivo USUDS deshabilitado en CICS'
                       TO LMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN DFHRESP(NOTOPEN)
                   MOVE 'ERROR: Archivo USUDS no esta abierto'
                       TO LMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN OTHER
                   MOVE 'ERROR al grabar usuario en VSAM'
                       TO LMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       LIMPIAR-FORMULARIO.
      *---- Obtener ID actualizado ----
           PERFORM OBTENER-NUEVO-ID.

      *---- Formatear ID para display ----
           MOVE WS-NUEVO-ID TO WS-ID-DISPLAY.
           MOVE WS-ID-DISPLAY TO LIDVALO.

      *---- Limpiar campos de entrada ----
           MOVE SPACES TO LNOMINPO LAPEINPO LMAILINPO LTIPOINPO.

      *---- Mensaje actualizado ----
           STRING 'Formulario limpio. Proximo ID: ' WS-ID-DISPLAY
               DELIMITED BY SIZE INTO LMENSAJEO
           END-STRING.

      *---- Posicionar cursor en NOMBRE ----
           MOVE -1 TO LNOMINPL.

      *---- Enviar solo datos ----
           EXEC CICS SEND MAP('UALTAM') MAPSET('UALTAM') DATAONLY CURSOR
           END-EXEC.

       ENVIAR-MAPA-EXITO.
      *---- El ID ya fue actualizado en GRABAR-USUARIO ----
      *---- NO volver a tocar LIDVALO aqui ----

      *---- Limpiar campos para nuevo usuario ----
           MOVE SPACES TO LNOMINPO LAPEINPO LMAILINPO LTIPOINPO.

      *---- Posicionar cursor en NOMBRE ----
           MOVE -1 TO LNOMINPL.

           EXEC CICS SEND MAP('UALTAM') MAPSET('UALTAM') DATAONLY CURSOR
           END-EXEC.

      *---- NO TOCAR LIDVALO - Mantener el ID que ya esta en pantalla ----
      *---- Solo reenviar con mensaje de error ----
       ENVIAR-MAPA-ERROR.

      *---- Reenviar mapa con mensaje de error ----
           MOVE -1 TO LNOMINPL.

           EXEC CICS SEND MAP('UALTAM') MAPSET('UALTAM') DATAONLY
              CURSOR ALARM
           END-EXEC.

      *---- Transferir control de vuelta al menú ----
       VOLVER-MENU.
           EXEC CICS XCTL PROGRAM('UMENUP') END-EXEC.
