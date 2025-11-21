      *--------------------------------------------------------------*
      * Programa   : CARGUSU                                         *
      * Propósito  : Cargar archivo secuencial de usuarios y         *
      *              grabarlo en un VSAM KSDS                        *
      * Autor      : KC03CA5                                         *
      * Fecha      : 05/11/2025                                      *
      *--------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CARGUSU.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INFILE ASSIGN TO SYSIN
               ORGANIZATION IS SEQUENTIAL.
           SELECT USUDS ASSIGN TO USUDS
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS USU-ID
               FILE STATUS IS WS-FS-USUDS.
       DATA DIVISION.
       FILE SECTION.
       FD  INFILE
           RECORD CONTAINS 200 CHARACTERS
           BLOCK CONTAINS 0 RECORDS
           RECORDING MODE IS F.
       01 REG-IN        PIC X(200).
       FD  USUDS.
       COPY USUARIO.
       WORKING-STORAGE SECTION.
       01 WS-FS-USUDS            PIC XX.
           88 WS-USUDS-OK        VALUE '00'.
       01 WS-EOF                 PIC X VALUE 'N'.
           88 WS-END-FILE        VALUE 'S'.
       01 WS-ID-CNT              PIC 9(10) VALUE 0000000001.
       PROCEDURE DIVISION.
       MAIN-PARA.
           OPEN INPUT INFILE
           OPEN OUTPUT USUDS
           PERFORM UNTIL WS-END-FILE
               READ INFILE
                   AT END
                       SET WS-END-FILE TO TRUE
                   NOT AT END
                       PERFORM PROCESAR-REG
               END-READ
           END-PERFORM
           CLOSE INFILE
           CLOSE USUDS
           STOP RUN.
       PROCESAR-REG.
           IF REG-IN NOT = SPACES AND REG-IN NOT = LOW-VALUES
               UNSTRING REG-IN DELIMITED BY '|'
                   INTO USU-NOMBRE
                        USU-APELLIDO
                        USU-EMAIL
                        USU-TIPO
               END-UNSTRING
               MOVE WS-ID-CNT TO USU-ID
               ADD 1 TO WS-ID-CNT
               WRITE REG-USUARIO
                   INVALID KEY
                       DISPLAY 'ERROR VSAM, STATUS=' WS-FS-USUDS
               END-WRITE
           END-IF.
