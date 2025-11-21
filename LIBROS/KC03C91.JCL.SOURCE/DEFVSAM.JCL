//SYSUIDV JOB (ACCT),'DEFINIR VSAM',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID
//*
//* JOB: DEFINICION DE ARCHIVOS VSAM PARA BIBLIOTECA
//*
//DEFVSAM  EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE &SYSUID.VSAM.LIBROS CLUSTER PURGE
  DELETE &SYSUID.VSAM.USUARIOS CLUSTER PURGE
  DELETE &SYSUID.VSAM.PRESTAMO CLUSTER PURGE
  SET MAXCC = 0
  DEFINE CLUSTER (NAME(&SYSUID.VSAM.LIBROS) -
                  RECSZ(200 200) -
                  KEYS(10 0) -
                  CYLINDERS(10 3) -
                  INDEXED -
                  FREESPACE(10 10) -
                  SHAREOPTIONS(2 3) -
                  REUSE) -
         DATA (NAME(&SYSUID.VSAM.LIBROS.DATA)) -
         INDEX (NAME(&SYSUID.VSAM.LIBROS.INDEX))
  DEFINE CLUSTER (NAME(&SYSUID.VSAM.USUARIOS) -
                  RECSZ(250 250) -
                  KEYS(10 0) -
                  CYLINDERS(5 2) -
                  INDEXED -
                  FREESPACE(10 10) -
                  SHAREOPTIONS(2 3) -
                  REUSE) -
         DATA (NAME(&SYSUID.VSAM.USUARIOS.DATA)) -
         INDEX (NAME(&SYSUID.VSAM.USUARIOS.INDEX))
  DEFINE CLUSTER (NAME(&SYSUID.VSAM.PRESTAMO) -
                  RECSZ(200 200) -
                  KEYS(8 0) -
                  CYLINDERS(10 3) -
                  INDEXED -
                  FREESPACE(10 10) -
                  SHAREOPTIONS(2 3) -
                  REUSE) -
         DATA (NAME(&SYSUID.VSAM.PRESTAMO.DATA)) -
         INDEX (NAME(&SYSUID.VSAM.PRESTAMO.INDEX))
  LISTCAT ENTRIES(&SYSUID.VSAM.LIBROS -
                  &SYSUID.VSAM.USUARIOS -
                  &SYSUID.VSAM.PRESTAMO) ALL
/*
