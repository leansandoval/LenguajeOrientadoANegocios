       IDENTIFICATION DIVISION.
       PROGRAM-ID. CMENU.

       DATA DIVISION.

       WORKING-STORAGE SECTION.
       01  WS-CONTADOR         PIC 9(02) VALUE 0.

       COPY DFHAID.
       COPY MMENU.

       01  WS-VARIABLES.
           05 WS-OPCION        PIC X(1).
           05 WS-MENSAJE       PIC X(60).
           05 WS-FIRST-TIME    PIC X(1) VALUE 'Y'.
              88 PRIMERA-VEZ   VALUE 'Y'.
           05 WS-MSG-SALIDA    PIC X(28)
                                VALUE 'GRACIAS POR USAR EL SISTEMA'.

       01  WS-FILE-AREA.
           05 WS-RECORD-KEY    PIC X(10) VALUE SPACES.

       01  WS-RESP             PIC S9(8) COMP VALUE 0.
       01  WS-RESP2            PIC S9(8) COMP VALUE 0.

       01  WS-LIBRO-RECORD.
           COPY LIBROS.

      *  Línea formateada para mostrar cada libro (máx 60 columnas)
       01  WS-LINEA-LIBRO.
           05 WLL-CODIGO       PIC X(10).
           05 FILLER           PIC X VALUE SPACE.
           05 WLL-TITULO       PIC X(20).
           05 FILLER           PIC X VALUE SPACE.
           05 WLL-AUTOR        PIC X(14).
           05 FILLER           PIC X VALUE SPACE.
           05 WLL-ANIO         PIC X(4).
           05 FILLER           PIC X VALUE SPACE.
           05 WLL-STOCK        PIC X(3).
           05 FILLER           PIC X VALUE SPACE.
           05 WLL-UBIC         PIC X(4).

       01  WS-FIN-LECTURA      PIC X VALUE 'N'.
           88 FIN-LECTURA-SI   VALUE 'S'.
           88 FIN-LECTURA-NO   VALUE 'N'.

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           EVALUATE TRUE
               WHEN EIBCALEN = ZERO
                    PERFORM ENVIAR-MAPA-INICIAL
               WHEN EIBAID = DFHCLEAR
                    PERFORM ENVIAR-MAPA-INICIAL
               WHEN EIBAID = DFHPF3
                    PERFORM TERMINAR-TRANSACCION
               WHEN EIBAID = DFHENTER
                    PERFORM PROCESAR-OPCION
               WHEN OTHER
                    MOVE 'TECLA NO VALIDA' TO WS-MENSAJE
                    PERFORM ENVIAR-MAPA-CON-DATOS
           END-EVALUATE

           EXEC CICS RETURN
                TRANSID('TPG3')
                COMMAREA(WS-FIRST-TIME)
                LENGTH(1)
           END-EXEC.

      *--------------------------------------------------------------
      *   MAPA VACÍO INICIAL
      *--------------------------------------------------------------
       ENVIAR-MAPA-INICIAL.
           MOVE SPACES TO OPCIONO
           MOVE SPACES TO MENSAJE1O
           MOVE SPACES TO MENSAJE2O
           MOVE SPACES TO MENSAJE3O
           MOVE SPACES TO MENSAJE4O
           MOVE SPACES TO MENSAJE5O
           MOVE SPACES TO MENSAJE6O
           MOVE SPACES TO MENSAJE7O
           MOVE SPACES TO MENSAJE8O
           MOVE SPACES TO MENSAJE9O
           MOVE SPACES TO MENSAJE10O

           EXEC CICS SEND MAP('CMENU')
                MAPSET('MMENU')
                ERASE
                CURSOR
                RESP(WS-RESP)
           END-EXEC.

      *--------------------------------------------------------------
      *   PROCESAR OPCIÓN DEL MENÚ
      *--------------------------------------------------------------
       PROCESAR-OPCION.
           EXEC CICS RECEIVE MAP('CMENU')
                MAPSET('MMENU')
                RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERR REC MAP' TO MENSAJE1O
               MOVE WS-RESP       TO MENSAJE2O
               PERFORM ENVIAR-MAPA-CON-DATOS
               EXIT PARAGRAPH
           END-IF

           MOVE OPCIONI TO WS-OPCION

           EVALUATE WS-OPCION
               WHEN '1'
                    PERFORM LEER-ARCHIVO-LIBROS
               WHEN '2'
                    MOVE 'OPCION 2: LISTAR' TO WS-MENSAJE
               WHEN '3'
                    MOVE 'OPCION 3: ALTA'   TO WS-MENSAJE
               WHEN '4'
                    PERFORM TERMINAR-TRANSACCION
               WHEN OTHER
                    MOVE 'OPCION 1-4'       TO WS-MENSAJE
           END-EVALUATE

           PERFORM ENVIAR-MAPA-CON-DATOS.

      *--------------------------------------------------------------
      *   LECTURA Y LISTADO DEL VSAM LIBROS
      *--------------------------------------------------------------
       LEER-ARCHIVO-LIBROS.
           MOVE SPACES TO WS-RECORD-KEY
           MOVE 'N'     TO WS-FIN-LECTURA
           MOVE 0       TO WS-RESP
           MOVE 0       TO WS-RESP2

      *  Iniciar browse
           EXEC CICS STARTBR
                FILE('LIBROS')
                GTEQ
                RIDFLD(WS-RECORD-KEY)
                RESP(WS-RESP)
                RESP2(WS-RESP2)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERR STARTBR' TO MENSAJE1O
               MOVE WS-RESP       TO MENSAJE2O
               MOVE WS-RESP2      TO MENSAJE3O
               EXIT PARAGRAPH
           END-IF

      *  Limpiar zona de mensajes
           MOVE SPACES TO MENSAJE1O
           MOVE SPACES TO MENSAJE2O
           MOVE SPACES TO MENSAJE3O
           MOVE SPACES TO MENSAJE4O
           MOVE SPACES TO MENSAJE5O
           MOVE SPACES TO MENSAJE6O
           MOVE SPACES TO MENSAJE7O
           MOVE SPACES TO MENSAJE8O
           MOVE SPACES TO MENSAJE9O
           MOVE SPACES TO MENSAJE10O

      *  Cabecera
           MOVE SPACES          TO MENSAJE1O
           MOVE 'CODIGO'        TO MENSAJE1O(1:6)
           MOVE 'TITULO'        TO MENSAJE1O(12:6)
           MOVE 'AUTOR'         TO MENSAJE1O(33:5)
           MOVE 'ANIO'          TO MENSAJE1O(48:4)
           MOVE 'STK'           TO MENSAJE1O(53:3)
           MOVE 'UBIC'          TO MENSAJE1O(57:4)

      *  Vamos a mostrar hasta 9 libros (líneas 2 a 10 del mapa)
           MOVE 1 TO WS-CONTADOR

           PERFORM UNTIL FIN-LECTURA-SI
                 OR WS-CONTADOR > 9

                EXEC CICS READNEXT
                     FILE('LIBROS')
                     INTO(WS-LIBRO-RECORD)
                     RIDFLD(WS-RECORD-KEY)
                     RESP(WS-RESP)
                     RESP2(WS-RESP2)
                END-EXEC

                EVALUATE WS-RESP
                    WHEN DFHRESP(NORMAL)

      *                 Armar línea formateada
                         MOVE SPACES              TO WS-LINEA-LIBRO
                         MOVE LIB-CODIGO         TO WLL-CODIGO
                         MOVE LIB-TITULO(1:20)   TO WLL-TITULO
                         MOVE LIB-AUTOR(1:14)    TO WLL-AUTOR
                         MOVE LIB-ANIO-PUBLICACION
                                                 TO WLL-ANIO
                         MOVE LIB-STOCK-TOTAL    TO WLL-STOCK
                         MOVE LIB-UBICACION(1:4) TO WLL-UBIC

                         EVALUATE WS-CONTADOR
                             WHEN 1
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE2O
                             WHEN 2
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE3O
                             WHEN 3
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE4O
                             WHEN 4
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE5O
                             WHEN 5
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE6O
                             WHEN 6
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE7O
                             WHEN 7
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE8O
                             WHEN 8
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE9O
                             WHEN 9
                                  MOVE WS-LINEA-LIBRO
                                       TO MENSAJE10O
                         END-EVALUATE

                         ADD 1 TO WS-CONTADOR

                    WHEN DFHRESP(ENDFILE)
                         MOVE 'S' TO WS-FIN-LECTURA

                    WHEN DFHRESP(NOTFND)
                         MOVE 'S' TO WS-FIN-LECTURA

                    WHEN OTHER
                         MOVE 'ERR READNXT' TO MENSAJE1O
                         MOVE WS-RESP      TO MENSAJE2O
                         MOVE WS-RESP2     TO MENSAJE3O
                         MOVE 'S'          TO WS-FIN-LECTURA
                END-EVALUATE
           END-PERFORM

      *  Cerrar browse
           EXEC CICS ENDBR FILE('LIBROS')
                RESP(WS-RESP)
                RESP2(WS-RESP2)
           END-EXEC.

           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'ERR ENDBR' TO MENSAJE1O
               MOVE WS-RESP     TO MENSAJE2O
               MOVE WS-RESP2    TO MENSAJE3O
           END-IF

      *  Si no hubo registros, mostrar mensaje bajo la cabecera
           IF WS-CONTADOR = 1
                MOVE 'SIN REGISTROS' TO MENSAJE2O
           END-IF.

      *--------------------------------------------------------------
      *   ENVIAR MAPA CON DATOS O MENSAJE
      *--------------------------------------------------------------
       ENVIAR-MAPA-CON-DATOS.
           IF WS-MENSAJE NOT = SPACES
              MOVE WS-MENSAJE TO MENSAJE1O
           END-IF

           MOVE SPACES TO WS-MENSAJE
           MOVE SPACES TO OPCIONO

           EXEC CICS SEND MAP('CMENU')
                MAPSET('MMENU')
                CURSOR
                RESP(WS-RESP)
           END-EXEC.

      *--------------------------------------------------------------
      *   SALIDA DEL PROGRAMA
      *--------------------------------------------------------------
       TERMINAR-TRANSACCION.
           EXEC CICS SEND TEXT
                FROM(WS-MSG-SALIDA)
                LENGTH(28)
                ERASE
           END-EXEC.

           EXEC CICS RETURN
           END-EXEC.
