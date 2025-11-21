//*-------------------------------------------------------------------
//* JCL: DEFVSAM
//* PROPOSITO: Definir el cluster VSAM para la tabla de usuarios
//* AUTOR: Z79381/ KC03CA5
//* FECHA: 08/11/2025
//* VERSION: 1.0
//*-------------------------------------------------------------------
//DEFVSAM  JOB (ACCT),'DEFINE VSAM',CLASS=A,MSGCLASS=X
//STEP1    EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD *
  DEFINE CLUSTER (NAME(KC03CA5.VSAM.USUARIOS) -
      INDEXED -
      KEYS(10 0) -
      RECORDSIZE(200 200) -
      TRACKS(10 5) -
      SHR(3) -
  ) -
      DATA (NAME(KC03CA5.VSAM.USUARIOS.DATA)) -
      INDEX (NAME(KC03CA5.VSAM.USUARIOS.INDEX))
/*
