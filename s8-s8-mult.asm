S8S8toS16Mult:
; Signed 8x8 multiply: A * B -> HL
        ld      h, a        ; save A                        [4]
        ld      e, b        ; save B                        [4]
        ; determine sign
        xor     e           ; A ^ B                         [4]
        ld      c, a        ; store sign in c               [4]

        ; abs(h)
        xor     a           ;                               [4]
        
        ld      d, a        ; oh a zero! give me that!      [4]
        ld      l, a        ; oh ditto!                     [4]        
        
        sub     h           ;                               [4]
        jp      m, A_pos    ;                              [10]
        ld      h, a        ;                               [4]        
A_pos:
        
        ; abs(e)
        xor     a           ;                               [4]
        sub     e           ;                               [4]
        jp      m, B_pos    ;                              [10]
        ld      e, a        ;                               [4]
B_pos:
            
; Multiply 8-bit values
; In:  Multiply H with E
; Out: HL = result
;
Mult8:
        ld      b,8          ;                               [7]
Mult8_Loop:
        add     hl,hl        ;                               [11]
        jr      nc,Mult8_NoAdd ; taken=12, not taken=7
        add     hl,de        ;                               [11]
Mult8_NoAdd:
        djnz    Mult8_Loop   ; taken=13, not taken=8
        
        ; apply sign
        ld      a, c        ;                               [4]
        or      a           ;                               [4]
        ret     p           ; taken=11, not taken=5
        
        ; negate HL
        xor     a           ;                               [4]
        sub     l           ;                               [4]
        ld      l, a        ;                               [4]
        sbc     a, a        ;                               [4]
        sub     h           ;                               [4]
        ld      h, a        ;                               [4]
        
        ret                 ;                               [10]
