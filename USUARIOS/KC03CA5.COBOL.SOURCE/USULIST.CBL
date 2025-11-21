      *--------------------------------------------------------------*
      * Programa   : USULIST                                         *
      * Propósito  : Listar contenido del KSDS de usuarios           *
      * Autor      : KC03CA5                                         *
      * Fecha      : 05/11/2025                                      *
      *--------------------------------------------------------------*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. USULIST.
        ENVIRONMENT DIVISION.
        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
            SELECT USUDS ASSIGN TO USUDS
                ORGANIZATION IS INDEXED
                ACCESS MODE IS SEQUENTIAL
                RECORD KEY IS USU-ID
                FILE STATUS IS WS-FS-USUDS.
            SELECT OUTFILE ASSIGN TO OUTFILE
                ORGANIZATION IS SEQUENTIAL.
        DATA DIVISION.
        FILE SECTION.
        FD  USUDS.
        COPY USUARIO.
        FD  OUTFILE
            RECORD CONTAINS 200 CHARACTERS
            BLOCK CONTAINS 0 RECORDS
            RECORDING MODE IS F.
        01  REG-OUT        PIC X(200).
        WORKING-STORAGE SECTION.
        01 WS-FS-USUDS     PIC XX.
           88 WS-USUDS-OK  VALUE '00'.
        01 WS-EOF          PIC X VALUE 'N'.
           88 WS-END-FILE  VALUE 'S'.
        PROCEDURE DIVISION.
        MAIN-PARA.
            OPEN INPUT USUDS
            OPEN OUTPUT OUTFILE
            PERFORM UNTIL WS-END-FILE
                READ USUDS
                    AT END
                        SET WS-END-FILE TO TRUE
                    NOT AT END
                        MOVE SPACES TO REG-OUT
                        STRING
                            USU-ID        DELIMITED BY SIZE
                            '|'           DELIMITED BY SIZE
                            USU-NOMBRE    DELIMITED BY SIZE
                            '|'           DELIMITED BY SIZE
                            USU-APELLIDO  DELIMITED BY SIZE
                            '|'           DELIMITED BY SIZE
                            USU-EMAIL     DELIMITED BY SIZE
                            '|'           DELIMITED BY SIZE
                            USU-TIPO      DELIMITED BY SIZE
                        INTO REG-OUT
                        END-STRING
                        WRITE REG-OUT
                END-READ
            END-PERFORM
            CLOSE USUDS
            CLOSE OUTFILE
            STOP RUN.
