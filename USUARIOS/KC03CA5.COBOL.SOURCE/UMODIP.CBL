       IDENTIFICATION DIVISION.
       PROGRAM-ID. UMODIP.
      ******************************************************************
      * PROGRAMA: UMODIP - MODIFICACION DE USUARIOS                    *
      * DESCRIPCION: Permite buscar y modificar un usuario por ID      *
      * TRANSACCION: UMOD (pseudo-conversacional independiente)        *
      * MAPSET: UMODIM                                                 *
      ******************************************************************

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *---- Copybooks CICS ----
       COPY DFHAID.
       COPY DFHBMSCA.

      *---- Copia del mapa ----
       COPY UMODIM.

      *---- Copia de la estructura de usuario ----
       COPY USUARIO.

      *---- Variables de trabajo ----
       01  WS-VARIABLES.
           05  WS-RESP                PIC S9(8) COMP.
           05  WS-RESP2               PIC S9(8) COMP.
           05  WS-ID-TEMP             PIC X(10).
           05  WS-EMAIL-TEMP          PIC X(50).
           05  WS-EMAIL-INPUT         PIC X(50).
           05  WS-EMAIL-ORIGINAL      PIC X(50).

      *---- Registro temporal para busqueda de email ----
       01  REG-TEMP.
           05  TEMP-ID                PIC 9(10).
           05  TEMP-NOMBRE            PIC X(30).
           05  TEMP-APELLIDO          PIC X(30).
           05  TEMP-EMAIL             PIC X(50).
           05  TEMP-TIPO              PIC X(1).
           05  FILLER                 PIC X(79).

      *---- Control de email ----
       01  WS-EMAIL-ENCONTRADO        PIC X VALUE 'N'.
           88  EMAIL-YA-EXISTE                  VALUE 'S'.
           88  EMAIL-DISPONIBLE                 VALUE 'N'.

      *---- Indicador de primera ejecución ----
       01  WS-PRIMERA-VEZ             PIC X(01) VALUE 'Y'.
           88  ES-PRIMERA-VEZ                   VALUE 'Y'.
           88  NO-ES-PRIMERA-VEZ                VALUE 'N'.

       LINKAGE SECTION.
       01  DFHCOMMAREA                PIC X(01).

       PROCEDURE DIVISION.

       MAIN-PROCESS.
      *---- IGUAL QUE UCONSP: Verificar si es la primera vez ----
           IF EIBCALEN = ZERO
               SET ES-PRIMERA-VEZ TO TRUE
               PERFORM ENVIAR-MAPA-INICIAL
           ELSE
               MOVE DFHCOMMAREA TO WS-PRIMERA-VEZ
               PERFORM PROCESAR-ENTRADA
           END-IF.

      *---- IGUAL QUE UCONSP: Retornar con transacción UMOD ----
           EXEC CICS RETURN TRANSID('UMOD') COMMAREA(WS-PRIMERA-VEZ)
               LENGTH(1)
           END-EXEC.

       ENVIAR-MAPA-INICIAL.
      *---- IGUAL QUE UCONSP: Limpiar solo el area de entrada ----
           MOVE LOW-VALUES TO UMODIMI.

      *---- Limpiar solo campos variables (datos del usuario) ----
           MOVE SPACES TO MMENSAJEO MNOMINPO MAPEINPO MMAILINPO.
           MOVE SPACE TO MTIPOINPO.

      *---- Mensaje inicial con nueva instrucción PF2 ----
           MOVE 'Ingrese ID y presione ENTER. Use PF2 para limpiar'
               TO MMENSAJEO.

      *---- Posicionar cursor en campo ID ----
           MOVE -1 TO MIDINPL.

      *---- IGUAL QUE UCONSP: Enviar mapa completo con ERASE ----
           EXEC CICS SEND MAP('UMODIM') MAPSET('UMODIM') ERASE CURSOR
           END-EXEC.

      *---- Marcar que ya no es la primera vez ----
           SET NO-ES-PRIMERA-VEZ TO TRUE.

       PROCESAR-ENTRADA.
      *---- Recibir datos del mapa ----
           EXEC CICS RECEIVE MAP('UMODIM') MAPSET('UMODIM')
               RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC.

      *---- Verificar PF3 y PF2/CLEAR PRIMERO (no necesitan RECEIVE) ----
           IF EIBAID = DFHPF3
               PERFORM VOLVER-MENU
               EXIT PARAGRAPH
           END-IF.

           IF EIBAID = DFHPF2 OR EIBAID = DFHCLEAR
               PERFORM LIMPIAR-PANTALLA
               EXIT PARAGRAPH
           END-IF.

      *---- Ahora procesar ENTER y PF5 ----
      *---- Ambos pueden tener INVREQ si los campos están protegidos ----

           EVALUATE TRUE
      *------------------------------------------------------------
      *---- CASO 1: RECEIVE fue NORMAL (campos desprotegidos) ----
      *------------------------------------------------------------
               WHEN WS-RESP = DFHRESP(NORMAL)
                   EVALUATE TRUE
                       WHEN EIBAID = DFHENTER
                           PERFORM BUSCAR-USUARIO
                       WHEN EIBAID = DFHPF5
                           PERFORM MODIFICAR-USUARIO
                       WHEN OTHER
                           MOVE 'Tecla invalida. Use ENTER,PF2,PF3,PF5'
                               TO MMENSAJEO
                           PERFORM ENVIAR-MAPA-ERROR
                   END-EVALUATE

      *------------------------------------------------------------
      *---- CASO 2: RECEIVE fue INVREQ (campos protegidos) ----
      *---- Esto es NORMAL después de buscar un usuario ----
      *------------------------------------------------------------
               WHEN WS-RESP = DFHRESP(INVREQ)
                   EVALUATE TRUE
      *---- ENTER con INVREQ: Re-buscar con ID guardado ----
                       WHEN EIBAID = DFHENTER
                           IF WS-ID-TEMP NOT = SPACES
                               MOVE WS-ID-TEMP TO MIDINPI
                               PERFORM BUSCAR-USUARIO
                           ELSE
                               MOVE 'ERROR: Debe ingresar un ID primero'
                                   TO MMENSAJEO
                               PERFORM ENVIAR-MAPA-ERROR
                           END-IF

      *---- PF5 con INVREQ: Modificar usuario ----
      *---- MODIFICAR-USUARIO validará si hay cambios ----
                       WHEN EIBAID = DFHPF5
                           PERFORM MODIFICAR-USUARIO

      *---- Otras teclas con INVREQ ----
                       WHEN OTHER
                           MOVE 'Tecla invalida. Use ENTER,PF2,PF3,PF5'
                               TO MMENSAJEO
                           PERFORM ENVIAR-MAPA-ERROR
                   END-EVALUATE

      *------------------------------------------------------------
      *---- CASO 3: Otros errores de RECEIVE (realmente errores) ----
      *------------------------------------------------------------
               WHEN OTHER
                   MOVE 'ERROR al recibir datos del mapa'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       BUSCAR-USUARIO.
      *---- EXACTAMENTE IGUAL QUE UCONSP ----
      *---- Validar que se ingresó un ID ----
           IF MIDINPL = 0 OR MIDINPL = -1
               MOVE 'ERROR: Debe ingresar un ID para buscar'
                   TO MMENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Validar que el ID no sea espacios ----
           IF MIDINPI = SPACES
               MOVE 'ERROR: ID no puede estar vacio'
                   TO MMENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- EXACTAMENTE IGUAL QUE UCONSP: Preparar clave ----
           MOVE MIDINPI TO USU-ID.

      *---- Leer registro usando EXEC CICS READ ----
           EXEC CICS READ FILE('USUDS') INTO(REG-USUARIO)
              RIDFLD(USU-ID) RESP(WS-RESP)
           END-EXEC.

      *---- Evaluar resultado de la lectura ----
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
      *---- Cargar datos del usuario en el mapa ----
           MOVE USU-NOMBRE   TO MNOMINPO.
           MOVE USU-APELLIDO TO MAPEINPO.
           MOVE USU-EMAIL    TO MMAILINPO.
           MOVE USU-TIPO     TO MTIPOINPO.

      *---- Guardar email original para validacion posterior ----
           MOVE USU-EMAIL TO WS-EMAIL-ORIGINAL.

      *---- IGUAL QUE UCONSP: Proteger el campo ID para mostrar ----
           MOVE MIDINPI TO WS-ID-TEMP.
           MOVE WS-ID-TEMP TO MIDINPO.

      *---- NUEVO: Desproteger campos para permitir modificacion ----
           MOVE DFHBMUNP TO MNOMINPA MAPEINPA MMAILINPA MTIPOINPA.

      *---- NUEVO: Proteger campo ID (no se modifica) ----
           MOVE DFHBMPRO TO MIDINPA.

      *---- Mensaje actualizado con PF2 ----
           MOVE 'Usuario encontrado. Modifique y PF5=Grabar, PF2=Nuevo'
               TO MMENSAJEO.

      *---- IGUAL QUE UCONSP: Enviar solo los datos ----
           MOVE -1 TO MNOMINPL.
           EXEC CICS SEND MAP('UMODIM') MAPSET('UMODIM') DATAONLY CURSOR
           END-EXEC.

       MOSTRAR-USUARIO-NO-ENCONTRADO.
      *---- Limpiar campos de datos ----
           MOVE SPACES TO MNOMINPO MAPEINPO MMAILINPO.
           MOVE SPACE TO MTIPOINPO.
           MOVE 'Usuario no encontrado en el sistema' TO MMENSAJEO.

      *---- IGUAL QUE UCONSP: Mantener el ID ingresado ----
           MOVE MIDINPI TO WS-ID-TEMP.
           MOVE WS-ID-TEMP TO MIDINPO.

      *---- Enviar mapa con mensaje ----
           MOVE -1 TO MIDINPL.
           EXEC CICS SEND MAP('UMODIM') MAPSET('UMODIM') DATAONLY
              CURSOR ALARM
           END-EXEC.

       MODIFICAR-USUARIO.
      *---- VALIDACIÓN PRIORITARIA: Debe haber un ID guardado ----
           IF WS-ID-TEMP = SPACES
               MOVE 'ERROR: Debe ingresar un ID para buscar'
                   TO MMENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- Usar el ID guardado en WS-ID-TEMP ----
           MOVE WS-ID-TEMP TO USU-ID.

      *---- PRIMERO: Leer el registro con UPDATE ----
           EXEC CICS READ FILE('USUDS') INTO(REG-USUARIO)
              RIDFLD(USU-ID) UPDATE RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERROR: No se pudo leer el usuario para actualizar'
                   TO MMENSAJEO
               PERFORM ENVIAR-MAPA-ERROR
               EXIT PARAGRAPH
           END-IF.

      *---- SEGUNDO: Guardar email original ANTES de cualquier modificación ----
           MOVE USU-EMAIL TO WS-EMAIL-ORIGINAL.

      *---- TERCERO: Verificar si se modificó algún campo ----
           IF MNOMINPL <= 0 AND MAPEINPL <= 0 AND
              MMAILINPL <= 0 AND MTIPOINPL <= 0
      *---- No se modificó ningún campo, liberar registro y salir ----
              EXEC CICS UNLOCK FILE('USUDS') END-EXEC
              MOVE 'No se modifico ningun campo. Modifique y PF5=Grabar'
                 TO MMENSAJEO
              PERFORM ENVIAR-MAPA-ERROR
              EXIT PARAGRAPH
           END-IF.

      *---- CUARTO: Actualizar SOLO los campos que fueron modificados ----
      *---- Si LENGTH > 0, el usuario modificó el campo ----
      *---- Si LENGTH = -1 o 0, NO se tocó, mantener valor del registro ----

           IF MNOMINPL > 0
      *---- Usuario modificó NOMBRE, validar y actualizar ----
               IF MNOMINPI = SPACES
                   EXEC CICS UNLOCK FILE('USUDS') END-EXEC
                   MOVE 'ERROR: NOMBRE no puede estar vacio'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
                   EXIT PARAGRAPH
               END-IF
               MOVE MNOMINPI TO USU-NOMBRE
           END-IF.

           IF MAPEINPL > 0
      *---- Usuario modificó APELLIDO, validar y actualizar ----
               IF MAPEINPI = SPACES
                   EXEC CICS UNLOCK FILE('USUDS') END-EXEC
                   MOVE 'ERROR: APELLIDO no puede estar vacio'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
                   EXIT PARAGRAPH
               END-IF
               MOVE MAPEINPI TO USU-APELLIDO
           END-IF.

           IF MMAILINPL > 0
      *---- Usuario modificó EMAIL, validar y actualizar ----
               IF MMAILINPI = SPACES
                   EXEC CICS UNLOCK FILE('USUDS') END-EXEC
                   MOVE 'ERROR: EMAIL no puede estar vacio'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
                   EXIT PARAGRAPH
               END-IF

      *---- Verificar que el nuevo email sea único ----
               IF MMAILINPI NOT = WS-EMAIL-ORIGINAL
                   PERFORM VERIFICAR-EMAIL-UNICO
                   IF EMAIL-YA-EXISTE
                       EXEC CICS UNLOCK FILE('USUDS') END-EXEC
                       MOVE 'ERROR: El nuevo email ya existe'
                           TO MMENSAJEO
                       PERFORM ENVIAR-MAPA-ERROR
                       EXIT PARAGRAPH
                   END-IF
               END-IF

               MOVE MMAILINPI TO USU-EMAIL
           END-IF.

           IF MTIPOINPL > 0
      *---- Usuario modificó TIPO, validar y actualizar ----
               IF MTIPOINPI = SPACE
                   EXEC CICS UNLOCK FILE('USUDS') END-EXEC
                   MOVE 'ERROR: TIPO no puede estar vacio'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
                   EXIT PARAGRAPH
               END-IF
               IF MTIPOINPI NOT = 'A' AND MTIPOINPI NOT = 'D' AND
                  MTIPOINPI NOT = 'E'
                   EXEC CICS UNLOCK FILE('USUDS') END-EXEC
                   MOVE 'ERROR: TIPO debe ser A, D o E'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
                   EXIT PARAGRAPH
               END-IF
               MOVE MTIPOINPI TO USU-TIPO
           END-IF.

      *---- QUINTO: Grabar modificación ----
           PERFORM GRABAR-MODIFICACION.

       VERIFICAR-EMAIL-UNICO.
           MOVE ZERO TO TEMP-ID.
           SET EMAIL-DISPONIBLE TO TRUE.

           EXEC CICS STARTBR FILE('USUDS') RIDFLD(TEMP-ID)
               KEYLENGTH(10) GTEQ RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               SET EMAIL-DISPONIBLE TO TRUE
               EXIT PARAGRAPH
           END-IF.

      *---- Normalizar email ingresado ----
           MOVE SPACES TO WS-EMAIL-INPUT.
           MOVE MMAILINPI TO WS-EMAIL-INPUT.
           INSPECT WS-EMAIL-INPUT CONVERTING
               'abcdefghijklmnopqrstuvwxyz' TO
               'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.

      *---- Recorrer archivo buscando email duplicado ----
           PERFORM UNTIL WS-RESP NOT = DFHRESP(NORMAL)
               EXEC CICS READNEXT FILE('USUDS') INTO(REG-TEMP)
                 RIDFLD(TEMP-ID) KEYLENGTH(10) RESP(WS-RESP)
               END-EXEC

               IF WS-RESP = DFHRESP(NORMAL)
      *---- Ignorar el registro actual (mismo ID) ----
                   MOVE WS-ID-TEMP TO USU-ID
                   IF TEMP-ID NOT = USU-ID
      *---- Normalizar email del registro ----
                       MOVE TEMP-EMAIL TO WS-EMAIL-TEMP
                       INSPECT WS-EMAIL-TEMP CONVERTING
                           'abcdefghijklmnopqrstuvwxyz' TO
                           'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      *---- Comparar emails ----
                       IF WS-EMAIL-TEMP = WS-EMAIL-INPUT
                           SET EMAIL-YA-EXISTE TO TRUE
                           PERFORM CERRAR-BROWSE-EMAIL
                           EXIT PARAGRAPH
                       END-IF
                   END-IF
               END-IF
           END-PERFORM.

      *---- Cerrar browse ----
           PERFORM CERRAR-BROWSE-EMAIL.
           SET EMAIL-DISPONIBLE TO TRUE.

       CERRAR-BROWSE-EMAIL.
           EXEC CICS ENDBR FILE('USUDS') RESP(WS-RESP)
           END-EXEC.

       GRABAR-MODIFICACION.
      *---- El registro YA está actualizado en REG-USUARIO ----
      *---- Solo hacer el REWRITE ----
           EXEC CICS REWRITE FILE('USUDS') FROM(REG-USUARIO)
              RESP(WS-RESP)
           END-EXEC.

      *---- Evaluar resultado ----
           EVALUATE WS-RESP
               WHEN DFHRESP(NORMAL)
                   MOVE 'Usuario modificado exitosamente. Use CLEAR'
                       TO MMENSAJEO
                   MOVE SPACES TO WS-ID-TEMP
                   PERFORM ENVIAR-MAPA-EXITO
               WHEN DFHRESP(NOTFND)
                   MOVE 'ERROR: Usuario no encontrado para modificar'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN DFHRESP(INVREQ)
                   MOVE 'ERROR: REWRITE sin READ UPDATE previo'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
               WHEN OTHER
                   MOVE 'ERROR al modificar usuario en VSAM'
                       TO MMENSAJEO
                   PERFORM ENVIAR-MAPA-ERROR
           END-EVALUATE.

       LIMPIAR-PANTALLA.
      *---- Limpiar todos los campos ----
           MOVE SPACES TO MIDINPO MNOMINPO MAPEINPO MMAILINPO.
           MOVE SPACE TO MTIPOINPO.
           MOVE SPACES TO WS-ID-TEMP.

      *---- NUEVO: Desproteger campo ID para permitir nueva búsqueda ----
           MOVE DFHBMUNP TO MIDINPA.

      *---- NUEVO: Proteger campos de datos (no hay usuario cargado) ----
           MOVE DFHBMPRO TO MNOMINPA MAPEINPA MMAILINPA MTIPOINPA.

      *---- Mensaje actualizado ----
           MOVE 'Pantalla limpia. Ingrese nuevo ID y presione ENTER'
               TO MMENSAJEO.

      *---- Posicionar cursor en ID ----
           MOVE -1 TO MIDINPL.

      *---- Enviar solo datos ----
           EXEC CICS SEND MAP('UMODIM') MAPSET('UMODIM') DATAONLY CURSOR
           END-EXEC.

       ENVIAR-MAPA-EXITO.
      *---- Proteger campos despues de modificar ----
           MOVE DFHBMPRO TO MNOMINPA MAPEINPA MMAILINPA MTIPOINPA.
           MOVE DFHBMUNP TO MIDINPA.

      *---- Mensaje de éxito con instrucción PF2 ----
           MOVE 'Usuario modificado exitosamente. Use PF2 para limpiar'
               TO MMENSAJEO.

           MOVE -1 TO MIDINPL.
           EXEC CICS SEND MAP('UMODIM') MAPSET('UMODIM') DATAONLY CURSOR
           END-EXEC.

      *---- IGUAL QUE UCONSP: Reenviar mapa con mensaje de error ----
       ENVIAR-MAPA-ERROR.
           MOVE -1 TO MIDINPL.
           EXEC CICS SEND MAP('UMODIM') MAPSET('UMODIM') DATAONLY
              CURSOR ALARM
           END-EXEC.

      *---- IGUAL QUE UCONSP: Transferir control al menú ----
       VOLVER-MENU.
           EXEC CICS XCTL PROGRAM('UMENUP') END-EXEC.
