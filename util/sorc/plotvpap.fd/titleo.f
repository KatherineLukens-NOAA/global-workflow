      SUBROUTINE TITLEO(I,J,DHMBS,IERR)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:    TITLEO      PUTS TITLE ON TROPICAL ANALYSIS
C   PRGMMR: LIN              ORG: W/NMC412   DATE: 97-02-10
C
C ABSTRACT: PLACES A DESCRIPTIVE TITLE ON THE TROPICAL ANALYSIS.
C   UNPACKS THE TIMES OUT OF WORDS (1-2) OF NANJI AND BUILDS A TITLE
C   FOR CALL TO PUTLAB.
C
C PROGRAM HISTORY LOG:
C   YY-MM-DD  ORIGINAL AUTHOR UNKNOWN
C   89-04-06  HENRICHSEN REPLACED ENCODE AND DECODE WITH FFA2I,
C                        FFI2A AND MOVCH. DOCUMENT CODE.
C   93-05-10  LILLY CONVERT SUBROUTINE TO FORTRAN 77
C   97-02-10  LIN   CONVERT SUBROUTINE TO CFT     77
C
C USAGE:    CALL TITLEO(I,J,DHMBS,IERR)
C
C   INPUT ARGUMENT LIST:
C     I        - I POSITION IN DOTS OF TITLE.
C     J        - J POSITION IN DOTS OF TITLE.
C     DHMBS    - REAL*8 WORD THAT CONTAINS THE MB LEVEL
C              - DISCRIPTION.
C     COMMON   - /TIMES/ NANJI(12)
C              - CONTAINS YYMMDDHH IN WORDS (1-2) IN HOLLERTH.
C              - CONTAINS DUMP TIME IN WORDS (5-6) IN HOLLERTH.
C
C   OUTPUT ARGUMENT LIST:
C     IERR     - ERROR RETURN
C              - =0 NORMAL RETURN
C              - =1 ERROR FROM SUB DAYOWK, NO TITLE MADE.
C
C
C REMARKS:
C     THIS TITLER PLACES A DESCRIPTIVE TITLE ON THE TROPICAL ANALYSES.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE:  CRAY 
C
C$$$
      COMMON /TIMES/ NANJI(12)
      COMMON /ADJUST/  IXADJ, IYADJ
      COMMON / DATE / NYR,NMO,NDA,NHR,CDUMP
      CHARACTER*8  CDUMP

      CHARACTER*4  CSTOR
C
C
C     ...COMMON TIMES IS COMMON TO MAIN(PLOTOB) AND REDADP.
C
      CHARACTER*8     DHMBS     
C
      CHARACTER*4  AA(3)
      DATA         AA          /3*'AAAA'/
      CHARACTER*4 TITLE(7)
      DATA        TITLE      /'    ','    ','HHZ ','THU ','   A',
     1                        'PR 1','989 '/
      CHARACTER*4 MONAM(12)
      DATA        MONAM      /'JAN ','FEB ','MAR ','APR ','MAY ',
     1                        'JUN ','JUL ','AUG ','SEP ','OCT ',
     2                        'NOV ','DEC '/
C???  INTEGER   IACCIR       /Z4C000000/
C???  INTEGER   IOPCIR       /Z4D000000/
C???  INTEGER   ISRCIR       /ZE0000000/
      INTEGER   IWORK(4)
      INTEGER   IPRIOR(2)
      CHARACTER*1 TEXT(8)
      CHARACTER*8 CWORK
      CHARACTER*4   IHDAYW
      INTEGER     ITEXT
      EQUIVALENCE (TEXT(1),ITEXT)
C
C     *     *     *     *     *     *     *     *     *     *     *
C
      IERR = 0
C
C     CONVERT TIMES TO INTEGER
C
C     PRINT 214, NANJI(1),NANJI(2)
  214 FORMAT (1X, Z16,4X,Z16)
C     PRINT 215, NANJI(1),NANJI(2)
  215 FORMAT (1X, A8,12X,A8 )
C
      ITEXT = NANJI(1)
c     CALL ASC2INT(2,TEXT(5),IWORK(1),IERR)
c     CALL ASC2INT(2,TEXT(7),IWORK(2),IERR)
      ITEXT = NANJI(2)
c     CALL ASC2INT(2,TEXT(5),IWORK(3),IERR)
c     CALL ASC2INT(2,TEXT(7),IWORK(4),IERR)
C     CALL FFA2I(NANJI,1,2,4,IWORK,IERR)
      IYR =  NYR     + 1900
      IF(IYR .LT. 1950)  IYR = IYR + 100
      IMO =  NMO
      IDA =  NDA
      IHR =  NHR 
      PRINT *, ' IYR=',IYR,' IMO=',IMO,' IDA=',IDA,' IHR=',IHR
      CALL DAYOWK(IDA,IMO,IYR,IDAYWK,IHDAYW)
      IF (IDAYWK.NE.0) GO TO 40
      IERR = 1
      GO TO 100
   40 CONTINUE
C
C       MOVE DUMP TIME INTO FIRST 8 BYTES OF TITLE ARRAY
C
C      CALL MOVCH(8,CDUMP,1 ,TITLE,1)
C
C       MOVE HOUR INTO BYTES 9-10 OF TITLE ARRAY
C
C     CALL INT2CH(IHR,CWORK,2,'L999')
C      CALL MOVCH(2,CWORK,1,TITLE,9)
      CALL BIN2CH(IHR,CSTOR,2,'A99')
C      PRINT *,'TITLE ',TITLE
       TITLE(3)(1:2)  = CSTOR(1:2) 
C      PRINT *,'TITLE ',TITLE
       
C
C       MOVE DAY OF WEEK INTO BYTES 13-16 OF TITLE ARRAY
C
       CALL MOVCH(4,IHDAYW,1,TITLE,13)
C
C       MOVE DAY OF MONTH INTO BYTES 17-18 OF TITLE ARRAY
C
C     CALL INT2CH(NDA,CWORK,4,'L999')
      CALL BIN2CH(NDA,CWORK,2,'A99')
       TITLE(5)(1:2)=CWORK(1:2)
C      PRINT *,'TITLE ',TITLE
C      CALL MOVCH(2,CWORK,1,TITLE,17)
C
C       MOVE MONTH INTO BYTES 20-23 OF TITLE ARRAY
C
       CALL MOVCH(4,MONAM(IMO),1,TITLE,20)
C
C     CONVERT YEAR TO HOLLERTH
C
C??   CALL FFI2A(IWORK,1,4,1,IYR)
C     CALL INT2CH(IYR,TEXT,4,'L999')
      CALL BIN2CH(IYR,CWORK,4,'A99')
C
C
C       MOVE YEAR INTO BYTES 24-27 OF TITLE ARRAY
C
C??    CALL MOVCH(4,IWORK,1,TITLE,24)
       CALL MOVCH(4,CWORK,1,TITLE,24)
       PRINT *,' TITLE ',TITLE
C
      IXL = I + IXADJ
      JXL = J + IYADJ
      IBORD = IXL + 10
      JBORD = JXL - 2
      IPRIOR(1) = 0
      IPRIOR(2) = 2
      ITAG = 0
C
      HT = 3.0
      ANGLE = 90.0
      NCHAR = 6
      CALL PUTLAB(IXL,JXL,HT,DHMBS,ANGLE,NCHAR,IPRIOR,ITAG)
C
      JXL = JXL + 60
      NCHAR = 9
      CALL PUTLAB(IXL,JXL,HT,'ANALYSIS ',ANGLE,NCHAR,IPRIOR,ITAG)
      JXL = JXL + 90
      NCHAR = 5
      CALL PUTLAB(IXL,JXL,HT,TITLE(1),ANGLE,NCHAR,IPRIOR,ITAG)
      IXL = IXL + 15
      JXL = JXL - 145
      NCHAR = 19
      CALL PUTLAB(IXL,JXL,HT,TITLE(3),ANGLE,NCHAR,IPRIOR,ITAG)
      IXL = IXL + 15
      JXL = JXL + 29
      HT = 1.0
      NCHAR = 1
      TEXT(1) = CHAR(60)
C.....   IT IS A SQUARE
      CALL PUTLAB(IXL,JXL,HT,  TEXT,0.0,NCHAR,IPRIOR,ITAG)
      JXL = JXL + 12
      HT = 5.0
      NCHAR = 8
      CALL PUTLAB(IXL,JXL,HT,'AIRCRAFT',ANGLE,NCHAR,IPRIOR,ITAG)
      JXL = JXL + 54
      HT = 1.0
      NCHAR = 1
      TEXT(1) = CHAR(92)
C.....   IT IS A STAR  
      CALL PUTLAB(IXL,JXL,HT,  TEXT,0.0,NCHAR,IPRIOR,ITAG)
      JXL = JXL + 12
      HT = 5.0
      NCHAR = 9
      CALL PUTLAB(IXL,JXL,HT,'SATELLITE',ANGLE,NCHAR,IPRIOR,ITAG)
      IXL = IXL + 11
      JXL = JXL - 48
      HT = 1.0
      NCHAR = 1
      TEXT(1) = CHAR(40)
C.....   IT IS AN OPEN CIRCLE
      CALL PUTLAB(IXL,JXL,HT,  TEXT,0.0,NCHAR,IPRIOR,ITAG)
      JXL = JXL + 12
      HT = 5.0
      NCHAR = 10
      CALL PUTLAB(IXL,JXL,HT,'RADIOSONDE',ANGLE,NCHAR,IPRIOR,ITAG)
      IXL = IXL + 11
      JXL = JXL - 54
      NCHAR = 26
      CALL PUTLAB(IXL,JXL,HT,'WIND WITH NO STN CIRCLE IS',
     X            ANGLE,NCHAR,IPRIOR,ITAG)
      IXL = IXL + 11
      JXL = JXL + 6
      NCHAR = 24
      CALL PUTLAB(IXL,JXL,HT,'ANALYZED GRIDPOINT VALUE',
     X            ANGLE,NCHAR,IPRIOR,ITAG)
C
C     ...BORDER...
C
      HT = 16.0
      ANGLE = 0.0
      NCHAR = 5
      IXL = IBORD - 27
      JXL = JBORD - 10
      CALL PUTLAB(IXL,JXL,HT,AA(1),ANGLE,NCHAR,IPRIOR,ITAG)
      JXL = JXL + 220
      CALL PUTLAB(IXL,JXL,HT,AA(1),ANGLE,NCHAR,IPRIOR,ITAG)
      HT = 17.0
      NCHAR = 11
      JXL = JBORD - 10
      CALL PUTLAB(IXL,JXL,HT,AA(1),ANGLE,NCHAR,IPRIOR,ITAG)
      IXL = IXL + 95
      CALL PUTLAB(IXL,JXL,HT,AA(1),ANGLE,NCHAR,IPRIOR,ITAG)
C
 100  RETURN
      END
