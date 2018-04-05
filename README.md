![](https://github.com/jerry-D/SYMPL-FP324-AXI4-GP-GPU/blob/master/web_logo.jpg)

## Universal IEEE 754-2008 Floating-Point Emulator for Xilinx and Altera FPGAs

(April 5, 2018) Supporting half, single and double-precision binary formats specified in the IEEE 754-2008 specification, the instant mixed Verilog and VHDL design emulates in “hardware” ALL the required floating-point operations, including comparison predicates, binary-to-decimal character sequence conversion (and back again), hardware remainder, alternate immediate exception handling, all five directed rounding mode attributes, and many others not required, like all three power functions, log, exp, sind, cosd, tand and cotd.

Stated simply, the Universal IEEE 754-2008 Floating-Point Emulator is a ready and easy to use, “canned” hardware implementation of the IEEE 754-2008 specification.  Meaning, there is just one instruction per operation, which includes (among many others):  fusedMultiplyAdd, remainder, convertFromDecimalCharacter, convertToDecimalCharacter, nextUp, nextDown, pow, powr, pown.

### All Computational Operators are Fully Pipelined

That's right.  Because each computational operator can have up to sixteen dedicated result buffers that results and their encoded exception bits automatically spill into, these operators can accept dual operands as inputs every clock cycle, which helps to hide latency when performing big data computations.

### Perfect for Customizing Your FPGA-Based CPU

This Universal IEEE 754-2008 Floating-Point Emulator can be easily connected to virtually any FPGA-based CPU by way of its generic memory interface, either directly or via a slave AXI-4 type connection.  If you are designing your own FPGA-based CPU and want to give it instant IEEE 754-2008 compliance, this is for you.

It supports the three main binary formats to half-precision.  Meaning, that although most of the hardware operators in the current version are yield half-precision intermediate results, such operators can accept single and double-precision numbers (or any mix of half, single and double-precision)--directly--without the need to explicitly convert them to half-precision beforehand, so long as such numbers fall within the same range as half-precision binary formatted numbers.  If they fall outside of such range, use scaleB/logB to scale your data set first, then submit.

As required by IEEE 754-2008, half-precision subnormal numbers are also now fully supported, meaning that all floating-point computational operators can accept and produce subnormal numbers as input or as a result of computation, allowing generation and propagation of gradual underflow in a computational stream as required for specification compliance.

All specified default and directed rounding modes (nearest, positive/negative infinity, zero and away) are now fully supported by way of a rounding mode attribute field in the status register.  Alternatively, when no rounding mode attribute is set, the rounding mode can be specified on-the-fly within the instruction.  However, the directed rounding mode attribute enable bit, if set, in the status register overrides any specified in the instruction.

### Mixed Verilog and VHDL Design

At this repository you will find all the synthesizable Verilog and VHDL source code needed to simulate and synthesize the instant  Universal IEEE 754-2008 Floating-Point Emulator.  The core processor is based on a custom, 64-bit, interleaving, multi-threading, GP-GPU Compute Unit design.  

This design was developed using the “free” version of Xilinx Vivado, version 2015.1, targeted to a Kintex7, -3 speed grade. To obtain a copy of the latest version of Vivado, visit Xilinx' website at www.Xilinx.com 

After place and route, it was determined that this 64-bit design will clock at roughly 100MHz in a Kintex7 without constraints of any kind except for specifying what pin to use as the clock and at what clock rate. About 90% of the delays are attributed to routing and not logic propagation delays. 

The instant design incorporates several FloPoCo 6-bit exponent, 10-bit fraction operators modified and adapted for fully compliant operations.   If you would like to change Emulator core operators to increase range/precision, visit FloPoCo's website at:

http://flopoco.gforge.inria.fr

There you will find everything you need to generate virtually any kind of floating-point operator and many others.

For more information regarding the FloPoCo library and generator, read the article at the link provided below:
Florent de Dinechin and Bogdan Pasca.  Designing custom arithmetic data paths with FloPoCo.  IEEE Design & Test of Computers, 28(4):18—27, July 2011.

http://perso.citi-lab.fr/fdedinec/recherche/publis/2011-DaT-FloPoCo.pdf

The simplest way to increase range and/or precision, is to use the existing operator wrappers as templates.  Care should be taken to properly adjust the number of “delay” registers to correspond to the latency of the substituted operator.  For instance, half-precision will generally require fewer stages than smaller range/precision will generally require more.

### Universal IEEE 754-2008 Emulator Instruction Set
Also at this repository you will find the SYMPL 64-bit ISA instruction table that can be used with “CROSS-32” Universal Cross-Assembler to compile the example 3D-transform thread used in the example simulation.   The instruction table can be found in the ASM folder at this repository.  A detailed wiki for the Universal IEEE 754-2008 Emulator basic architecture and instruction set is being developed, which will take some time.  In the meantime, for a basic description instruction formatting, refer to the instruction table.

To obtain a copy of CROSS-32, visit Data-Sync Engineering's website: 

http://www.cdadapter.com/cross32.htm
sales@datasynceng.com

A copy of the Cross-32 manual can be viewed online here: 

http://www.cdadapter.com/download/cross32.pdf

### Real-Time Debug On-Chip

Additionally, this design comes with on-chip debug capability. Each thread has independent h/w breakpoints with programmable pass-counters, single-steps, 4-level deep PC discontinuity trace buffer, and real-time data exchange/monitoring. Thread registers can be read and modified in real-time without affecting ongoing processes. Threads can be independently or simultaneously breakpointed, single-stepped or released. Presently all this is done through a generic port which can be matted with a JTAG TAP, CPU I/O port, AXI4, etc. The test bench provided at this repository has examples of breakpoints, single-steps, etc.

For more information on how to use the debug feature, study the test bench in the simulation folder at this repository.

### Required Homogeneous General-Computational Floating-Point Operators Implemented in Hardware

Below is a SYMPL Intermediate Language (IL) listing of all required homogeneous general-computational floating-point operators and actual usage.    Each operation is exactly one instruction.  It should be noted that, in most cases, the destination format can be specified as half, single or double precision, in that results are always stored in their respective intermediate result buffers as half-precision regardless.  However, take note that you can read them out in any format you want, in that they will automatically be converted to the binary format specified in the respective source operand format field, which can be mixed if so desired.

Also note that each of the statements shown below is a single instruction implemented in hardware with the number clocks to execute shown to the right.

Below is a SYMPL Intermediate Language (IL) listing of all required homogeneous general-computational floating-point operators and actual usage.  It should be noted that, in most cases, the destination format can be specified as half, single or double precision, in that results are always stored in their respective intermediate result buffers as half-precision regardless.  However, take note that you can read them out in any format you want, in that they will automatically be converted to the binary format specified in the respective source operand format field, which can be mixed if you so desire.
Also note that each of the statements shown below is a single instruction implemented in hardware with the number clocks to execute shown to the right.

 rh.e    rtoi.15     = roundToIntegralTiesToEven:(fh:fdiv.15)          ;3 clocks
 rh.a    rtoi.14     = roundToIntegralTiesToAway:(fh:fdiv.15)          ;3 clocks   
 rh.z    rtoi.13     = roundToIntegralTowardZero:(fh:fdiv.15)          ;3 clocks   
 rh.p    rtoi.12     = roundToIntegralTowardPositive:(fh:fdiv.15)      ;3 clocks
 rh.n    rtoi.11     = roundToIntegralTowardNegative:(fh:fdiv.15)      ;3 clocks
 fh      rtoi.10     = roundToIntegralExact:(fh:fdiv.15)               ;3 clocks
 fh.p    rtoi.8      = roundToIntegralExact:(fh:fdiv.15)               ;3 clocks
 fh.n    rtoi.7      = roundToIntegralExact:(fh:fdiv.15)               ;3 clocks
 fh.z    rtoi.6      = roundToIntegralExact:(fh:fdiv.15)               ;3 clocks
 fh      nextUp.7    = nextUp:(fh:itof.15)                             ;3 clocks
 fh      nextDown.7  = nextDown:(fs:work_2)                            ;3 clocks
 fh      rem.15      = remainder:(fs:work_1, fs:work_2)                ;14 clocks
 fh      minNum.3    = minNum:(fs:work_2, fs:work_1)                   ;3 clocks        
 fh      maxNum.3    = maxNum:(fs:work_2, fs:work_1)                   ;3 clocks        
 fh      minNumMag.3 = minNumMag:(fs:work_2, fs:work_1)                ;3 clocks        
 fh      maxNumMag.3 = maxNumMag:(fs:work_2, fs:work_1)                ;3 clocks        
 fh      scaleB.15   = scaleB:(fh:itof.15, fs:work_2)                  ;4 clocks              
 fh      logb.15     = logB:(fh:itof.15)                               ;4 clocks        
 fh      fadd.15     = addition:(fs:work_1, fs:work_2)                 ;5 clocks
 fh      fsub.15     = subtraction:(fs:work_1, fs:work_2)              ;5 clocks
 fh      fmul.15     = multiplication:(fs:work_1, fs:work_2)           ;4 clocks
 fh      fdiv.15     = division:(fs:work_1, fs:work_2)                 ;8 clocks
 fh      sqrt.15     = squareRoot:(fs:work_1)                          ;6 clocks
 fh      fma.15      = fusedMultiplyAdd:(fs:work_1, fs:work_2, C)      ;6 clocks
 fh      itof.15     = convertFromInt:(uh:#0x0022)                     ;2 clocks
 fh.p    itof.13     = convertFromInt:(uh:#0x0022)                     ;2 clocks
 fh.n    itof.12     = convertFromInt:(uh:#0x0022)                     ;2 clocks
 fh.z    itof.11     = convertFromInt:(uh:#0x0022)                     ;2 clocks
 uw.e    ftoi.15     = convertToIntegerTiesToEven:(fh:itof.15)         ;3 clocks
 uw.z    ftoi.14     = convertToIntegerTowardZero:(fh:itof.15)         ;3 clocks    
 uw.p    ftoi.13     = convertToIntegerTowardPositive:(fh:itof.15)     ;3 clocks    
 uw.n    ftoi.12     = convertToIntegerTowardNegative:(fh:itof.15)     ;3 clocks    
 uw.a    ftoi.11     = convertToIntegerTiesToAway:(fh:itof.15)         ;3 clocks  
 uw.ex   ftoi.10     = convertToIntegerExactTiesToEven:(fh:itof.15)    ;3 clocks   
 uw.zx   ftoi.9      = convertToIntegerExactTowardZero:(fh:itof.15)    ;3 clocks    
 uw.px   ftoi.8      = convertToIntegerExactTowardPositive:(fh:itof.15);3 clocks 
 uw.nx   ftoi.7      = convertToIntegerExactTowardNegative:(fh:itof.15);3 clocks 
 uw.ax   ftoi.6      = convertToIntegerExactTiesToAway:(fh:itof.15)    ;3 clocks 
 fs      conv.15     = convertFormat:(fs:work_1)                       ;3 clocks
 fh      cnvFDCS.15  = convertFromDecimalCharacter:(ud:cnvTDCS.15, sd:cnvTDCS.15) ;7 clocks
 ud      cnvTDCS.15  = convertToDecimalCharacter:(fh:pow.15, ub:#0)               ;8 clocks
 fh      cnvFHCS.15  = convertFromHexCharacter:(ud:cnvTHCS.15, sd:cnvTHCS.15)     ;7 clocks                          
 ud      cnvTHCS.15  = convertToHexCharacter:(fh:rem.15, ub:#0)        ;5 clocks       
 fh      copy.3      = copy:(fh:sqrt.15)                               ;3 clocks
 fh      negate.3    = negate:(fs:work_2)                              ;3 clocks
 fh      abs.3       = abs:(fh:negate.3)                               ;3 clocks
 fh      copySign.3  = copySign:(fs:work_1, fh:negate.3)               ;3 clocks

### Computational Signaling Operations 
These comparison operators affect a single sticky bit in the status register called "CompareTrue" and should be followed by the IF (CompareTrue) statements provided below this list to change program flow:

         compareSignalingEqual(fs:work_1, fs:work_2)                   ;1 clock
         compareQuietEqual(fs:work_1, fs:work_2)                       ;1 clock
         compareSignalingNotEqual(fs:work_1, fs:work_2)                ;1 clock
         compareQuietNotEqual(fs:work_1, fs:work_2)                    ;1 clock
         compareSignalingGreater(fs:work_1, fs:work_2)                 ;1 clock
         compareQuietGreater(fs:work_1, fs:work_2)                     ;1 clock
         compareSignalingGreaterEqual(fs:work_1, fs:work_2)            ;1 clock
         compareQuietGreaterEqual(fs:work_1, fs:work_2)                ;1 clock
         compareSignalingLess(fs:work_1, fs:work_2)                    ;1 clock
         compareQuietLess(fs:work_1, fs:work_2)                        ;1 clock
         compareSignalingLessEqual(fs:work_1, fs:work_2)               ;1 clock
         compareQuietLessEqual(fs:work_1, fs:work_2)                   ;1 clock
         compareSignalingNotGreater(fs:work_1, fs:work_2)              ;1 clock
         compareQuietNotGreater(fs:work_1, fs:work_2)                  ;1 clock
         compareSignalingLessUnordered(fs:work_1, fs:work_2)           ;1 clock
         compareQuietLessUnordered(fs:work_1, fs:work_2)               ;1 clock
         compareSignalingNotLess(fs:work_1, fs:work_2)                 ;1 clock
         compareQuietNotLess(fs:work_1, fs:work_2)                     ;1 clock
         compareSignalingGreaterUnordered(fs:work_1, fs:work_2)        ;1 clock
         compareQuietGreaterUnordered(fs:work_1, fs:work_2)            ;1 clock   
         compareQuietUnordered(fs:work_1, fs:work_2)                   ;1 clock                           
         compareQuietOrdered(fs:work_1, fs:work_2)                     ;1 clock                               
                                                                                                      
         IF (compareTrue) GOTO: <label>                                ;1 clock                         
         IF NOT(compareTrue) GOTO: <label>                             ;1 clock                       
         IF (compareTrue) GOSUB: <label>                               ;1 clock                           
         IF NOT(compareTrue) GOSUB: <label>                            ;1 clock                           
                                                                                                      
### Non-Computational Operations                                                                        
                                                                                                      
         is754version1985()                                            ;1 clock
         IF (754version1985) GOTO: <label>                             ;1 clock
         IF NOT(754version1985) GOTO: <label>                          ;1 clock
         
         is754version2008() GOTO: <label>                              ;1 clock
         IF (754version2008) GOTO: <label>                             ;1 clock
         IF NOT(754version2008) GOTO: <label>                          ;1 clock                                             
         
 ub      clas        = class:(fs:work_2)                               ;1 clock
         ;after execution, location "clas" will contain the enumeration corresponding to the class of the operand as follows:
         
         0x01 = signalingNaN
         0x02 = quietNaN
         0x03 = negativeInfinity
         0x04 = negativeNormal
         0x05 = negativeSubnormal
         0x06 = negativeZero
         0x07 = positiveZero
         0x08 = positiveSubnormal
         0x09 = positiveNormal
         0x0A = positiveInfinity
         
         ;each one of the above classes have a dedicated sticky bit in the status register that can be tested with one of the corresponding branch instructions provided below:
         
         IF (signalingNaN) GOTO: <label>                               ;1 clock                                         
         IF (quietNaN) GOTO: <label>                                   ;1 clock                                         
         IF (negativeInfinity) GOTO: <label>                           ;1 clock                                         
         IF (negativeNormal) GOTO: <label>                             ;1 clock                                         
         IF (negativeSubnormal) GOTO: <label>                          ;1 clock                                         
         IF (negativeZero) GOTO: <label>                               ;1 clock                                         
         IF (positiveZero) GOTO: <label>                               ;1 clock                                         
         IF (positiveSubnormal) GOTO: <label>                          ;1 clock                                         
         IF (positiveNormal) GOTO: <label>                             ;1 clock                                         
         IF (positiveInfinity) GOTO: <label>                           ;1 clock                                         
 
         IF NOT(signalingNaN) GOTO: <label>                            ;1 clock                                         
         IF NOT(quietNaN) GOTO: <label>                                ;1 clock                                         
         IF NOT(negativeInfinity) GOTO: <label>                        ;1 clock                                         
         IF NOT(negativeNormal) GOTO: <label>                          ;1 clock                                         
         IF NOT(negativeSubnormal) GOTO: <label>                       ;1 clock                                         
         IF NOT(negativeZero) GOTO: <label>                            ;1 clock                                         
         IF NOT(positiveZero) GOTO: <label>                            ;1 clock                                         
         IF NOT(positiveSubnormal) GOTO: <label>                       ;1 clock                                         
         IF NOT(positiveNormal) GOTO: <label>                          ;1 clock                                         
         IF NOT(positiveInfinity) GOTO: <label>                        ;1 clock                                         
         
         IF (signalingNaN) GOSUB: <label>                              ;1 clock                                         
         IF (quietNaN) GOSUB: <label>                                  ;1 clock                                         
         IF (negativeInfinity) GOSUB: <label>                          ;1 clock                                         
         IF (negativeNormal) GOSUB: <label>                            ;1 clock                                         
         IF (negativeSubnormal) GOSUB: <label>                         ;1 clock                                         
         IF (negativeZero) GOSUB: <label>                              ;1 clock                                         
         IF (positiveZero) GOSUB: <label>                              ;1 clock                                         
         IF (positiveSubnormal) GOSUB: <label>                         ;1 clock                                         
         IF (positiveNormal) GOSUB: <label>                            ;1 clock                                         
         IF (positiveInfinity) GOSUB: <label>                          ;1 clock                                         

         IF NOT(signalingNaN) GOSUB: <label>                           ;1 clock                                         
         IF NOT(quietNaN) GOSUB: <label>                               ;1 clock                                         
         IF NOT(negativeInfinity) GOSUB: <label>                       ;1 clock                                         
         IF NOT(negativeNormal) GOSUB: <label>                         ;1 clock                                         
         IF NOT(negativeSubnormal) GOSUB: <label>                      ;1 clock                                         
         IF NOT(negativeZero) GOSUB: <label>                           ;1 clock                                         
         IF NOT(positiveZero) GOSUB: <label>                           ;1 clock                                         
         IF NOT(positiveSubnormal) GOSUB: <label>                      ;1 clock                                         
         IF NOT(positiveNormal) GOSUB: <label>                         ;1 clock                                         
         IF NOT(positiveInfinity) GOSUB: <label>                       ;1 clock                                         

The following are non-exceptional predicates.  Each have a dedicated corresponding sticky bit in status register that can be tested using one of the corresponding conditional branch instructions shown immediately beneath it:

         isSignMinus(fh:negate.3)                                      ;1 clock
         isNormal(fh:sqrt.15)                                          ;1 clock
         isFinite(fh:sqrt.15)                                          ;1 clock
         isZero(fh:sqrt.15)                                            ;1 clock
         isSubnormal(fh:sqrt.15)                                       ;1 clock
         isInfinite(fh:sqrt.15)                                        ;1 clock
         isNaN(fh:sqrt.15)                                             ;1 clock
         isSignaling(fh:sqrt.15)                                       ;1 clock
         isCanonical(fh:sqrt.15)                                       ;1 clock
         
         IF (SignMinus) GOTO: <label>                                  ;1 clock                                         
         IF (Normal) GOTO: <label>                                     ;1 clock                                         
         IF (Finite) GOTO: <label>                                     ;1 clock                                         
         IF (Zero) GOTO: <label>                                       ;1 clock                                         
         IF (Subnormal) GOTO: <label>                                  ;1 clock                                         
         IF (Infinite) GOTO: <label>                                   ;1 clock                                         
         IF (NaN) GOTO: <label>                                        ;1 clock                                         
         IF (Signaling) GOTO: <label>                                  ;1 clock                                         
         IF (Canonical) GOTO: <label>                                  ;1 clock 
         
         IF NOT(SignMinus) GOTO: <label>                               ;1 clock                                         
         IF NOT(Normal) GOTO: <label>                                  ;1 clock                                         
         IF NOT(Finite) GOTO: <label>                                  ;1 clock                                         
         IF NOT(Zero) GOTO: <label>                                    ;1 clock                                         
         IF NOT(Subnormal) GOTO: <label>                               ;1 clock                                         
         IF NOT(Infinite) GOTO: <label>                                ;1 clock                                         
         IF NOT(NaN)  GOTO: <label>                                    ;1 clock                                         
         IF NOT(Signaling) GOTO: <label>                               ;1 clock                                         
         IF NOT(Canonical) GOTO: <label>                               ;1 clock                                         

         IF (SignMinus) GOSUB: <label>                                 ;1 clock                                         
         IF (Normal) GOSUB: <label>                                    ;1 clock                                         
         IF (Finite) GOSUB: <label>                                    ;1 clock                                         
         IF (Zero) GOSUB: <label>                                      ;1 clock                                         
         IF (Subnormal) GOSUB: <label>                                 ;1 clock                                         
         IF (Infinite) GOSUB: <label>                                  ;1 clock                                         
         IF (NaN) GOSUB: <label>                                       ;1 clock                                         
         IF (Signaling) GOSUB: <label>                                 ;1 clock                                         
         IF (Canonical) GOSUB: <label>                                 ;1 clock                                         

         IF NOT(SignMinus) GOSUB: <label>                              ;1 clock                                         
         IF NOT(Normal) GOSUB: <label>                                 ;1 clock                                         
         IF NOT(Finite) GOSUB: <label>                                 ;1 clock                                         
         IF NOT(Zero) GOSUB: <label>                                   ;1 clock                                         
         IF NOT(Subnormal) GOSUB: <label>                              ;1 clock                                         
         IF NOT(Infinite) GOSUB: <label>                               ;1 clock                                         
         IF NOT(NaN)  GOSUB: <label>                                   ;1 clock                                         
         IF NOT(Signaling) GOSUB: <label>                              ;1 clock                                         
         IF NOT(Canonical) GOSUB: <label>                              ;1 clock                                         
         
 uw.rdx  work_3      = radix:(fs:work_2)                               ;1 clock
         ;the value 0x2 will be stored in the specified destination address
 
         totalOrder(fs:work_1, fs:work_2)                              ;1 clock
         IF (totalOrder) GOTO: <label>                                 ;1 clock  
         IF NOT(totalOrder) GOTO: <label>                              ;1 clock  
         IF (totalOrder) GOSUB: <label>                                ;1 clock                                         
         IF NOT(totalOrder) GOSUB: <label>                             ;1 clock                                         
                                                
         totalOrderMag(fs:work_1, fs:work_2)                           ;1 clock                                  
         IF (totalOrderMag) GOTO: <label>                              ;1 clock                                         
         IF NOT(totalOrderMag) GOTO: <label>                           ;1 clock                                         
         IF (totalOrderMag) GOSUB: <label>                             ;1 clock                                         
         IF NOT(totalOrderMag) GOSUB: <label>                          ;1 clock                                         
                                                          
### Operations on Flag Subsets

         lowerFlags(ub:#{invalid | overflow | inexact})                ;1 clock
         raiseFlags(ub:#{invalid | overflow | inexact})                ;1 clock
         testFlags(ub:#invalid)                                        ;1 clock
         Note: "testFlags" and "testSavedFlags" operators will set or clear the "aFlagRaised" sticky bit in the status register if the of the specified flags are raised.

         testSavedFlags(ub: savedFlags, ub:#{invalid | overflow | underflow}) ;1 clock
         restoreFlags(ub: savedFlags, ub:#{invalid | overflow | underflow})   ;1 clock
         saveAllFlags()                                                ;1 clock
         
         Note:  the following branch instructions can be used to test the "aFlagRaised" sticky bit in the status register 
         IF (aFlagRaised) GOTO: <label>                                ;1 clock                                         
         IF NOT(aFlagRaised) GOTO: <label>                             ;1 clock                                         
         IF (aFlagRaised) GOSUB: <label>                               ;1 clock                                         
         IF NOT(aFlagRaised) GOSUB: <label>                            ;1 clock                                         

### Resuming Alternate Exception Handling Attributes 
        
         default(ub:#{overflow | inexact})                             ;1 clock
         raiseNoFlag(ub:#overflow)                                     ;1 clock                               
         
         raiseSignals(ub:#{invalid | overflow | inexact})              ;1 clock
         lowerSignals(ub:#{invalid | overflow | inexact})              ;1 clock
         raiseSignals(ub:#{divByZero | underflow})                     ;1 clock
         lowerSignals(ub:#{divByZero | underflow})                     ;1 clock
         
         enableAltImmediateHandlers(ub:#{invalid | overflow | inexact})   ;1 clock
         disableAltImmediateHandlers(ub:#{invalid | overflow | inexact})  ;1 clock

### Set and Clear Alternate Exception Substitution Bits in Status Register
         setSubsInexact                                                ;1 clock
         clearSubsInexact                                              ;1 clock
         setSubssubsUnderflow                                          ;1 clock    
         clearSubssubsUnderflow                                        ;1 clock    
         setSubsOverflow                                               ;1 clock    
         clearSubsOverflow                                             ;1 clock    
         setSubsDivByZero                                              ;1 clock   
         clearSubsDivByZero                                            ;1 clock    
         setSubsInvalid                                                ;1 clock    
         clearSubsInvalid                                              ;1 clock    


### Implemented (but not required) Correctly Rounded Functions
 fh      exp.15 = exp:(fh:log.15)                                      ;5 clocks
 fh      log.15 = log:(fs:work_1)                                      ;9 clocks
 fh      pow.14 = pown:(fs:work_1, xfs:work_2)                         ;13 clocks
 fh      pow.15 = pow:(fs:work_1, fs:work_2)                           ;13 clocks
 fh      pow.13 = powr:(xfs:work_1, fs:work_2)                         ;13 clocks

### Implemented Correctly Rounded Trig Functions (these accept integer input in degrees) 

 fh      sind.3 = sind:(uh:#30)                                        ;3 clocks
 fh      cosd.3 = cosd:(uh:#122)                                       ;3 clocks
 fh      tand.3 = tand:(uh:#223)                                       ;3 clocks
 fh      cotd.3 = cotd:(uh:#98)                                        ;3 clocks

### Operations on Dynamic Modes
 
         getBinaryRoundingDirection()                                  ;1 clock
         Note:  the above instruction copies the 4-bit rounding direction attribute in the status register to byte location 0x0FE18 in a threads private RAM
         
         setBinaryRoundingDirection(NEAREST)                           ;1 clock
         setBinaryRoundingDirection(POSITIVE)                          ;1 clock
         setBinaryRoundingDirection(NEGATIVE)                          ;1 clock
         setBinaryRoundingDirection(AWAY)                              ;1 clock
         setBinaryRoundingDirection(ZERO)                              ;1 clock
         saveModes()                                                   ;1 clock
         restoreModes(ub:savedModes)                                   ;1 clock
         defaultModes()                                                ;1 clock
                                                              
 
### Native Integer, Logical and Bit Test and Branch Operators (with some equivalent straignt assembly shown intermixed)         

 uh      and.3 = and:(uh:work_3, uh:#0x5555)            ;2 clocks
 uh      or.3 = or:(uh:work_3, uh:#0x5555)              ;2 clocks                    
 uh      xor.3 = xor:(uh:work_3, uh:#0x5555)            ;2 clocks
 uh      add.3 = add:(uh:work_3, uh:#0x5555)            ;2 clocks
         setC
 sh      add.4 = addc:(uh:work_3, sh:#0x5555)           ;2 clocks      
 uh      sub.3 = sub:(uh:work_3, uh:#0x0055)            ;2 clocks
         setC
 sh      sub.4 = subb:(uh:work_3, sh:#0x0055)           ;2 clocks   
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
 
         IF (Z==1) GOTO: <label>            ;1 clock
         IF (Z==0) GOTO: <label>            ;1 clock
         IF (A==B) GOTO: <label>            ;1 clock
         IF (A!=B) GOTO: <label>            ;1 clock
         IF (C==1) GOTO: <label>            ;1 clock
         IF (C==0) GOTO: <label>            ;1 clock
         IF (N==1) GOTO: <label>            ;1 clock
         IF (N==0) GOTO: <label>            ;1 clock
         IF (V==1) GOTO: <label>            ;1 clock
         IF (V==0) GOTO: <label>            ;1 clock
         IF (A<B)  GOTO: <label>            ;1 clock
         IF (A>=B) GOTO: <label>            ;1 clock
         IF (A<=B) GOTO: <label>            ;1 clock
         IF (A>B)  GOTO: <label>            ;1 clock
                                           
         IF (Z==1) GOSUB: <label>           ;1 clock
         IF (Z==0) GOSUB: <label>           ;1 clock
         IF (A==B) GOSUB: <label>           ;1 clock
         IF (A!=B) GOSUB: <label>           ;1 clock
         IF (C==1) GOSUB: <label>           ;1 clock
         IF (C==0) GOSUB: <label>           ;1 clock
         IF (N==1) GOSUB: <label>           ;1 clock
         IF (N==0) GOSUB: <label>           ;1 clock
         IF (V==1) GOSUB: <label>           ;1 clock
         IF (V==0) GOSUB: <label>           ;1 clock
         IF (A<B)  GOSUB: <label>           ;1 clock
         IF (A>=B) GOSUB: <label>           ;1 clock
         IF (A<=B) GOSUB: <label>           ;1 clock
         IF (A>B)  GOSUB: <label>           ;1 clock
         
         IF (uw:work_3:[bit8]==0) GOTO: <label>    ;1 clock
         IF (uw:work_3:[bit7]==1) GOTO: <label>    ;1 clock
         IF (uw:work_3:[bit6]==0) GOSUB: <label>   ;1 clock
         IF (uw:work_3:[bit5]==1) GOSUB: <label>   ;1 clock
         
         btbc uh:work_3, 8, <label>
         btbs uh:work_3, 7, <label>
         btbc uh:work_3, 6, <label>
         btbs uh:work_3, 5, <label>
         
         . uh:pcc, uw:work_3, 8, <label>
         . uh:pcs, uw:work_3, 7, <label>
         . uh:pcc, uw:work_3, 6, <label>
         . uh:pcs, uw:work_3, 5, <label>
               
         FOR (LPCNT0 = uw:#3) (       ;1 clock
             nop                      ;1 clock
             nop                      ;1 clock
         NEXT LPCNT0 GOTO: loop_0 )   ;1 clock
 
         . uw:LPCNT0, uw:#3
         . uw:PCS, ud:STATUS, NEVER, loop_1 
         . uw:PCS, ud:STATUS, NEVER, loop_1 
         . uw:PCS, ud:LPCNT0, 16, loop_1
 
         FOR (LPCNT1 = uw:#3) (       ;1 clock    
             nop                      ;1 clock
             nop                      ;1 clock
         NEXT LPCNT1 GOTO: loop_2 )   ;1 clock
              
         GOTO <label>                  ;1 clock
         GOSUB <label>                 ;1 clock
         RETURN                        ;1 clock

### REPEAT Examples 
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
                                                               
                   
### Example Alternate Immediate Divide By Zero Exception Handler (Trap Service Routine) 
      
 sh      *SP--[8] = uh:PC_COPY       ;save return address from floating-point divide by 0 exception, which is maskable
 ud      capt0_save = ud:CAPTURE0    ;read out CAPTURE0 register and save it
 ud      capt1_save = ud:CAPTURE1    ;read out CAPTURE1 register and save it
 ud      capt2_save = ud:CAPTURE2    ;read out CAPTURE2 register and save it
 ud      capt3_save = ud:CAPTURE3    ;read out CAPTURE3 register and save it
         lowerSignals(ub:#divByZero) ;lower divByZero signal
         raiseFlags(ub:#divByZero)   ;raise divByZero flag   
 uw      TIMER = uw:#60000           ;put a new value in the timer
 sh      PC = uh:*SP++[8]            ;return from from trap
    
### Simulating the Universal IEEE 754-2008 Floating-Point Emulator Design

The example test case takes a 3D representation of an olive in single-precision binary .stl file format and performs a 3D transformation on all three axis, which includes:  scale(x, y, z), rotate(x, y, x) and translate(x, y, z).   The “olive” was created using the OpenSCAD, free open source 3D modeling environment and was exported in ASCII .stl file format.  To convert to binary, the “olive.stl” file was imported into “Blender”, free open source 3D modeling environment, and immediately exported back to .stl format, which, for Blender, is binary format.  Below is the “before” and “after” 3D rendering of the olive as viewed with OpenSCAD.  Note that the number of faces were kept to a minimum to facilitate faster simulation.

The “Olive” Before and After

![](https://github.com/jerry-D/SYMPL-FP324-AXI4-GP-GPU/blob/master/olive_trans_both.gif.gif)

To run this simulation using Vivado, download or clone the Universal IEEE 754-2008 Floating-Point Emulator design in this repository.   All the files you need to run the 3D transformation of the “olive” in the simulation and ASM files.  For the simulation, you need to make sure that the following four files are in the Vivado working directory.  The file, “threeD_xform.v”, is presently automatically loaded into the Emulator's program memory with the $readmemh("threeD_xform.v",triportRAMA) statement in the “ram4kx64.v” module.  Alternatively, you can comment-out the $readmemh statement and manually load/push the thread in from the test bench.

The other file that you need to run this simulation is the “olive.stl” file.  It's a very coarse representation of the olive to keep number of triangles down to keep simulation time down to reasonable minimum.  There are a couple other 3D objects in .stl file format located in the STL folder that you can run using the same setup.  Resulting 3D transformations will be written in .stl binary format to the Vivado .sim/behav directory under the file name, “result_trans.stl”.  You can view the transformed result using any online .stl file viewer, including the one at GitHub.

### Technical Support
If you need assistance setting up your simulation, answers to pertinent technical questions, assistance customizing or modifying this design for your application, please don't hesitate to direct them at me here:  sympl.gpu@gmail.com

