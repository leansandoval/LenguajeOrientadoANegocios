//COMPMAPS JOB (1),CLASS=A,MSGCLASS=H,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//*
//IBMLIB  JCLLIB ORDER=DFH610.CICS.SDFHPROC
//*******************************************************************
//* MENU PRINCIPAL
//*******************************************************************
//MAPMENU EXEC DFHMAPS,
//             MAPLIB='KC03CA5.LOAD.LIBRARY',
//             INDEX='DFH610.CICS',
//             DSCTLIB='KC03CA5.COBOL.COPYLIB',
//             MAPNAME='UMENUM'
//SYSUT1 DD DSN=KC03CA5.BMS.SOURCE(UMENUM),DISP=SHR
//******************************************************************
//* ALTA DE USUARIOS
//******************************************************************
//MAPALTA EXEC DFHMAPS,
//             MAPLIB='KC03CA5.LOAD.LIBRARY',
//             INDEX='DFH610.CICS',
//             DSCTLIB='KC03CA5.COBOL.COPYLIB',
//             MAPNAME='UALTAM'
//SYSUT1 DD DSN=KC03CA5.BMS.SOURCE(UALTAM),DISP=SHR
//******************************************************************
//* LISTA DE USUARIOS
//******************************************************************
//MAPLIST EXEC DFHMAPS,
//             MAPLIB='KC03CA5.LOAD.LIBRARY',
//             INDEX='DFH610.CICS',
//             DSCTLIB='KC03CA5.COBOL.COPYLIB',
//             MAPNAME='ULISTAM'
//SYSUT1 DD DSN=KC03CA5.BMS.SOURCE(ULISTAM),DISP=SHR
//******************************************************************
//* CONSULTA DE USUARIOS
//******************************************************************
//MAPCONS EXEC DFHMAPS,
//             MAPLIB='KC03CA5.LOAD.LIBRARY',
//             INDEX='DFH610.CICS',
//             DSCTLIB='KC03CA5.COBOL.COPYLIB',
//             MAPNAME='UCONSM'
//SYSUT1 DD DSN=KC03CA5.BMS.SOURCE(UCONSM),DISP=SHR
//******************************************************************
//* MODIFICACION DE USUARIOS
//******************************************************************
//MAPMODI EXEC DFHMAPS,
//             MAPLIB='KC03CA5.LOAD.LIBRARY',
//             INDEX='DFH610.CICS',
//             DSCTLIB='KC03CA5.COBOL.COPYLIB',
//             MAPNAME='UMODIM'
//SYSUT1 DD DSN=KC03CA5.BMS.SOURCE(UMODIM),DISP=SHR
//******************************************************************
//* BAJA DE USUARIOS
//******************************************************************
//MAPBAJA EXEC DFHMAPS,
//             MAPLIB='KC03CA5.LOAD.LIBRARY',
//             INDEX='DFH610.CICS',
//             DSCTLIB='KC03CA5.COBOL.COPYLIB',
//             MAPNAME='UBAJAM'
//SYSUT1 DD DSN=KC03CA5.BMS.SOURCE(UBAJAM),DISP=SHR
