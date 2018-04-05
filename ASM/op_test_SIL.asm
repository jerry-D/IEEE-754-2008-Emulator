           CPU  "SYMPL64_IL.TBL"
           HOF  "MOT32"
           WDLN 8
           ; version 2.01   March 20, 2018
           ; Author:  Jerry D. Harthcock
           ; SYMPL 64-BIT IEEE 754-2008 Floating-Point Emulator assember test for SYMPL IL with some straight assembly examples
           
;private dword storage
bitbucket:  EQU     0x0000                   ;this dword location is reserved.  Don't use it for anything because a lot of garbage can wind up here
work_1:     EQU     0x0008                    
work_2:     EQU     0x0010
work_3:     EQU     0x0018
capt0_save: EQU     0x0020                  ;alternate delayed exception capture register 0 save location
capt1_save: EQU     0x0028                  ;alternate delayed exception capture register 1 save location
capt2_save: EQU     0x0030                  ;alternate delayed exception capture register 2 save location
capt3_save: EQU     0x0038                  ;alternate delayed exception capture register 3 save location


            org    0x0000
_5p0:       dff    0, 5.0
_2p0:       dff    0, 2.0     


            org     0x00FE              

Constants:  DFL     start                   ;program memory locations 0x000 - 0x0FF reserved for look-up table
        
prog_len:   DFL     progend - Constants
              
;           type    dest = OP:(type:srcA, type:srcB) 

            org     0x00000100                               ;default interrupt/trap vector locations
load_vects: 
            uh      NMI_VECT = uh:#NMI_                      ;load of interrupt vectors for faster interrupt response
            uh      IRQ_VECT = uh:#IRQ_                      ;these registers are presently not visible to app s/w
            uh      INV_VECT = uh:#INV_
            uh      DIVx0_VECT = uh:#DIVx0_
            uh      OVFL_VECT = uh:#OVFL_
            uh      UNFL_VECT = uh:#UNFL_
            uh      INEXT_VECT = uh:#INEXT_
            uw      TIMER = uw:#0x60000                      ;load time-out timer with sufficient time to process before timeout
                    GOTO start
done:                   
                    setDone
spin:               GOTO spin

start:  
                    clearDone
            uw      work_1  = uw:@_5p0                       
            uw      work_2  = uw:@_2p0
            fs      creg = fs:work_1
            fh      rem.15 = remainder:(fs:work_1, fs:work_2)           ;14 clocks
            fh      fma.15 = fusedMultiplyAdd:(fs:work_1, fs:work_2, C) ;6 clocks
            fh      fmul.15 = multiplication:(fs:work_1, fs:work_2)     ;4 clocks
            fh      fadd.15 = addition:(fs:work_1, fs:work_2)           ;5 clocks
            fh      fsub.15 = subtraction:(fs:work_1, fs:work_2)        ;5 clocks
            fh      fdiv.15 = division:(fs:work_1, fs:work_2)           ;8 clocks
            fh      log.15 = log:(fs:work_1)                            ;9 clocks
            fh      exp.15 = exp:(fh:log.15)                            ;5 clocks
            fh      sqrt.15 = squareRoot:(fs:work_1)                    ;6 clocks
            fh      sind.3 = sind:(uh:#30)                              ;3 clocks
            fh      cosd.3 = cosd:(uh:#122)                             ;3 clocks
            fh      tand.3 = tand:(uh:#223)                             ;3 clocks
            fh      cotd.3 = cotd:(uh:#98)                              ;3 clocks
            fh      pow.15 = pow:(fs:work_1, fs:work_2)                 ;13 clocks
            fh      pow.14 = pown:(fs:work_1, xfs:work_2)               ;13 clocks
            fh      pow.13 = powr:(xfs:work_1, fs:work_2)               ;13 clocks
            uh      work_3 = uh:#0x3579
            
            rh.e    rtoi.15 = roundToIntegralTiesToEven:(fh:fdiv.15)     ;3 clocks
            rh.a    rtoi.14 = roundToIntegralTiesToAway:(fh:fdiv.15)     ;3 clocks   
            rh.z    rtoi.13 = roundToIntegralTowardZero:(fh:fdiv.15)     ;3 clocks   
            rh.p    rtoi.12 = roundToIntegralTowardPositive:(fh:fdiv.15) ;3 clocks
            rh.n    rtoi.11 = roundToIntegralTowardNegative:(fh:fdiv.15) ;3 clocks
            fh      rtoi.10 = roundToIntegralExact:(fh:fdiv.15)          ;3 clocks
            fh.p    rtoi.8  = roundToIntegralExact:(fh:fdiv.15)          ;3 clocks
            fh.n    rtoi.7  = roundToIntegralExact:(fh:fdiv.15)          ;3 clocks
            fh.z    rtoi.6  = roundToIntegralExact:(fh:fdiv.15)          ;3 clocks
                                                                         
            fh      itof.15 = convertFromInt:(uh:#0x0022)                ;2 clocks
            fh.p    itof.13 = convertFromInt:(uh:#0x0022)                ;2 clocks
            fh.n    itof.12 = convertFromInt:(uh:#0x0022)                ;2 clocks
            fh.z    itof.11 = convertFromInt:(uh:#0x0022)                ;2 clocks
            uw.e    ftoi.15 = convertToIntegerTiesToEven:(fh:itof.15)         ;3 clocks
            uw.z    ftoi.14 = convertToIntegerTowardZero:(fh:itof.15)         ;3 clocks    
            uw.p    ftoi.13 = convertToIntegerTowardPositive:(fh:itof.15)     ;3 clocks    
            uw.n    ftoi.12 = convertToIntegerTowardNegative:(fh:itof.15)     ;3 clocks    
            uw.a    ftoi.11 = convertToIntegerTiesToAway:(fh:itof.15)         ;3 clocks  
            uw.ex   ftoi.10 = convertToIntegerExactTiesToEven:(fh:itof.15)    ;3 clocks   
            uw.zx   ftoi.9  = convertToIntegerExactTowardZero:(fh:itof.15)    ;3 clocks    
            uw.px   ftoi.8  = convertToIntegerExactTowardPositive:(fh:itof.15);3 clocks 
            uw.nx   ftoi.7  = convertToIntegerExactTowardNegative:(fh:itof.15);3 clocks 
            uw.ax   ftoi.6  = convertToIntegerExactTiesToAway:(fh:itof.15)    ;3 clocks 
            fh      logb.15     = logB:(fh:itof.15)                 ;4 clocks        
            fh      scaleB.15   = scaleB:(fh:itof.15, fs:work_2)    ;4 clocks              
            fh      nextUp.7    = nextUp:(fh:itof.15)               ;3 clocks
            fh      nextDown.7  = nextDown:(fs:work_2)              ;3 clocks
            fh      minNum.3    = minNum:(fs:work_2, fs:work_1)     ;3 clocks        
            fh      maxNum.3    = maxNum:(fs:work_2, fs:work_1)     ;3 clocks        
            fh      copy.3      = copy:(fh:sqrt.15)                 ;3 clocks
            fh      negate.3    = negate:(fs:work_2)                ;3 clocks
            fh      abs.3       = abs:(fh:negate.3)                 ;3 clocks
            fh      copySign.3  = copySign:(fs:work_1, fh:negate.3) ;3 clocks
            fs      conv.15     = convertFormat:(fs:work_1)         ;3 clocks
             
;            ud      cnvTDCS.15  = convertToDecimalCharacter:(fh:rem.15, ub:#0)    ;8 clocks
            ud      cnvTDCS.15  = convertToDecimalCharacter:(fh:pow.15, ub:#0)     ;8 clocks
            ud      cnvTDCS.14  = convertToDecimalCharacter:(fh:fma.15, ub:#0)     ;8 clocks
            ud      cnvTDCS.13  = convertToDecimalCharacter:(fh:fdiv.15, ub:#0)    ;8 clocks
            ud      cnvTDCS.12  = convertToDecimalCharacter:(fh:log.15, ub:#0)     ;8 clocks
            ud      cnvTDCS.11  = convertToDecimalCharacter:(fh:exp.15, ub:#0)     ;8 clocks
            ud      cnvTDCS.10  = convertToDecimalCharacter:(fh:sqrt.15, ub:#0)    ;8 clocks
            ud      cnvTDCS.9   = convertToDecimalCharacter:(fh:rtoi.15, ub:#0)    ;8 clocks
            ud      cnvTDCS.8   = convertToDecimalCharacter:(fh:itof.15, ub:#0)    ;8 clocks
            ud      cnvTDCS.7   = convertToDecimalCharacter:(fh:logb.15, ub:#0)    ;8 clocks
            ud      cnvTDCS.6   = convertToDecimalCharacter:(fh:scaleb.15, ub:#0)  ;8 clocks
            ud      cnvTDCS.5   = convertToDecimalCharacter:(fh:nextUp.7, ub:#0)   ;8 clocks
            ud      cnvTDCS.4   = convertToDecimalCharacter:(fh:nextDown.7, ub:#0) ;8 clocks
            ud      cnvTDCS.3   = convertToDecimalCharacter:(fh:minNum.3, ub:#0)   ;8 clocks
            ud      cnvTDCS.2   = convertToDecimalCharacter:(fh:maxNum.3, ub:#0)   ;8 clocks
            ud      cnvTDCS.1   = convertToDecimalCharacter:(fh:negate.3, ub:#0)   ;8 clocks
            ud      cnvTDCS.0   = convertToDecimalCharacter:(fh:copySign.3, ub:#0) ;8 clocks

            fh      cnvFDCS.15  = convertFromDecimalCharacter:(ud:cnvTDCS.15, sd:cnvTDCS.15)  ;7 clocks
            fh      cnvFDCS.14  = convertFromDecimalCharacter:(ud:cnvTDCS.14, sd:cnvTDCS.14)  ;7 clocks
            fh      cnvFDCS.13  = convertFromDecimalCharacter:(ud:cnvTDCS.13, sd:cnvTDCS.13)  ;7 clocks
            fh      cnvFDCS.12  = convertFromDecimalCharacter:(ud:cnvTDCS.12, sd:cnvTDCS.12)  ;7 clocks
            fh      cnvFDCS.11  = convertFromDecimalCharacter:(ud:cnvTDCS.11, sd:cnvTDCS.11)  ;7 clocks
            fh      cnvFDCS.10  = convertFromDecimalCharacter:(ud:cnvTDCS.10, sd:cnvTDCS.10)  ;7 clocks
            fh      cnvFDCS.9   = convertFromDecimalCharacter:(ud:cnvTDCS.9 , sd:cnvTDCS.9 )  ;7 clocks
            fh      cnvFDCS.8   = convertFromDecimalCharacter:(ud:cnvTDCS.8 , sd:cnvTDCS.8 )  ;7 clocks
            fh      cnvFDCS.7   = convertFromDecimalCharacter:(ud:cnvTDCS.7 , sd:cnvTDCS.7 )  ;7 clocks
            fh      cnvFDCS.6   = convertFromDecimalCharacter:(ud:cnvTDCS.6 , sd:cnvTDCS.6 )  ;7 clocks
            fh      cnvFDCS.5   = convertFromDecimalCharacter:(ud:cnvTDCS.5 , sd:cnvTDCS.5 )  ;7 clocks
            fh      cnvFDCS.4   = convertFromDecimalCharacter:(ud:cnvTDCS.4 , sd:cnvTDCS.4 )  ;7 clocks
            fh      cnvFDCS.3   = convertFromDecimalCharacter:(ud:cnvTDCS.3 , sd:cnvTDCS.3 )  ;7 clocks
            fh      cnvFDCS.2   = convertFromDecimalCharacter:(ud:cnvTDCS.2 , sd:cnvTDCS.2 )  ;7 clocks
            fh      cnvFDCS.1   = convertFromDecimalCharacter:(ud:cnvTDCS.1 , sd:cnvTDCS.1 )  ;7 clocks
            fh      cnvFDCS.0   = convertFromDecimalCharacter:(ud:cnvTDCS.0 , sd:cnvTDCS.0 )  ;7 clocks
            
            ud      cnvTHCS.15  = convertToHexCharacter:(fh:rem.15, ub:#0)     ;5 clocks       
            ud      cnvTHCS.14  = convertToHexCharacter:(fh:fma.15, ub:#0)     ;5 clocks       
            ud      cnvTHCS.13  = convertToHexCharacter:(fh:fdiv.15, ub:#0)    ;5 clocks        
            ud      cnvTHCS.12  = convertToHexCharacter:(fh:log.15, ub:#0)     ;5 clocks       
            ud      cnvTHCS.11  = convertToHexCharacter:(fh:exp.15, ub:#0)     ;5 clocks       
            ud      cnvTHCS.10  = convertToHexCharacter:(fh:sqrt.15, ub:#0)    ;5 clocks        
            ud      cnvTHCS.9   = convertToHexCharacter:(fh:rtoi.15, ub:#0)    ;5 clocks        
            ud      cnvTHCS.8   = convertToHexCharacter:(fh:itof.15, ub:#0)    ;5 clocks        
            ud      cnvTHCS.7   = convertToHexCharacter:(fh:logb.15, ub:#0)    ;5 clocks        
            ud      cnvTHCS.6   = convertToHexCharacter:(fh:scaleb.15, ub:#0)  ;5 clocks        
            ud      cnvTHCS.5   = convertToHexCharacter:(fh:nextUp.7, ub:#0)   ;5 clocks         
            ud      cnvTHCS.4   = convertToHexCharacter:(fh:nextDown.7, ub:#0) ;5 clocks           
            ud      cnvTHCS.3   = convertToHexCharacter:(fh:minNum.3, ub:#0)   ;5 clocks         
            ud      cnvTHCS.2   = convertToHexCharacter:(fh:maxNum.3, ub:#0)   ;5 clocks         
            ud      cnvTHCS.1   = convertToHexCharacter:(fh:negate.3, ub:#0)   ;5 clocks         
            ud      cnvTHCS.0   = convertToHexCharacter:(fh:copySign.3, ub:#0) ;5 clocks
            
            fh      cnvFHCS.15  = convertFromHexCharacter:(ud:cnvTHCS.15, sd:cnvTHCS.15) ;7 clocks                          
            fh      cnvFHCS.14  = convertFromHexCharacter:(ud:cnvTHCS.14, sd:cnvTHCS.14) ;7 clocks                          
            fh      cnvFHCS.13  = convertFromHexCharacter:(ud:cnvTHCS.13, sd:cnvTHCS.13) ;7 clocks                          
            fh      cnvFHCS.12  = convertFromHexCharacter:(ud:cnvTHCS.12, sd:cnvTHCS.12) ;7 clocks                          
            fh      cnvFHCS.11  = convertFromHexCharacter:(ud:cnvTHCS.11, sd:cnvTHCS.11) ;7 clocks                          
            fh      cnvFHCS.10  = convertFromHexCharacter:(ud:cnvTHCS.10, sd:cnvTHCS.10) ;7 clocks                          
            fh      cnvFHCS.9   = convertFromHexCharacter:(ud:cnvTHCS.9 , sd:cnvTHCS.9 ) ;7 clocks                          
            fh      cnvFHCS.8   = convertFromHexCharacter:(ud:cnvTHCS.8 , sd:cnvTHCS.8 ) ;7 clocks                          
            fh      cnvFHCS.7   = convertFromHexCharacter:(ud:cnvTHCS.7 , sd:cnvTHCS.7 ) ;7 clocks                          
            fh      cnvFHCS.6   = convertFromHexCharacter:(ud:cnvTHCS.6 , sd:cnvTHCS.6 ) ;7 clocks                          
            fh      cnvFHCS.5   = convertFromHexCharacter:(ud:cnvTHCS.5 , sd:cnvTHCS.5 ) ;7 clocks                          
            fh      cnvFHCS.4   = convertFromHexCharacter:(ud:cnvTHCS.4 , sd:cnvTHCS.4 ) ;7 clocks                          
            fh      cnvFHCS.3   = convertFromHexCharacter:(ud:cnvTHCS.3 , sd:cnvTHCS.3 ) ;7 clocks                          
            fh      cnvFHCS.2   = convertFromHexCharacter:(ud:cnvTHCS.2 , sd:cnvTHCS.2 ) ;7 clocks                          
            fh      cnvFHCS.1   = convertFromHexCharacter:(ud:cnvTHCS.1 , sd:cnvTHCS.1 ) ;7 clocks                          
            fh      cnvFHCS.0   = convertFromHexCharacter:(ud:cnvTHCS.0 , sd:cnvTHCS.0 ) ;7 clocks                          
            
            ub      clas        = class:(fs:work_2)    ;1 clock
                                    
            uw.rdx  work_3      = radix:(fs:work_2)    ;1 clock
                      
                    isSignMinus(fh:negate.3)           ;1 clock
                    isNormal(fh:sqrt.15)               ;1 clock
                    isFinite(fh:sqrt.15)               ;1 clock
                    isZero(fh:sqrt.15)                 ;1 clock
                    isSubnormal(fh:sqrt.15)            ;1 clock
                    isInfinite(fh:sqrt.15)             ;1 clock
                    isNaN(fh:sqrt.15)                  ;1 clock
                    isSignaling(fh:sqrt.15)            ;1 clock
                    isCanonical(fh:sqrt.15)            ;1 clock

                    compareSignalingEqual(fs:work_1, fs:work_2)            ;1 clock
                    compareQuietEqual(fs:work_1, fs:work_2)                ;1 clock
                    compareSignalingNotEqual(fs:work_1, fs:work_2)         ;1 clock
                    compareQuietNotEqual(fs:work_1, fs:work_2)             ;1 clock
                    compareSignalingGreater(fs:work_1, fs:work_2)          ;1 clock
                    compareQuietGreater(fs:work_1, fs:work_2)              ;1 clock
                    compareSignalingGreaterEqual(fs:work_1, fs:work_2)     ;1 clock
                    compareQuietGreaterEqual(fs:work_1, fs:work_2)         ;1 clock
                    compareSignalingLess(fs:work_1, fs:work_2)             ;1 clock
                    compareQuietLess(fs:work_1, fs:work_2)                 ;1 clock
                    compareSignalingLessEqual(fs:work_1, fs:work_2)        ;1 clock
                    compareQuietLessEqual(fs:work_1, fs:work_2)            ;1 clock
                    compareSignalingNotGreater(fs:work_1, fs:work_2)       ;1 clock
                    compareQuietNotGreater(fs:work_1, fs:work_2)           ;1 clock
                    compareSignalingLessUnordered(fs:work_1, fs:work_2)    ;1 clock
                    compareQuietLessUnordered(fs:work_1, fs:work_2)        ;1 clock
                    compareSignalingNotLess(fs:work_1, fs:work_2)          ;1 clock
                    compareQuietNotLess(fs:work_1, fs:work_2)              ;1 clock
                    compareSignalingGreaterUnordered(fs:work_1, fs:work_2) ;1 clock
                    compareQuietGreaterUnordered(fs:work_1, fs:work_2)     ;1 clock   
                    compareQuietUnordered(fs:work_1, fs:work_2)            ;1 clock
                    compareQuietOrdered(fs:work_1, fs:work_2)              ;1 clock
                    
                    enableInt               ;1 clock
                    disableInt              ;1 clock
                    setV                    ;1 clock
                    clearV                  ;1 clock
                    setN                    ;1 clock
                    clearN                  ;1 clock
                    setC                    ;1 clock
                    clearC                  ;1 clock
                    setZ                    ;1 clock
                    clearZ                  ;1 clock
                    setSubsInexact          ;1 clock
                    clearSubsInexact        ;1 clock
                    setSubssubsUnderflow    ;1 clock    
                    clearSubssubsUnderflow  ;1 clock    
                    setsubsOverflow         ;1 clock    
                    clearsubsOverflow       ;1 clock    
                    setsubsDivByZero        ;1 clock   
                    clearsubsDivByZero      ;1 clock    
                    setsubsInvalid          ;1 clock    
                    clearsubsInvalid        ;1 clock    
                    
                    totalOrder(fs:work_1, fs:work_2)      ;1 clock
                    totalOrderMag(fs:work_1, fs:work_2)   ;1 clock                                  
                      
                    setBinaryRoundingDirection(NEAREST)   ;1 clock
                    setBinaryRoundingDirection(AWAY)      ;1 clock
                    getBinaryRoundingDirection()          ;1 clock
                    setBinaryRoundingDirection(POSITIVE)  ;1 clock
                    saveModes()                           ;1 clock
                    setBinaryRoundingDirection(NEGATIVE)  ;1 clock
                    setBinaryRoundingDirection(ZERO)      ;1 clock
                    restoreModes(ub:savedModes)           ;1 clock
                    defaultModes()                        ;1 clock
                    
                    raiseFlags(ub:#{invalid | overflow | inexact})  ;1 clock
                    is754version1985()                      ;1 clock
                    is754version2008()                      ;1 clock
                    saveAllFlags()                                                       ;1 clock
                    testFlags(ub:#invalid)                                               ;1 clock
                    lowerFlags(ub:#{invalid | overflow | inexact})                       ;1 clock
                    restoreFlags(ub: savedFlags, ub:#{invalid | overflow | underflow})   ;1 clock
                    raiseFlags(ub:#{divByZero | underflow})                              ;1 clock
                    lowerFlags(ub:#{divByZero | underflow})                              ;1 clock
                    raiseNoFlag(ub:#overflow)                                            ;1 clock
                    default(ub:#{overflow | inexact})                                    ;1 clock
                    raiseNoFlag(ub:#inexact)                                             ;1 clock
                                          
                    testSavedFlags(ub: savedFlags, ub:#{invalid | overflow | underflow}) ;1 clock
                    
                    raiseSignals(ub:#{invalid | overflow | inexact})                     ;1 clock
                    lowerSignals(ub:#{invalid | overflow | inexact})                     ;1 clock
                    raiseSignals(ub:#{divByZero | underflow})                            ;1 clock
                    lowerSignals(ub:#{divByZero | underflow})                            ;1 clock
                    
                    enableAltImmediateHandlers(ub:#{invalid | overflow | inexact})       ;1 clock
                    disableAltImmediateHandlers(ub:#{invalid | overflow | inexact})      ;1 clock
                    enableAltImmediateHandlers(ub:#{divByZero | underflow})              ;1 clock
                    disableAltImmediateHandlers(ub:#{divByZero | underflow})             ;1 clock
                    enableAltImmediateHandlers(ub:#divByZero)                            ;1 clock

                    IF (754version1985) GOTO: goback               ;1 clock
                    IF (754version2008) GOTO: goback               ;1 clock
                    IF (signalingNaN) GOTO: goback                 ;1 clock                                         
                    IF (quietNaN) GOTO: goback                     ;1 clock                                         
                    IF (negativeInfinity) GOTO: goback             ;1 clock                                         
                    IF (negativeNormal) GOTO: goback               ;1 clock                                         
                    IF (negativeSubnormal) GOTO: goback            ;1 clock                                         
                    IF (negativeZero) GOTO: goback                 ;1 clock                                         
                    IF (positiveZero) GOTO: goback                 ;1 clock                                         
                    IF (positiveSubnormal) GOTO: goback            ;1 clock                                         
                    IF (positiveNormal) GOTO: goback               ;1 clock                                         
                    IF (positiveInfinity) GOTO: goback             ;1 clock                                         
                    IF (SignMinus) GOTO: goback                    ;1 clock                                         
                    IF (Normal) GOTO: goback                       ;1 clock                                         
                    IF (Finite) GOTO: goback                       ;1 clock                                         
                    IF (Zero) GOTO: goback                         ;1 clock                                         
                    IF (Subnormal) GOTO: goback                    ;1 clock                                         
                    IF (Infinite) GOTO: goback                     ;1 clock                                         
                    IF (NaN) GOTO: goback                          ;1 clock                                         
                    IF (Signaling) GOTO: goback                    ;1 clock                                         
                    IF (Canonical) GOTO: goback                    ;1 clock                                         
                    IF (totalOrder) GOTO: goback                   ;1 clock                                         
                    IF (totalOrderMag) GOTO: goback                ;1 clock                                         
                    IF (aFlagRaised) GOTO: goback                  ;1 clock                                         
                    IF (compareTrue) GOTO: goback                  ;1 clock
                    
                    IF NOT(754version1985) GOTO: goback            ;1 clock
                    IF NOT(754version2008) GOTO: goback            ;1 clock                                             
                    IF NOT(signalingNaN) GOTO: goback              ;1 clock                                         
                    IF NOT(quietNaN) GOTO: goback                  ;1 clock                                         
                    IF NOT(negativeInfinity) GOTO: goback          ;1 clock                                         
                    IF NOT(negativeNormal) GOTO: goback            ;1 clock                                         
                    IF NOT(negativeSubnormal) GOTO: goback         ;1 clock                                         
                    IF NOT(negativeZero) GOTO: goback              ;1 clock                                         
                    IF NOT(positiveZero) GOTO: goback              ;1 clock                                         
                    IF NOT(positiveSubnormal) GOTO: goback         ;1 clock                                         
                    IF NOT(positiveNormal) GOTO: goback            ;1 clock                                         
                    IF NOT(positiveInfinity) GOTO: goback          ;1 clock                                         
                    IF NOT(SignMinus) GOTO: goback                 ;1 clock                                         
                    IF NOT(Normal) GOTO: goback                    ;1 clock                                         
                    IF NOT(Finite) GOTO: goback                    ;1 clock                                         
                    IF NOT(Zero) GOTO: goback                      ;1 clock                                         
                    IF NOT(Subnormal) GOTO: goback                 ;1 clock                                         
                    IF NOT(Infinite) GOTO: goback                  ;1 clock                                         
                    IF NOT(NaN)  GOTO: goback                      ;1 clock                                         
                    IF NOT(Signaling) GOTO: goback                 ;1 clock                                         
                    IF NOT(Canonical) GOTO: goback                 ;1 clock                                         
                    IF NOT(totalOrder) GOTO: goback                ;1 clock                                         
                    IF NOT(totalOrderMag) GOTO: goback             ;1 clock                                         
                    IF NOT(aFlagRaised) GOTO: goback               ;1 clock                                         
                    IF NOT(compareTrue) GOTO: goback               ;1 clock                                         
                    IF (signalingNaN) GOSUB: goback                ;1 clock                                         
                    IF (quietNaN) GOSUB: goback                    ;1 clock                                         
                    IF (negativeInfinity) GOSUB: goback            ;1 clock                                         
                    IF (negativeNormal) GOSUB: goback              ;1 clock                                         
                    IF (negativeSubnormal) GOSUB: goback           ;1 clock                                         
                    IF (negativeZero) GOSUB: goback                ;1 clock                                         
                    IF (positiveZero) GOSUB: goback                ;1 clock                                         
                    IF (positiveSubnormal) GOSUB: goback           ;1 clock                                         
                    IF (positiveNormal) GOSUB: goback              ;1 clock                                         
                    IF (positiveInfinity) GOSUB: goback            ;1 clock                                         
                    IF (SignMinus) GOSUB: goback                   ;1 clock                                         
                    IF (Normal) GOSUB: goback                      ;1 clock                                         
                    IF (Finite) GOSUB: goback                      ;1 clock                                         
                    IF (Zero) GOSUB: goback                        ;1 clock                                         
                    IF (Subnormal) GOSUB: goback                   ;1 clock                                         
                    IF (Infinite) GOSUB: goback                    ;1 clock                                         
                    IF (NaN) GOSUB: goback                         ;1 clock                                         
                    IF (Signaling) GOSUB: goback                   ;1 clock                                         
                    IF (Canonical) GOSUB: goback                   ;1 clock                                         
                    IF (totalOrder) GOSUB: goback                  ;1 clock                                         
                    IF (totalOrderMag) GOSUB: goback               ;1 clock                                         
                    IF (aFlagRaised) GOSUB: goback                 ;1 clock                                         
                    IF (compareTrue) GOSUB: goback                 ;1 clock                                         
                    IF NOT(signalingNaN) GOSUB: goback             ;1 clock                                         
                    IF NOT(quietNaN) GOSUB: goback                 ;1 clock                                         
                    IF NOT(negativeInfinity) GOSUB: goback         ;1 clock                                         
                    IF NOT(negativeNormal) GOSUB: goback           ;1 clock                                         
                    IF NOT(negativeSubnormal) GOSUB: goback        ;1 clock                                         
                    IF NOT(negativeZero) GOSUB: goback             ;1 clock                                         
                    IF NOT(positiveZero) GOSUB: goback             ;1 clock                                         
                    IF NOT(positiveSubnormal) GOSUB: goback        ;1 clock                                         
                    IF NOT(positiveNormal) GOSUB: goback           ;1 clock                                         
                    IF NOT(positiveInfinity) GOSUB: goback         ;1 clock                                         
                    IF NOT(SignMinus) GOSUB: goback                ;1 clock                                         
                    IF NOT(Normal) GOSUB: goback                   ;1 clock                                         
                    IF NOT(Finite) GOSUB: goback                   ;1 clock                                         
                    IF NOT(Zero) GOSUB: goback                     ;1 clock                                         
                    IF NOT(Subnormal) GOSUB: goback                ;1 clock                                         
                    IF NOT(Infinite) GOSUB: goback                 ;1 clock                                         
                    IF NOT(NaN)  GOSUB: goback                     ;1 clock                                         
                    IF NOT(Signaling) GOSUB: goback                ;1 clock                                         
                    IF NOT(Canonical) GOSUB: goback                ;1 clock                                         
                    IF NOT(totalOrder) GOSUB: goback               ;1 clock                                         
                    IF NOT(totalOrderMag) GOSUB: goback            ;1 clock                                         
                    IF NOT(aFlagRaised) GOSUB: goback              ;1 clock                                         
                    IF NOT(compareTrue) GOSUB: goback              ;1 clock
                    
            ;integer operators
            uh      and.3 = and:(uh:work_3, uh:#0x5555)            ;2 clocks
            uh      or.3 = or:(uh:work_3, uh:#0x5555)              ;2 clocks                    
            uh      xor.3 = xor:(uh:work_3, uh:#0x5555)            ;2 clocks
            uh      add.3 = add:(uh:work_3, uh:#0x5555)            ;2 clocks
                    setC
            sh      add.4 = addc:(uh:work_3, sh:#0x5555)           ;2 clocks      signed add with carry
            uh      sub.3 = sub:(uh:work_3, uh:#0x0055)            ;2 clocks
                    setC
            sh      sub.4 = subb:(uh:work_3, sh:#0x0055)           ;2 clocks   signed subtract with borrow
            uh      mul.3 = mul:(uh:work_3, uh:#0x5555)            ;2 clocks
            uw      div.15 = div:(uw:mul.3, uh:#0x0055)            ;11 clocks
            uh      min.3 = min:(uh:work_3, uh:#0x5555)            ;2 clocks
            uh      max.3 = max:(uh:work_3, uh:#0x5555)            ;2 clocks
            uh      bset.3 = bset:(uh:work_3, ub:#1)               ;2 clocks
            
            uh      bclr.3 = bclr:(uh:bset.3, ub:#1)               ;2 clocks
                    . uh:bclr.3, uh:bset.3, ub:#1
                     
                    compare(uw:div.15, uh:#0x5555)                 ;1 clock
                    compare(uw:work_1, uw:work_2)                  ;1 clock
                    . ub:compare, uw:work_1, uw:work_2
                    
            uw      shift.0 = shift:(uh:work_3, LEFT, 1)           ;2 clocks
            uw      shift.1 = shift:(uh:work_3, RIGHT, 3)          ;2 clocks
            uw      shift.2 = shift:(uh:work_3, LSL, 10)           ;2 clocks
            uw      shift.3 = shift:(uh:work_3, ASL, 5)            ;2 clocks
            uw      shift.4 = shift:(uh:work_3, ROL, 8)            ;2 clocks
            uw      shift.5 = shift:(uh:work_3, LSR, 6)            ;2 clocks
            uw      shift.6 = shift:(uh:work_3, ASR, 14)           ;2 clocks
            uw      shift.7 = shift:(uh:work_3, ROR, 20)           ;2 clocks
            
                    . uw:shift.0, uh:work_3, LEFT, 1 
                    . uw:shift.1, uh:work_3, RIGHT, 3 
                    . uw:shift.2, uh:work_3, LSL, 10 
                    . uw:shift.3, uh:work_3, ASL, 5  
                    . uw:shift.4, uh:work_3, ROL, 8  
                    . uw:shift.5, uh:work_3, LSR, 6  
                    . uw:shift.6, uh:work_3, ASR, 14 
                    . uw:shift.7, uh:work_3, ROR, 20 
            
            ud      endi.0 = endi:(ud:cnvTDCS.15)                  ;2 clocks
                    . ud:endi.0, ud:cnvTDCS.15
            
            ud      cnvFBTA.15 = convertFromBinaryToASCII:(uw:#0xA5632504) ;2 clocks
                    . ud:cnvFBTA.15, uw:#0xA5632504
            uw      cnvTBFA.15 = convertToBinaryFromASCII:(ud:cnvFBTA.15) ;2 clocks
                    . uw:cnvTBFA.15, ud:cnvFBTA.15 

                    IF (Z==1) GOTO: goback            ;1 clock
                    IF (Z==0) GOTO: goback            ;1 clock
                    IF (A==B) GOTO: goback            ;1 clock
                    IF (A!=B) GOTO: goback            ;1 clock
                    IF (C==1) GOTO: goback            ;1 clock
                    IF (C==0) GOTO: goback            ;1 clock
                    IF (N==1) GOTO: goback            ;1 clock
                    IF (N==0) GOTO: goback            ;1 clock
                    IF (V==1) GOTO: goback            ;1 clock
                    IF (V==0) GOTO: goback            ;1 clock
                    IF (A<B)  GOTO: goback            ;1 clock
                    IF (A>=B) GOTO: goback            ;1 clock
                    IF (A<=B) GOTO: goback            ;1 clock
                    IF (A>B)  GOTO: goback            ;1 clock
                                                      
                    IF (Z==1) GOSUB: goback           ;1 clock
                    IF (Z==0) GOSUB: goback           ;1 clock
                    IF (A==B) GOSUB: goback           ;1 clock
                    IF (A!=B) GOSUB: goback           ;1 clock
                    IF (C==1) GOSUB: goback           ;1 clock
                    IF (C==0) GOSUB: goback           ;1 clock
                    IF (N==1) GOSUB: goback           ;1 clock
                    IF (N==0) GOSUB: goback           ;1 clock
                    IF (V==1) GOSUB: goback           ;1 clock
                    IF (V==0) GOSUB: goback           ;1 clock
                    IF (A<B)  GOSUB: goback           ;1 clock
                    IF (A>=B) GOSUB: goback           ;1 clock
                    IF (A<=B) GOSUB: goback           ;1 clock
                    IF (A>B)  GOSUB: goback           ;1 clock
                    
                    IF (uw:work_3:[bit8]==0) GOTO: goback    ;1 clock
                    IF (uw:work_3:[bit7]==1) GOTO: goback    ;1 clock
                    IF (uw:work_3:[bit6]==0) GOSUB: goback   ;1 clock
                    IF (uw:work_3:[bit5]==1) GOSUB: goback   ;1 clock
                    
                    btbc uh:work_3, 8, goback
                    btbs uh:work_3, 7, goback
                    btbc uh:work_3, 6, goback
                    btbs uh:work_3, 5, goback
                    
                    . uh:pcc, uw:work_3, 8, goback
                    . uh:pcs, uw:work_3, 7, goback
                    . uh:pcc, uw:work_3, 6, goback
                    . uh:pcs, uw:work_3, 5, goback
                          
                    FOR (LPCNT0 = uw:#3) (       ;1 clock
loop_0:                 nop                      ;1 clock
                        nop                      ;1 clock
                    NEXT LPCNT0 GOTO: loop_0 )   ;1 clock

                    . uw:LPCNT0, uw:#3
loop_1:             . uw:PCS, ud:STATUS, NEVER, loop_1 
                    . uw:PCS, ud:STATUS, NEVER, loop_1 
                    . uw:PCS, ud:LPCNT0, 16, loop_1

                    FOR (LPCNT1 = uw:#3) (       ;1 clock    
loop_2:                 nop                      ;1 clock
                        nop                      ;1 clock
                    NEXT LPCNT1 GOTO: loop_2 )   ;1 clock
                         
                    GOTO goback                  ;1 clock
                    GOSUB goback                 ;1 clock
;                    RETURN

            uw      AR0 = uw:#cnvFDCS.0        ;load AR0 with source address
            uw      AR1 = uw:#cnvTHCS.0        ;load AR1 with destination address      
                    REPEAT uh:#15
            uh      *AR1++[8] = convertToHexCharacter:(uh:*AR0++[8], ub:#0)        

            uw      AR0 = uw:#cnvTHCS.0        ;load AR0 with source address
            uw      AR1 = uw:#cnvFHCS.0        ;load AR1 with destination address 
            uw      AR2 = uw:#15     
                    REPEAT [AR2]
            uh      *AR1++[8] = convertFromHexCharacter:(ud:*AR0++[8], sd:*AR0[0])   ;128-bit (16-byte character string) move (* 16 of them)                         
                 
                    ;test divide by zero alternate immediate exception handling and exception capture registers
            fh      fdiv.14 = division:(fs:work_1, fs:#0x00000000)
            fh      copy.0 = fh:fdiv.14
                                                                          
            
                    GOTO done                      ;branch to done
                    
goback:     uh      PC = uh:PC_COPY 
                    
                    
NMI_:       sh      *SP--[8] = uh:PC_COPY       ;save return address from non-maskable interrupt (time-out timer in this instance)
            uw      TIMER = uw:#60000           ;put a new value in the timer
            sh      PC = uh:*SP++[8]            ;return from interrupt
              
INV_:       sh      *SP--[8] = uh:PC_COPY       ;save return address from floating-point invalid operation exception, which is maskable
            ud      capt0_save = ud:CAPTURE0    ;read out CAPTURE0 register and save it
            ud      capt1_save = ud:CAPTURE1    ;read out CAPTURE1 register and save it
            ud      capt2_save = ud:CAPTURE2    ;read out CAPTURE2 register and save it
            ud      capt3_save = ud:CAPTURE3    ;read out CAPTURE3 register and save it
                    lowerSignals(ub:#invalid)   ;lower invalid signal
                    raiseFlags(ub:#invalid)     ;raise invalid flag   
            uw      TIMER = uw:#60000           ;put a new value in the timer
            sh      PC = uh:*SP++[8]            ;return from interrupt
               
DIVx0_:     sh      *SP--[8] = uh:PC_COPY       ;save return address from floating-point divide by 0 exception, which is maskable
            ud      capt0_save = ud:CAPTURE0    ;read out CAPTURE0 register and save it
            ud      capt1_save = ud:CAPTURE1    ;read out CAPTURE1 register and save it
            ud      capt2_save = ud:CAPTURE2    ;read out CAPTURE2 register and save it
            ud      capt3_save = ud:CAPTURE3    ;read out CAPTURE3 register and save it
                    lowerSignals(ub:#divByZero) ;lower divByZero signal
                    raiseFlags(ub:#divByZero)   ;raise divByZero flag   
            uw      TIMER = uw:#60000           ;put a new value in the timer
            sh      PC = uh:*SP++[8]            ;return from interrupt
               
OVFL_:      sh      *SP--[8] = uh:PC_COPY       ;save return address from floating-point overflow exception, which is maskable
            ud      capt0_save = ud:CAPTURE0    ;read out CAPTURE0 register and save it
            ud      capt1_save = ud:CAPTURE1    ;read out CAPTURE1 register and save it
            ud      capt2_save = ud:CAPTURE2    ;read out CAPTURE2 register and save it
            ud      capt3_save = ud:CAPTURE3    ;read out CAPTURE3 register and save it
                    lowerSignals(ub:#overflow)  ;lower overflow signal
                    raiseFlags(ub:#overflow)    ;raise overflow flag   
            uw      TIMER = uw:#60000           ;put a new value in the timer
            sh      PC = uh:*SP++[8]            ;return from interrupt
               
UNFL_:      sh      *SP--[8] = uh:PC_COPY       ;save return address from floating-point underflow exception, which is maskable
            ud      capt0_save = ud:CAPTURE0    ;read out CAPTURE0 register and save it
            ud      capt1_save = ud:CAPTURE1    ;read out CAPTURE1 register and save it
            ud      capt2_save = ud:CAPTURE2    ;read out CAPTURE2 register and save it
            ud      capt3_save = ud:CAPTURE3    ;read out CAPTURE3 register and save it
                    lowerSignals(ub:#underflow)  ;lower underflow signal
                    raiseFlags(ub:#underflow)    ;raise underflow flag   
            uw      TIMER = uw:#60000           ;put a new value in the timer
            sh      PC = uh:*SP++[8]            ;return from interrupt
               
INEXT_:     sh      *SP--[8] = uh:PC_COPY       ;save return address from floating-point inexact exception, which is maskable
            ud      capt0_save = ud:CAPTURE0    ;read out CAPTURE0 register and save it
            ud      capt1_save = ud:CAPTURE1    ;read out CAPTURE1 register and save it
            ud      capt2_save = ud:CAPTURE2    ;read out CAPTURE2 register and save it
            ud      capt3_save = ud:CAPTURE3    ;read out CAPTURE3 register and save it
                    lowerSignals(ub:#inexact)   ;lower inexact signal
                    raiseFlags(ub:#inexact)     ;raise inexact flag   
            uw      TIMER = uw:#60000           ;put a new value in the timer
            sh      PC = uh:*SP++[8]            ;return from interrupt
               
IRQ_:       sh      *SP--[8] = uh:PC_COPY       ;save return address (general-purpose, maskable interrupt)
            uw      TIMER = uw:#60000           ;put a new value in the timer
            sh      PC = uh:*SP++[8]            ;return from interrupt  
progend:        
            end
          
    
