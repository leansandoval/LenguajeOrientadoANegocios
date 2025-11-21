//SYSUIDA JOB (ACCT),'COMPILE BMS MAP TESTC',

//         CLASS=A,

//         MSGCLASS=H,

//         MSGLEVEL=(1,1),

//         NOTIFY=&SYSUID

//*

//*****************************************************************

//* JCL PARA COMPILAR MAPA BMS                                    *

//* MAPA: TESTC                                                    *

//* GENERA: - Modulo de carga (LOAD)                             *

//*         - Copybook fisico (DSECT)                            *

//*         - Copybook simbolico (COPY)                          *

//*****************************************************************

//*

//*****************************************************************

//* PASO 1: ENSAMBLAR MAPA FISICO (DSECT)                        *

//*****************************************************************

//MAPA1   EXEC PGM=ASMA90,

//             PARM='DECK,NOOBJECT'

//SYSLIB   DD  DSN=DFH610.CICS.SDFHMAC,DISP=SHR

//SYSUT1   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSUT2   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSUT3   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSPRINT DD  SYSOUT=*

//SYSPUNCH DD  DSN=&SYSUID.COBOL.COPYLIB(TESTC),

//             DISP=SHR

//SYSIN    DD  DSN=&SYSUID.BMS.SOURCE(TESTC),

//             DISP=SHR

//*

//*****************************************************************

//* PASO 2: ENSAMBLAR MAPA SIMBOLICO (COPY)                      *

//*****************************************************************

//MAPA2   EXEC PGM=ASMA90,

//             PARM='DECK,NOOBJECT,SYSPARM(DSECT)'

//SYSLIB   DD  DSN=DFH610.CICS.SDFHMAC,DISP=SHR

//SYSUT1   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSUT2   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSUT3   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSPRINT DD  SYSOUT=*

//SYSPUNCH DD  DSN=&SYSUID.COBOL.COPYLIB(TESTC),

//             DISP=SHR

//SYSIN    DD  DSN=&SYSUID.BMS.SOURCE(TESTC),

//             DISP=SHR

//*

//*****************************************************************

//* PASO 3: ENSAMBLAR Y LINK MAPA LOAD                           *

//*****************************************************************

//MAPA3   EXEC PGM=ASMA90

//SYSLIB   DD  DSN=DFH610.CICS.SDFHMAC,DISP=SHR

//SYSUT1   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSUT2   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSUT3   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSPRINT DD  SYSOUT=*

//SYSLIN   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1)),

//             DISP=(,PASS),DCB=BLKSIZE=3200

//SYSIN    DD  DSN=&SYSUID.BMS.SOURCE(TESTC),

//             DISP=SHR

//*

//LKED    EXEC PGM=IEWL,

//             PARM='LIST,XREF,LET'

//SYSLIB   DD  DSN=DFH610.CICS.SDFHLOAD,DISP=SHR

//SYSPRINT DD  SYSOUT=*

//SYSLMOD  DD  DSN=&SYSUID.CICS.LOAD(TESTC),

//             DISP=SHR

//SYSUT1   DD  UNIT=SYSALLDA,SPACE=(CYL,(1,1))

//SYSLIN   DD  DSN=*.MAPA3.SYSLIN,DISP=(OLD,DELETE)



