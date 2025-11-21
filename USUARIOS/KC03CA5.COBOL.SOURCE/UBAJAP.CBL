       IDENTIFICATION DIVISION.
       PROGRAM-ID. UBAJAP.
      ******************************************************************
      * PROGRAMA: UBAJAP - ELIMINACION DE USUARIOS                     *
      * DESCRIPCION: Permite buscar y eliminar un usuario por ID       *
      * TRANSACCION: UBAJ (pseudo-conversacional independiente)        *
      * MAPSET: UBAJAM                                                 *
      ******************************************************************

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *---- Copybooks CICS ----
       COPY DFHAID.
       COPY DFHBMSCA.

      *---- Copia del mapa ----
       COPY UBAJAM.

      *---- Copia de la estructura de usuario ----
       COPY USUARIO.

      *---- Variables de trabajo ----
       01  WS-VARIABLES.
           05  WS-RESP                PIC S9(8) COMP.
           05  WS-RESP2               PIC S9(8) COMP.
           05  WS-ID-TEMP             PIC X(10).
           05  WS-TIPO-DESC           PIC X(30).

      *---- Indicador de estado ----
       01  WS-ESTADO-USUARIO          PIC X(01) VALUE 'N'.
           88  USUARIO-ENCONTRADO               VALUE 'S'.
           88  USUARIO-NO-ENCONTRADO            VALUE 'N'.

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

      *---- Retornar con transacción UBAJ ----
           EXEC CICS RETURN TRANSID('UBAJ') COMMAREA(WS-PRIMERA-VEZ)
               LENGTH(1)
           END-EXEC.

       ENVIAR-MAPA-INICIAL.
      *---- Limpiar solo el area de entrada ----
           MOVE LOW-VALUES TO UBAJAMI.

      *---- Limpiar campos variables ----
           MOVE SPACES TO MMENSAJEO MADVERTO MNOMINPO MAPEINPO
                          MMAILINPO.
           MOVE SPACE TO MTIPOINPO.

      *---- Mensaje inicial ----
           MOVE 'Ingrese ID del usuario a eliminar' TO MMENSAJEO.

      *---- Posicionar cursor en campo ID ----
           MOVE -1 TO MIDINPL.

      *---- Enviar mapa completo con ERASE ----
           EXEC CICS SEND MAP('UBAJAM') MAPSET('UBAJAM') ERASE CURSOR
           END-EXEC.

      *---- Marcar que ya no es la primera vez ----
           SET NO-ES-PRIMERA-VEZ TO TRUE.

       PROCESAR-ENTRADA.
      *---- Recibir datos del mapa ----
           EXEC CICS RECEIVE MAP('UBAJAM') MAPSET('UBAJAM')
                     RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC.

      *---- Verificar PF3 y PF2/CLEAR PRIMERO ----
           IF EIBAID = DFHPF3
               PERFORM VOLVER-MENU
               EXIT PARAGRAPH
           END-IF.

           IF EIBAID = DFHPF2 OR EIBAID = DFHCLEAR
               PERFORM LIMPIAR-PANTALLA
               EXIT PARAGRAPH
           END-IF.

      *---- Procesar ENTER y PF5 ----
           EVALUATE TRUE
      *---- CASO 1: RECEIVE fue NORMAL ----
              WHEN WS-RESP = DFHRESP(NORMAL)
                 EVALUATE TRUE
                     WHEN EIBAID = DFHENTER
                       PERFORM BUSCAR-USUARIO
                     WHEN EIBAID = DFHPF5
                       PERFORM ELIMINAR-USUARIO
                     WHEN OTHER
                      MOVE 'Tecla invalida. Use ENTER,PF2,PF3,PF5'
                          TO MMENSAJEO
                      PERFORM ENVIAR-MAPA-ERROR
                 END-EVALUATE

      *---- CASO 2: RECEIVE fue INVREQ (campos protegidos) ----
               WHEN WS-RESP = DFHRESP(INVREQ)
                   EVALUATE TRUE
                       WHEN EIBAID = DFHENTER
                           IF WS-ID-TEMP NOT = SPACES
                               MOVE WS-ID-TEMP TO MIDINPI
                               PERFORM BUSCAR-USUARIO
                           ELSE
                               MOVE 'ERROR: Debe ingresar un ID primero'
                                   TO MMENSAJEO
                               PERFORM ENVIAR-MAPA-ERROR
                           END-IF
                       WHEN EIBAID = DFHPF5
                           PERFORM ELIMINAR-USUARIO
                       WHEN OTHER
                           MOVE 'Tecla invalida. Use ENTER,PF2,PF3,PF5'
                               TO MMENSAJEO
                           PERFORM ENVIAR-MAPA-ERROR
                   END-EVALUATE

      *---- CASO 3: Otros errores ----
               WHEN OTHER
                   MOVE 'ERROR al recibir datos del mapa'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       BUSCAR-USUARIO.
      *---- Validar que se ingresó un ID ----
           IF MIDINPL = 0 OR MIDINPL = -1
              MOVE 'ERROR: Debe ingresar un ID para buscar' TO MMENSAJEO
              PERFORM ENVIAR-MAPA-ERROR
              EXIT PARAGRAPH
           END-IF.

      *---- Validar que el ID no sea espacios ----
           IF MIDINPI = SPACES
               MOVE 'ERROR: ID no puede estar vacio' TO MMENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Preparar clave ----
           MOVE MIDINPI TO USU-ID.

      *---- Leer registro ----
           EXEC CICS READ
               FILE('USUDS')
               INTO(REG-USUARIO)
               RIDFLD(USU-ID)
               RESP(WS-RESP)
           END-EXEC.

      *---- Evaluar resultado ----
           EVALUATE WS-RESP
               WHEN DFHRESP(NORMAL)
                   PERFORM MOSTRAR-USUARIO-ENCONTRADO
               WHEN DFHRESP(NOTFND)
                   PERFORM MOSTRAR-USUARIO-NO-ENCONTRADO
               WHEN DFHRESP(DISABLED)
                   MOVE 'ERROR: Archivo USUDS deshabilitado en CICS'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN DFHRESP(NOTOPEN)
                   MOVE 'ERROR: Archivo USUDS no esta abierto'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN OTHER
                   MOVE 'ERROR al leer archivo VSAM' TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       MOSTRAR-USUARIO-ENCONTRADO.
      *---- Cargar datos del usuario ----
           MOVE USU-NOMBRE   TO MNOMINPO.
           MOVE USU-APELLIDO TO MAPEINPO.
           MOVE USU-EMAIL    TO MMAILINPO.
           MOVE USU-TIPO     TO MTIPOINPO.

      *---- Guardar ID en variable temporal ----
           MOVE MIDINPI TO WS-ID-TEMP.
           MOVE WS-ID-TEMP TO MIDINPO.

      *---- Marcar usuario encontrado ----
           SET USUARIO-ENCONTRADO TO TRUE.

      *---- Mensaje de advertencia en ROJO ----
           MOVE 'ADVERTENCIA: Presione PF5 para ELIMINAR este usuario'
               TO MADVERTO.

           MOVE 'Usuario encontrado. Verifique datos antes de eliminar'
               TO MMENSAJEO.

      *---- Proteger campo ID ----
           MOVE DFHBMPRO TO MIDINPA.

      *---- Enviar solo datos ----
           MOVE -1 TO MIDINPL.
           EXEC CICS SEND MAP('UBAJAM') MAPSET('UBAJAM') DATAONLY CURSOR
           END-EXEC.

       MOSTRAR-USUARIO-NO-ENCONTRADO.
      *---- Limpiar campos de datos ----
           MOVE SPACES TO MNOMINPO MAPEINPO MMAILINPO MADVERTO.
           MOVE SPACE TO MTIPOINPO.
           MOVE 'Usuario no encontrado en el sistema' TO MMENSAJEO.

      *---- Mantener ID ingresado ----
           MOVE MIDINPI TO WS-ID-TEMP.
           MOVE WS-ID-TEMP TO MIDINPO.

      *---- Marcar usuario no encontrado ----
           SET USUARIO-NO-ENCONTRADO TO TRUE.

      *---- Enviar mapa con mensaje ----
           MOVE -1 TO MIDINPL.
           EXEC CICS SEND MAP('UBAJAM') MAPSET('UBAJAM') DATAONLY
               CURSOR ALARM
           END-EXEC.

       ELIMINAR-USUARIO.
      *---- Validar que haya un ID guardado ----
           IF WS-ID-TEMP = SPACES
               MOVE 'ERROR: Debe buscar un usuario primero (ENTER)'
                   TO MMENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Usar ID guardado ----
           MOVE WS-ID-TEMP TO USU-ID.

      *---- Leer registro con UPDATE para eliminarlo ----
           EXEC CICS READ FILE('USUDS') INTO(REG-USUARIO)
              RIDFLD(USU-ID) UPDATE RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR: No se pudo leer el usuario para eliminar'
                   TO MMENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Ejecutar DELETE ----
           EXEC CICS DELETE FILE('USUDS') RESP(WS-RESP)
           END-EXEC.

      *---- Evaluar resultado ----
           EVALUATE WS-RESP
               WHEN DFHRESP(NORMAL)
                   PERFORM CONFIRMAR-ELIMINACION
               WHEN DFHRESP(NOTFND)
                   MOVE 'ERROR: Usuario no encontrado para eliminar'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN DFHRESP(INVREQ)
                   MOVE 'ERROR: DELETE sin READ UPDATE previo'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN OTHER
                   MOVE 'ERROR al eliminar usuario de VSAM'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       CONFIRMAR-ELIMINACION.
      *---- Limpiar campos después de eliminar ----
           MOVE SPACES TO MNOMINPO MAPEINPO MMAILINPO MADVERTO MIDINPO.
           MOVE SPACE TO MTIPOINPO.
           MOVE SPACES TO WS-ID-TEMP.

      *---- Mensaje de éxito ----
           MOVE 'Usuario eliminado exitosamente. Use PF2 para limpiar'
               TO MMENSAJEO.

      *---- Desproteger campo ID para nueva búsqueda ----
           MOVE DFHBMUNP TO MIDINPA.

           MOVE -1 TO MIDINPL.
           EXEC CICS SEND MAP('UBAJAM') MAPSET('UBAJAM') DATAONLY CURSOR
           END-EXEC.

       LIMPIAR-PANTALLA.
      *---- Limpiar todos los campos ----
           MOVE SPACES TO MIDINPO MNOMINPO MAPEINPO MMAILINPO MADVERTO.
           MOVE SPACE TO MTIPOINPO.
           MOVE SPACES TO WS-ID-TEMP.

      *---- Desproteger campo ID ----
           MOVE DFHBMUNP TO MIDINPA.

           MOVE 'Pantalla limpia. Ingrese nuevo ID y presione ENTER'
               TO MMENSAJEO.

           MOVE -1 TO MIDINPL.

           EXEC CICS SEND MAP('UBAJAM') MAPSET('UBAJAM') DATAONLY
              CURSOR
           END-EXEC.

      *---- Reenviar mapa con mensaje de error ----
       ENVIAR-MAPA-ERROR.
           MOVE -1 TO MIDINPL.

           EXEC CICS SEND MAP('UBAJAM') MAPSET('UBAJAM') DATAONLY
              CURSOR ALARM
           END-EXEC.

      *---- Transferir control al menú ----
       VOLVER-MENU.
           EXEC CICS XCTL PROGRAM('UMENUP')
           END-EXEC.
