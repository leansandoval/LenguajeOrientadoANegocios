//EXEVSAM JOB (ACCT),
//        'CARGA LISTA USU',
//        CLASS=A,
//        MSGCLASS=X,
//        NOTIFY=&SYSUID
//*****************************************************************
//* Cargar usuarios al VSAM
//*****************************************************************
//RUNLOAD EXEC PGM=CARGUSU,REGION=0M
//STEPLIB  DD DSN=KC03CA5.LOAD.LIBRARY,DISP=SHR
//SYSIN    DD DSN=KC03CA5.DATA.USUARIOS,DISP=SHR
//USUDS    DD DSN=KC03CA5.VSAM.USUARIOS,DISP=OLD
//SYSPRINT DD SYSOUT=*
//****************************************************************
//* Listar usuarios desde el VSAM
//*****************************************************************
//RUNLIST EXEC PGM=USULIST,REGION=0M
//STEPLIB  DD  DSN=KC03CA5.LOAD.LIBRARY,DISP=SHR
//USUDS    DD  DSN=KC03CA5.VSAM.USUARIOS,DISP=OLD
//OUTFILE  DD  DSN=KC03CA5.DATA.OUTPUT.USUARIOS,
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(5,1)),RECFM=FB,LRECL=200,BLKSIZE=32000
//SYSPRINT DD SYSOUT=*
//
