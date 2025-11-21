       01  UMENUMI.
           02  FILLER PIC X(12).
           02  OPCIONL    COMP  PIC  S9(4).
           02  OPCIONF    PICTURE X.
           02  FILLER REDEFINES OPCIONF.
             03 OPCIONA    PICTURE X.
           02  OPCIONI  PIC X(1).
           02  MENSAJEL    COMP  PIC  S9(4).
           02  MENSAJEF    PICTURE X.
           02  FILLER REDEFINES MENSAJEF.
             03 MENSAJEA    PICTURE X.
           02  MENSAJEI  PIC X(60).
       01  UMENUMO REDEFINES UMENUMI.
           02  FILLER PIC X(12).
           02  FILLER PICTURE X(3).
           02  OPCIONO  PIC X(1).
           02  FILLER PICTURE X(3).
           02  MENSAJEO  PIC X(60).
