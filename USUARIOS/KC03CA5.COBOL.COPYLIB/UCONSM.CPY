       01  UCONSMI.
           02  FILLER PIC X(12).
           02  TITULOL    COMP  PIC  S9(4).
           02  TITULOF    PICTURE X.
           02  FILLER REDEFINES TITULOF.
             03 TITULOA    PICTURE X.
           02  TITULOI  PIC X(35).
           02  ETI-IDL    COMP  PIC  S9(4).
           02  ETI-IDF    PICTURE X.
           02  FILLER REDEFINES ETI-IDF.
             03 ETI-IDA    PICTURE X.
           02  ETI-IDI  PIC X(14).
           02  CAMPOIDL    COMP  PIC  S9(4).
           02  CAMPOIDF    PICTURE X.
           02  FILLER REDEFINES CAMPOIDF.
             03 CAMPOIDA    PICTURE X.
           02  CAMPOIDI  PIC 9(10).
           02  ETI-NOML    COMP  PIC  S9(4).
           02  ETI-NOMF    PICTURE X.
           02  FILLER REDEFINES ETI-NOMF.
             03 ETI-NOMA    PICTURE X.
           02  ETI-NOMI  PIC X(10).
           02  NOML    COMP  PIC  S9(4).
           02  NOMF    PICTURE X.
           02  FILLER REDEFINES NOMF.
             03 NOMA    PICTURE X.
           02  NOMI  PIC X(20).
           02  ETI-APEL    COMP  PIC  S9(4).
           02  ETI-APEF    PICTURE X.
           02  FILLER REDEFINES ETI-APEF.
             03 ETI-APEA    PICTURE X.
           02  ETI-APEI  PIC X(10).
           02  APEL    COMP  PIC  S9(4).
           02  APEF    PICTURE X.
           02  FILLER REDEFINES APEF.
             03 APEA    PICTURE X.
           02  APEI  PIC X(20).
           02  ETI-EMAL    COMP  PIC  S9(4).
           02  ETI-EMAF    PICTURE X.
           02  FILLER REDEFINES ETI-EMAF.
             03 ETI-EMAA    PICTURE X.
           02  ETI-EMAI  PIC X(10).
           02  EMAL    COMP  PIC  S9(4).
           02  EMAF    PICTURE X.
           02  FILLER REDEFINES EMAF.
             03 EMAA    PICTURE X.
           02  EMAI  PIC X(35).
           02  ETI-TIPL    COMP  PIC  S9(4).
           02  ETI-TIPF    PICTURE X.
           02  FILLER REDEFINES ETI-TIPF.
             03 ETI-TIPA    PICTURE X.
           02  ETI-TIPI  PIC X(10).
           02  TIPL    COMP  PIC  S9(4).
           02  TIPF    PICTURE X.
           02  FILLER REDEFINES TIPF.
             03 TIPA    PICTURE X.
           02  TIPI  PIC X(30).
           02  MENSAJEL    COMP  PIC  S9(4).
           02  MENSAJEF    PICTURE X.
           02  FILLER REDEFINES MENSAJEF.
             03 MENSAJEA    PICTURE X.
           02  MENSAJEI  PIC X(60).
           02  PIEL    COMP  PIC  S9(4).
           02  PIEF    PICTURE X.
           02  FILLER REDEFINES PIEF.
             03 PIEA    PICTURE X.
           02  PIEI  PIC X(60).
       01  UCONSMO REDEFINES UCONSMI.
           02  FILLER PIC X(12).
           02  FILLER PICTURE X(3).
           02  TITULOO  PIC X(35).
           02  FILLER PICTURE X(3).
           02  ETI-IDO  PIC X(14).
           02  FILLER PICTURE X(3).
           02  CAMPOIDO  PIC X(10).
           02  FILLER PICTURE X(3).
           02  ETI-NOMO  PIC X(10).
           02  FILLER PICTURE X(3).
           02  NOMO  PIC X(20).
           02  FILLER PICTURE X(3).
           02  ETI-APEO  PIC X(10).
           02  FILLER PICTURE X(3).
           02  APEO  PIC X(20).
           02  FILLER PICTURE X(3).
           02  ETI-EMAO  PIC X(10).
           02  FILLER PICTURE X(3).
           02  EMAO  PIC X(35).
           02  FILLER PICTURE X(3).
           02  ETI-TIPO  PIC X(10).
           02  FILLER PICTURE X(3).
           02  TIPO  PIC X(30).
           02  FILLER PICTURE X(3).
           02  MENSAJEO  PIC X(60).
           02  FILLER PICTURE X(3).
           02  PIEO  PIC X(60).
