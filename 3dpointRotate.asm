  
  
  
  
  
  
  
  
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


//------------------------------------------------------------------------------------

// pseudo code for assembler translation 

// 2d rotation  

r2d(theta, a, b) {  
   ct = cos128(theta);
   st = sin128(theta);
   temp  = (a * ct) - (b * st);
   b = (a * st) + (b * ct)/128;
   a = temp/128;
}

// 3d rotation
void Rotate3d    ({this_x, this_y, this_z}, {theta_x, theta_y, theta_z}) { 
  
  // x rotation
   r2d(theta_x, this_y, this_z);  
       
  // y rotation
   r2d(theta_y, this_z, this_x);
        
  // z rotation
   r2d(theta_z, this_x, this_y);
   
}
  
  
  //------------------------------------------------------------------------------------
  
  
              
  ; use XY scale of 64, Z scale of 1, and Z offset of -5
  ; XY offset of 8
  
  
  /////////////////////////////////////////////////////////////////////////////////
  theta: .db 0x00
  a:     .db 0x00
  b:     .db 0x00
  sint:  .db 0x00
  cost:  .db 0x00
  
  2dRot: ; set up with    theta, a, b
                
   ; sint = sinTbl[that_x];
   LD   A,  (theta)
   ADD  #sinTbl_low
   LD   L, A
   LD   A, #0
   ADC  #sinTbl_high
   LD   H, A
   
   LD   A,(HL)
   LD   (sint), A
   
   ; work out the cos(t) table offset (for non-aligned tables)  
   ; cost = sinTbl[128+that_x]; // cos/sin x
   LD   A,  (theta)
   ADD  #128
   ; may need CLC here
   ADD  #sinTbl_low
   LD   L, A
   LD   A, #0
   ADC  #sinTbl_high
   LD   H, A
   
   LD   A,(HL)
   LD  (cost), A         
  
   ;----------- do multiplications via "S8S8toS16Mult" A * B -> HL----------
   
   ; eq1 = (a * cost);
   ; LD  A, (cost)
   LD    B, (a)
   CALL  S8S8toS16Mult ; HL = A*B
   PUSH  HL
   
   ; eq2 = (b * sint);
   LD    A, (sint)
   LD    B, (b)
   CALL  S8S8toS16Mult; HL = A*B
   POP   DE
      
   ; eq1 -= eq2;   
   SBC HL, DE
      
   ; temp  = eq1 / 128
   SLA  L
   RL   H
   LD   (temp), H
   
   ; --   
   
   ;eq1 = (a * sint);
   LD A, (a)
   LD B, (sint)
   CALL  S8S8toS16Mult; HL = A*B
   PUSH  HL
   
   ;eq2 = (b * cost);
   LD A, (b)
   LD B, (cost)
   CALL  S8S8toS16Mult; HL = A*B
   
   ;eq1 += eq2;
   POP   DE      
   ADD   HL, DE
    
   ;b  = eq1 / 128;   
   SLA  L
   RL   H
;   LD   (b), H
   
   ;a = temp;   
   LD   L, (temp)
;   LD   (a), L

   RET  ; returns with (a) in L, and (b) in H 
         
  
  
 ; set up with    theta_x, theta_y, theta_z, this_x, this_y, this_z
3dRot: 
 
 ; r2d(theta_x, this_y, this_z);
  LD   A,(this_y)  
  LD   (a), A
  
  LD   A,(this_z)
  LD   (b), A
  
  LD   A,(theta_x)   
  LD   (theta), A  
  
  CALL 2dRot; returns with rotated (a) in L, and (b) in H 
  
  
  LD   (this_y), L  ;(L = a = this_y) 
  
  LD   (a), H       ;(H = b = this_z)
    
  ; r2d(theta_y, this_z, this_x); 
  LD   A,(this_x)
  LD   (b), A
  
  LD   A,(theta_y)
  LD   (theta),A  
  
  CALL 2dRot  ; returns with rotated (a) in L, and (b) in H 
  
  
  LD  (this_z), L ; (L = a = this_z)
  
  LD  (a), H      ; (H = b = this_x)
 
  ; r2d(theta_z, this_x, this_y);
  
  LD   A,(this_y)
  LD   (b), A
  
  LD   A,(theta_z) 
  LD   (theta),A  
  
  CALL 2dRot  ; returns with rotated (a) in L, and (b) in H   
  
  LD   (this_x), L ; (L = a = this_x)
  LD   (this_y), H ; (H = b = this_y)
  
  RET
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  













































