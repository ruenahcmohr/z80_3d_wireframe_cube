  
  
  
  
  
  
  
  
  void Rotate3d    (point3d_t *this, point3d_t that) { 

  point3d_t temp;
  
  // x rotation
   temp.y  = (this->y * cos(deg2rad(that.x))) - (this->z * sin(deg2rad(that.x)));
   this->z = (this->y * sin(deg2rad(that.x))) + (this->z * cos(deg2rad(that.x)));
   this->y = temp.y;
    
  // y rotation
   temp.z = (this->z * cos(deg2rad(that.y))) - (this->x * sin(deg2rad(that.y)));
   this->x = (this->z * sin(deg2rad(that.y))) + (this->x * cos(deg2rad(that.y)));
   this->z = temp.z;
     
  // z rotation
   temp.x = (this->x * cos(deg2rad(that.z))) - (this->y * sin(deg2rad(that.z)));
   this->y = (this->x * sin(deg2rad(that.z))) + (this->y * cos(deg2rad(that.z)));
   this->x = temp.x;
}

  
  
  
  
  
  
  
  
  ; use XY scale of 64, Z scale of 1, and Z offset of -5
  ; XY offset of 8
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
 // sinTbl and cosTbl values are multiplied by 128
 // 

  int8_t this[3]; // point X, Y, Z
  int8_t that[3]; // rotation angles X, Y, Z
  
  int8_t cost, sint;    
  int8_t temp;
  int16_t eq1, eq2;
  
  
  
  
  
  
  // x rotation
                
   ; sint = sinTbl[that_x];
   LD   A,  (that_x)
   ADD  #sinTbl_low
   LD   L, A
   LD   A, #0
   ADC  #sinTbl_high
   LD   H, A
   
   LD   A,(HL)
   LD   (sint), A
   
   ; work out the cos(t) table offset (for non-aligned tables)  
   ; cost = sinTbl[128+that_x]; // cos/sin x
   LD   A,  (that_x)
   ADD  #128
   ADD  #sinTbl_low
   LD   L, A
   LD   A, #0
   ADC  #sinTbl_high
   LD   H, A
   
   LD   A,(HL)
   LD  (cost), A         
  
   ;----------- do multiplications via "S8S8toS16Mult" A * B -> HL----------
   
   ; eq1 = (this_y * cost);
   LD    B, (this_y)
   CALL  S8S8toS16Mult
   PUSH  HL
   
   ; eq2 = (this_z * sint);
   LD    A, (sint)
   LD    B, (this_z)
   CALL  S8S8toS16Mult
   POP   DE
      
   ; eq1 -= eq2;   
   SBC HL, DE
      
   ; temp  = eq1 / 2; eq1 is a result multiplied by 64 via the sin table,
   ; dividing by 2 leaves us a multiplier of 64, 
   ; zdist will leave us of +- 8 for a 16x16 pixel screen
   SRA  H
   RR   L
   LD   (temp), L
   
   ; --   
   
   ;eq1 = (this_y * sint);
   LD A, (this_y)
   LD B, (sint)
   CALL  S8S8toS16Mult
   PUSH  HL
   
   ;eq2 = (this_z * cost);
   LD A, (this_z)
   LD B, (cost)
   CALL  S8S8toS16Mult
   
   ;eq1 += eq2;
   POP   DE      
   ADD   HL, DE
    
   ;this_z  = eq1 / 2;   
   SRA  H
   RR   L
   LD   (this_z), L
   
   ;this_z = temp;   
   LD   A, (temp)
   LD   (this_z), A

         
         
         
         
         
  // y rotation
   cost = sinTbl[128+that_y]; // cos/sin y
   sint = sinTbl[that_y];  
  
   eq1 = (this_z * cost);
   eq2 = (this_x * sint);
   temp = eq1 - eq2;
   
   eq1 = (this_z * sint);
   eq2 = (this_x * cost);
   this_x = eq1 + eq2;
   
   this_z = temp;
     
  // z rotation
   cost = sinTbl[128+that_z]; // cos/sin y
   sint = sinTbl[that_z];  
   
   eq1 = (this_x * cost);
   eq2 = (this_y * sint);
   temp = eq1 - eq2;
   
   eq1 = (this_x * sint);
   eq2 = (this_y * cost);
   this_y = eq1 + eq2;
   
   this_x = temp;




////////////////////////

; eq1 = y * angles[0]
ld   A, (this_y)
ld   B, (angles+0)
call S8S8toS16Mult   ; HL = result

push HL              ; save eq1

; eq2 = z * angles[1]
ld   A, (this_z)
ld   B, (angles+1)
call S8S8toS16Mult   ; HL = eq2

pop  DE              ; DE = eq1

; eq1 -= eq2  => DE - HL
or   A               ; clear carry
sbc  HL, DE          ; HL = eq2 - eq1
ex   DE, HL          ; HL = eq1 - eq2

; temp = eq1 / 16  (arithmetic shift right 4)
sra  H
rr   L
sra  H
rr   L
sra  H
rr   L
sra  H
rr   L

ld   A, L            ; temp = low byte
ld   (temp), A













































