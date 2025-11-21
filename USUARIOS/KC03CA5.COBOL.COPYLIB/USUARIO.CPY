      ******************************************************************
      * COPYBOOK: USUARIO                                              *
      * PROPOSITO: ESTRUCTURA DE DATOS PARA USUARIOS                   *
      * AUTOR: ESTUDIANTE Z79381 / KC03CA5                             *
      * FECHA: 05/10/2025                                              *
      * VERSION: 1.0                                                   *
      ******************************************************************
       01  REG-USUARIO.
           05 USU-ID                  PIC 9(10).
           05 USU-NOMBRE              PIC X(30).
           05 USU-APELLIDO            PIC X(30).
           05 USU-EMAIL               PIC X(50).
           05 USU-TIPO                PIC X(1).
              88 USU-ESTUDIANTE       VALUE 'E'.
              88 USU-DOCENTE          VALUE 'D'.
              88 USU-ADMINISTRATIVO   VALUE 'A'.
           05 FILLER                PIC X(79).
