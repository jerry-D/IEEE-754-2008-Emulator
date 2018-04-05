           CPU  "SYMPL64_IL.TBL"
           HOF  "MOT32"
           WDLN 8
; SYMPL GP-GPU Shader Demo 3D Transform Micro-Kernel (straight assembly language version)
; version 2.00   March 16, 2018
; Author:  Jerry D. Harthcock
; Copyright (C) 2018.  All rights reserved.
           
;private dword storage
bitbucket:  EQU     0x0000                  ;this dword location is reserved.  Don't use it for anything because a lot of garbage can wind up here
work_1:     EQU     0x0008                    
work_2:     EQU     0x0010
work_3:     EQU     0x0018
capt0_save: EQU     0x0020                  ;alternate immediate exception capture register 0 save location
capt1_save: EQU     0x0028                  ;alternate immediate exception capture register 1 save location
capt2_save: EQU     0x0030                  ;alternate immediate exception capture register 2 save location
capt3_save: EQU     0x0038                  ;alternate immediate exception capture register 3 save location

;for private storage of parameters for 3D transform                                                                                       
vect_start: EQU     0x0040                  ;start location of this thread's first triangle vector                                
triangles:  EQU     0x0048                  ;number of triangles in this thread's list to process                                 

;dword storage locations for parameters so it will be easy to change to/from double precision
scaleX:     EQU     0x0050                  ;scale factor X axis
scaleY:     EQU     0x0058                  ;scale factor Y axis
scaleZ:     EQU     0x0060                  ;scale factor Z axis
transX:     EQU     0x0068                  ;translate amount X axis
transY:     EQU     0x0070                  ;translate amount Y axis
transZ:     EQU     0x0078                  ;translate amount Z axis

sin_thetaX: EQU     sind.0                  ;sine of theta X for rotate X                                                         
cos_thetaX: EQU     cosd.0                  ;cosine of theta X for rotate X                                                      
sin_thetaY: EQU     sind.1                  ;sine of theta Y for rotate Y                                                        
cos_thetaY: EQU     cosd.1                  ;cosine of theta Y for rotate Y                                                      
sin_thetaZ: EQU     sind.2                  ;sine of theta X for rotate Z                                                        
cos_thetaZ: EQU     cosd.2                  ;cosine of theta X for rotate Z                                                      


            org     0x0FE              

Constants:  DFL     start                     ;program memory locations 0x000 - 0x0FF reserved for look-up table
        
prog_len:   DFL     progend - Constants
              
;           mov    type:dest, type:srcA, type:srcB 

            org     0x00000100                ;default interrupt vector locations
load_vects: 
            mov uh:NMI_VECT, uh:#NMI_         ;load of interrupt vectors for faster interrupt response
            mov uh:IRQ_VECT, uh:#IRQ_         ;these registers are presently not visible to app s/w
            mov uh:INV_VECT, uh:#INV_
            mov uh:DIVx0_VECT, uh:#DIVx0_
            mov uh:OVFL_VECT, uh:#OVFL_
            mov uh:UNFL_VECT, uh:#UNFL_
            mov uh:INEXT_VECT, uh:#INEXT_
done:                   
            mov uh:0xFF8C, uh:#0x0300         ;this sets the Done bit
            
any_triangles?:


            mov ub:0xFF8D, uh:triangles, uh:#0x0  ;cmp(uw:triangles, uh:#0x0); the 16-bit 0 is zero extended to 64 bits
            mov uw:PCS, uw:STATUS, bit0, any_triangles?  ;bit test and branch if Z is set
                    
            mov uw:TIMER, uw:#60000           ;load time-out timer with sufficient time to process before timeout
            mov uw:AR3, uw:vect_start 
start:  
            mov uh:0xFF8C, uh:#0x0200         ;this clears the Done bit
                    
            mov fs:sin_thetaX, uw:@rotx       ;calculate sine of theta X and save
            mov fs:cos_thetaX, uw:@rotx       ;calculate cosine of theta X and save                               
            mov fs:sin_thetaY, uw:@roty       ;calculate sine of theta Y and save                                   
            mov fs:cos_thetaY, uw:@roty       ;calculate cosine of theta Y and save                                   
            mov fs:sin_thetaZ, uw:@rotz       ;calculate sine of theta Z and save                                   
            mov fs:cos_thetaZ, uw:@rotz       ;calculate cosine of theta Z and save                                   
                                                                                                                            
            mov fs:scaleX, fs:@scal_x         ;save scale X factor
            mov fs:scaleY, fs:@scal_y         ;save scale Y factor
            mov fs:scaleZ, fs:@scal_z         ;save scale Z factor
            mov fs:transX, fs:@trans_x        ;save translate X axis amount
            mov fs:transY, fs:@trans_y        ;save translate Y axis amount
            mov fs:transZ, fs:@trans_z        ;save translate Z axis amount

                  ; AR3 is now pointing to first X of first triangle
            mov uw:AR2, uw:AR3                ;copy AR3 contents to AR2 so AR2 can be used as write pointer back to PDB for saving results
            
            mov uw:LPCNT0, uh:triangles       ;   for (LPCNT0 = uh:triangles) (      ;load loop counter 0 with number of triangles
            
                    ;the following routine performs scaling on all three axis first, 
                    ;rotate on all three axis second, then translate on all three axis last 
                              
loop:   ;scale on X, Y, Z axis
            ;vertex 1
            mov fs:FMUL.0, fs:*AR3++[4], fs:scaleX
            mov fs:FMUL.1, fs:*AR3++[4], fs:scaleY
            mov fs:FMUL.2, fs:*AR3++[4], fs:scaleZ
            ;vertex 2
            mov fs:FMUL.3, fs:*AR3++[4], fs:scaleX
            mov fs:FMUL.4, fs:*AR3++[4], fs:scaleY
            mov fs:FMUL.5, fs:*AR3++[4], fs:scaleZ
            ;vertex 3
            mov fs:FMUL.6, fs:*AR3++[4], fs:scaleX
            mov fs:FMUL.7, fs:*AR3++[4], fs:scaleY
            mov fs:FMUL.8, fs:*AR3++[4], fs:scaleZ
            
;                     X1 is now in FMUL_0         
;                     Y1 is now in FMUL_1         
;                     Z1 is now in FMUL_2         
;                     X2 is now in FMUL_3         
;                     Y2 is now in FMUL_4         
;                     Z2 is now in FMUL_5         
;                     X3 is now in FMUL_6         
;                     Y3 is now in FMUL_7         
;                     Z3 is now in FMUL_8         
            
  ;rotate around X axis
       ;vertex 1
            ; (cos(xrot) * Y1) - (sin(xrot) * Z1) 
            mov fs:FMUL.9, fs:FMUL.1, fs:cos_thetaX      ; FMUL.9 = (cos(xrot) * Y1)
            mov fs:FMUL.10, fs:FMUL.2, fs:sin_thetaX     ; FMUL.10 = (sin(xrot) * Z1)
            ; (sin(xrot) * Y1) + (cos(xrot) * Z1) 
            mov fs:FMUL.11, fs:FMUL.1, fs:sin_thetaX     ; FMUL.11 = (sin(xrot) * Y1)
            mov fs:FMUL.12, fs:FMUL.2, fs:cos_thetaX     ; FMUL.12 = (cos(xrot) * Z1)
            
            mov fs:FSUB.0, fs:FMUL.9, fs:FMUL.10         ; FSUB.0 = (cos(xrot) * Y1) - (sin(xrot) * Z1)
            mov fs:FADD.0, fs:FMUL.11, fs:FMUL.12        ; FADD.0 = (sin(xrot) * Y1) + (cos(xrot) * Z1)

       ;vertex 2
            ; (cos(xrot) * Y2) - (sin(xrot) * Z2) 
            mov fs:FMUL.1, fs:FMUL.4, fs:cos_thetaX      ; FMUL.1 = (cos(xrot) * Y2)
            mov fs:FMUL.2, fs:FMUL.5, fs:sin_thetaX      ; FMUL.2 = (sin(xrot) * Z2)
            ; (sin(xrot) * Y2) + (cos(xrot) * Z2) 
            mov fs:FMUL.13, fs:FMUL.4, fs:sin_thetaX     ; FMUL.13 = (sin(xrot) * Y2)
            mov fs:FMUL.14, fs:FMUL.5, fs:cos_thetaX     ; FMUL.14 = (cos(xrot) * Z2)
            
            mov fs:FSUB.1, fs:FMUL.1, fs:FMUL.2          ; FSUB.1 = (cos(xrot) * Y2) - (sin(xrot) * Z2)
            mov fs:FADD.1, fs:FMUL.13, fs:FMUL.14        ; FADD.1 = (sin(xrot) * Y2) + (cos(xrot) * Z2)

       ;vertex 3
            ; (cos(xrot) * Y3) - (sin(xrot) * Z3) 
            mov fs:FMUL.9, fs:FMUL.7, fs:cos_thetaX      ; FMUL.9 = (cos(xrot) * Y3)
            mov fs:FMUL.10, fs:FMUL.8, fs:sin_thetaX     ; FMUL.10 = (sin(xrot) * Z3)
            ; (sin(xrot) * Y3) + (cos(xrot) * Z3) 
            mov fs:FMUL.11, fs:FMUL.7, fs:sin_thetaX     ; FMUL.11 = (sin(xrot) * Y3)
            mov fs:FMUL.12, fs:FMUL.8, fs:cos_thetaX     ; FMUL.12 = (cos(xrot) * Z3)
            
            mov fs:FSUB.2, fs:FMUL.9, fs:FMUL.10         ; FSUB.2 = (cos(xrot) * Y3) - (sin(xrot) * Z3)
            mov fs:FADD.2, fs:FMUL.11, fs:FMUL.12        ; FADD.2 = (sin(xrot) * Y3) + (cos(xrot) * Z3)            
            
            ;         X1 is now in FMUL_0
            ;         Y1 is now in FSUB_0
            ;         Z1 is now in FADD_0 
            ;         X2 is now in FMUL_3
            ;         Y2 is now in FSUB_1
            ;         Z2 is now in FADD_1
            ;         X3 is now in FMUL_6
            ;         Y3 is now in FSUB_2
            ;         Z3 is now in FADD_2      

  ;rotate around Y axis
       ;vertex 1
            ; (cos(yrot) * X1) + (sin(yrot) * Z1) 
            mov fs:FMUL.1, fs:FMUL.0, fs:cos_thetaY      ; FMUL.1 = (cos(yrot) * X1)
            mov fs:FMUL.2, fs:FADD.0, fs:sin_thetaY      ; FMUL.2 = (sin(yrot) * Z1)
            ; (cos(yrot) * Z1) - (sin(yrot) * X1)
            mov fs:FMUL.4, fs:FADD.0, fs:cos_thetaY      ; FMUL.4 = (cos(xrot) * Z1)
            mov fs:FMUL.5, fs:FMUL.0, fs:sin_thetaY      ; FMUL.5 = (sin(xrot) * X1)
            
            mov fs:FADD.3, fs:FMUL.1, fs:FMUL.2          ; FADD.3 = (cos(yrot) * X1) + (sin(yrot) * Z1)
            mov fs:FSUB.3, fs:FMUL.4, fs:FMUL.5          ; FSUB.3 = (cos(yrot) * Z1) - (sin(yrot) * X1)
       ;vertex 2
            ; (cos(yrot) * X2) + (sin(yrot) * Z2) 
            mov fs:FMUL.7, fs:FMUL.3, fs:cos_thetaY      ; FMUL.7 = (cos(yrot) * X2)
            mov fs:FMUL.8, fs:FADD.1, fs:sin_thetaY      ; FMUL.8 = (sin(yrot) * Z2)
            ; (cos(yrot) * Z2) - (sin(yrot) * X2)
            mov fs:FMUL.9, fs:FADD.1, fs:cos_thetaY      ; FMUL.9 = (cos(xrot) * Z2)
            mov fs:FMUL.10, fs:FMUL.3, fs:sin_thetaY     ; FMUL.10 = (sin(xrot) * X2)
            
            mov fs:FADD.4, fs:FMUL.7, fs:FMUL.8          ; FADD.4 = (cos(yrot) * X2) + (sin(yrot) * Z2)
            mov fs:FSUB.4, fs:FMUL.9, fs:FMUL.10         ; FSUB.4 = (cos(yrot) * Z2) - (sin(yrot) * X2)
            
       ;vertex 3
            ; (cos(yrot) * X3) + (sin(yrot) * Z3) 
            mov fs:FMUL.11, fs:FMUL.6, fs:cos_thetaY     ; FMUL.11 = (cos(yrot) * X3)
            mov fs:FMUL.12, fs:FADD.2, fs:sin_thetaY     ; FMUL.12 = (sin(yrot) * Z3)
            
            ; (cos(yrot) * Z3) - (sin(yrot) * X3)
            mov fs:FMUL.13, fs:FADD.2, fs:cos_thetaY     ; FMUL.13 = (cos(xrot) * Z3)
            mov fs:FMUL.14, fs:FMUL.6, fs:sin_thetaY     ; FMUL.14 = (sin(xrot) * X3)
            
            mov fs:FADD.5, fs:FMUL.11, fs:FMUL.12        ; FADD.5 = (cos(yrot) * X3) + (sin(yrot) * Z3)
            mov fs:FSUB.5, fs:FMUL.13, fs:FMUL.14        ; FSUB.5 = (cos(yrot) * Z3) - (sin(yrot) * X3)  
            
            ;         X1 is now in FADD_3
            ;         Y1 is now in FSUB_0
            ;         Z1 is now in FSUB_3
            ;         X2 is now in FADD_4
            ;         Y2 is now in FSUB_1
            ;         Z2 is now in FSUB_4
            ;         X3 is now in FADD_5
            ;         Y3 is now in FSUB_2 
            ;         Z3 is now in FSUB_5                      

  ;rotate around Z axis
       ;vertex 1
            ; (cos(zrot) * X1) - (sin(zrot) * Y1) 
            mov fs:FMUL.0, fs:FADD.3, fs:cos_thetaZ      ; FMUL.0 = (cos(zrot) * X1)
            mov fs:FMUL.1, fs:FSUB.0, fs:sin_thetaZ      ; FMUL.1 = (sin(xrot) * Y1)
            ; (sin(zrot) * X1) + (cos(zrot) * Y1) 
            mov fs:FMUL.2, fs:FADD.3, fs:sin_thetaZ      ; FMUL.2 = (sin(xrot) * X1)
            mov fs:FMUL.3, fs:FSUB.0, fs:cos_thetaZ      ; FMUL.3 = (cos(xrot) * Y1)
            
            mov fs:FSUB.6, fs:FMUL.0, fs:FMUL.1          ; FSUB.6 = (cos(zrot) * X1) - (sin(zrot) * Y1)
            mov fs:FADD.6, fs:FMUL.2, fs:FMUL.3          ; FADD.6 = (sin(zrot) * X1) + (cos(zrot) * Y1)

       ;vertex 2
            ; (cos(zrot) * X2) - (sin(zrot) * Y2) 
            mov fs:FMUL.4, fs:FADD.4, fs:cos_thetaZ      ; FMUL.4 = (cos(zrot) * X1)
            mov fs:FMUL.5, fs:FSUB.1, fs:sin_thetaZ      ; FMUL.5 = (sin(xrot) * Y1)
            ; (sin(zrot) * X2) + (cos(zrot) * Y2) 
            mov fs:FMUL.6, fs:FADD.4, fs:sin_thetaZ      ; FMUL.6 = (sin(xrot) * X2)
            mov fs:FMUL.7, fs:FSUB.1, fs:cos_thetaZ      ; FMUL.7 = (cos(xrot) * Y2)
            
            mov fs:FSUB.7, fs:FMUL.4, fs:FMUL.5          ; FSUB.7 = (cos(zrot) * X2) - (sin(zrot) * Y2)
            mov fs:FADD.7, fs:FMUL.6, fs:FMUL.7          ; FADD.7 = (sin(zrot) * X2) + (cos(zrot) * Y2)

       ;vertex 3
            ; (cos(zrot) * X3) - (sin(zrot) * Y3) 
            mov fs:FMUL.8, fs:FADD.5, fs:cos_thetaZ      ; FMUL.8 = (cos(zrot) * X3)
            mov fs:FMUL.9, fs:FSUB.2, fs:sin_thetaZ      ; FMUL.9 = (sin(xrot) * Y3)
            ; (sin(zrot) * X3) + (cos(zrot) * Y3)   
            mov fs:FMUL.10, fs:FADD.5, fs:sin_thetaZ     ; FMUL.10 = (sin(xrot) * X3)
            mov fs:FMUL.11, fs:FSUB.2, fs:cos_thetaZ     ; FMUL.11 = (cos(xrot) * Y3)
            
            mov fs:FSUB.8, fs:FMUL.8, fs:FMUL.9          ; FSUB.8 = (cos(zrot) * X3) - (sin(zrot) * Y3)
            mov fs:FADD.8, fs:FMUL.10, fs:FMUL.11        ; FADD.8 = (sin(zrot) * X3) + (cos(zrot) * Y3)            
            
            ;         X1 is now in FSUB.6
            ;         Y1 is now in FADD.6
            ;         Z1 is now in FSUB.3
            ;         X2 is now in FSUB.7
            ;         Y2 is now in FADD.7
            ;         Z2 is now in FSUB.4
            ;         X3 is now in FSUB.8
            ;         Y3 is now in FADD.8
            ;         Z3 is now in FSUB.5
       
    ;now translate on X, Y, Z axis
        ;vertex 1
            mov fs:FADD.0, fs:FSUB.6, fs:transX     
            mov fs:FADD.1, fs:FADD.6, fs:transY     
            mov fs:FADD.2, fs:FSUB.3, fs:transZ     
        ;vertex 2
            mov fs:FADD.9, fs:FSUB.7, fs:transX     
            mov fs:FADD.10, fs:FADD.7, fs:transY     
            mov fs:FADD.11, fs:FSUB.4, fs:transZ     
        ;vertex 3
            mov fs:FADD.12, fs:FSUB.8, fs:transX     
            mov fs:FADD.13, fs:FADD.8, fs:transY     
            mov fs:FADD.14, fs:FSUB.5, fs:transZ     

            mov fs:*AR2++[4], fs:FADD.0          ;copy transformed X1 to PDB
            mov fs:*AR2++[4], fs:FADD.1          ;copy transformed Y1 to PDB
            mov fs:*AR2++[4], fs:FADD.2          ;copy transformed Z1 to PDB
            mov fs:*AR2++[4], fs:FADD.9          ;copy transformed X2 to PDB
            mov fs:*AR2++[4], fs:FADD.10         ;copy transformed Y2 to PDB
            mov fs:*AR2++[4], fs:FADD.11         ;copy transformed Z2 to PDB
            mov fs:*AR2++[4], fs:FADD.12         ;copy transformed X3 to PDB
            mov fs:*AR2++[4], fs:FADD.13         ;copy transformed Y3 to PDB
            mov fs:*AR2++[4], fs:FADD.14         ;copy transformed Z3 to PDB

            mov uw:PCS, uw:LPCNT0, bit16, loop   ; NEXT LPCNT0 GOTO: loop)         ;continue until done
                    
            mov uh:triangles, uh:#0              ;clear triangles so it doesn't fall through again

            mov uw:PCS, uw:STATUS, ALWAYS, done  ; GOTO done                      ;jump to done, semphr test and spin for next packet

; interrupt service routines        
NMI_:       mov sh:*SP--[8], uh:PC_COPY          ;save return address from non-maskable interrupt (time-out timer in this instance)
            mov uw:TIMER, uw:#60000              ;put a new value in the timer
            mov sh:PC, uh:*SP++[8]               ;return from interrupt
        
INV_:       mov sh:*SP--[8], uh:PC_COPY          ;save return address from floating-point invalid operation exception, which is maskable
            mov ud:capt0_save, ud:CAPTURE0       ;read out CAPTURE0 register and save it
            mov ud:capt1_save, ud:CAPTURE1       ;read out CAPTURE1 register and save it
            mov ud:capt2_save, ud:CAPTURE2       ;read out CAPTURE2 register and save it
            mov ud:capt3_save, ud:CAPTURE3       ;read out CAPTURE3 register and save it
            mov uw:0xFF8B, ub:#invalid           ;lower invalid signal
            mov ub:0xFF04, ub:#invalid           ;raise invalid flag   
            mov uw:TIMER, uw:#60000              ;put a new value in the timer
            mov sh:PC, uh:*SP++[8]               ;return from interrupt
            
DIVx0_:     mov sh:*SP--[8], uh:PC_COPY          ;save return address from floating-point divide by 0 exception, which is maskable
            mov ud:capt0_save, ud:CAPTURE0       ;read out CAPTURE0 register and save it
            mov ud:capt1_save, ud:CAPTURE1       ;read out CAPTURE1 register and save it
            mov ud:capt2_save, ud:CAPTURE2       ;read out CAPTURE2 register and save it
            mov ud:capt3_save, ud:CAPTURE3       ;read out CAPTURE3 register and save it
            mov uw:0xFF8B, ub:#divByZero         ;lower divByZero signal
            mov ub:0xFF04, ub:#divByZero         ;raise divByZero flag   
            mov uw:TIMER, uw:#60000              ;put a new value in the timer
            mov sh:PC, uh:*SP++[8]               ;return from interrupt

OVFL_:      mov sh:*SP--[8], uh:PC_COPY          ;save return address from floating-point overflow exception, which is maskable
            mov ud:capt0_save, ud:CAPTURE0       ;read out CAPTURE0 register and save it
            mov ud:capt1_save, ud:CAPTURE1       ;read out CAPTURE1 register and save it
            mov ud:capt2_save, ud:CAPTURE2       ;read out CAPTURE2 register and save it
            mov ud:capt3_save, ud:CAPTURE3       ;read out CAPTURE3 register and save it
            mov uw:0xFF8B, ub:#overflow          ;lower overflow signal
            mov ub:0xFF04, ub:#overflow          ;raise overflow flag   
            mov uw:TIMER, uw:#60000              ;put a new value in the timer
            mov sh:PC, uh:*SP++[8]               ;return from interrupt

UNFL_:      mov sh:*SP--[8], uh:PC_COPY          ;save return address from floating-point underflow exception, which is maskable
            mov ud:capt0_save, ud:CAPTURE0       ;read out CAPTURE0 register and save it
            mov ud:capt1_save, ud:CAPTURE1       ;read out CAPTURE1 register and save it
            mov ud:capt2_save, ud:CAPTURE2       ;read out CAPTURE2 register and save it
            mov ud:capt3_save, ud:CAPTURE3       ;read out CAPTURE3 register and save it
            mov uw:0xFF8B, ub:#underflow         ;lower underflow signal
            mov ub:0xFF04, ub:#underflow         ;raise underflow flag   
            mov uw:TIMER, uw:#60000              ;put a new value in the timer
            mov sh:PC, uh:*SP++[8]               ;return from interrupt

INEXT_:     mov sh:*SP--[8], uh:PC_COPY          ;save return address from floating-point inexact exception, which is maskable
            mov ud:capt0_save, ud:CAPTURE0       ;read out CAPTURE0 register and save it
            mov ud:capt1_save, ud:CAPTURE1       ;read out CAPTURE1 register and save it
            mov ud:capt2_save, ud:CAPTURE2       ;read out CAPTURE2 register and save it
            mov ud:capt3_save, ud:CAPTURE3       ;read out CAPTURE3 register and save it
            mov uw:0xFF8B, ub:#inexact           ;lower inexact signal
            mov ub:0xFF04, ub:#inexact           ;raise inexact flag   
            mov uw:TIMER, uw:#60000              ;put a new value in the timer
            mov sh:PC, uh:*SP++[8]               ;return from interrupt

IRQ_:       mov sh:*SP--[8], uh:PC_COPY          ;save return address (general-purpose, maskable interrupt)
            mov uw:TIMER, uw:#60000              ;put a new value in the timer
            mov sh:PC, uh:*SP++[8]               ;return from interrupt 
                       
;parameters for this particular 3D transform test run
rotx:       dfl     0, 29                        ;rotate around x axis in integer degrees  
roty:       dfl     0, 44                        ;rotate around y axis in integer degrees  
rotz:       dfl     0, 75                        ;rotate around z axis in integer degrees  
scal_x:     dff     0, 2.0                       ;scale X axis amount real
scal_y:     dff     0, 2.0                       ;scale y axis amount real
scal_z:     dff     0, 2.25                      ;scale Z axis amount real
trans_x:    dff     0, 4.75                      ;translate on X axis amount real
trans_y:    dff     0, 3.87                      ;translate on Y axis amount real
trans_z:    dff     0, 2.237                     ;translate on Z axis amount real

progend:        
            end
          
    
