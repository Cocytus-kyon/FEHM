      subroutine stressperm_7(i)
! ********Bai et al model (stress based)	 
! 2d not implemented
      use comai
      use combi
      use comdi
      use comsi

      implicit none
      integer i, iispmd
      integer kbx1,kbx2,kby1,kby2,kbz1,kbz2,idir

      real*8  ipmd7_dsx,ipmd7_dsy,ipmd7_dsz
      real*8  ipmd7_dsxy,ipmd7_dsxz,ipmd7_dsyz
      real*8  ipmd7_knx,ipmd7_kny,ipmd7_knz
      real*8  ipmd7_nmx,ipmd7_nmy,ipmd7_nmz
      real*8  ipmd7_shx,ipmd7_shy,ipmd7_shz
      real*8  pi, phid
      real*8  frac_tol, disz,disy,disx
      real*8  ksx, ksy, ksz
      real*8 frac_bx, frac_by, frac_bz

      parameter (frac_tol=0.00001)

      iispmd = ispm(i)

      if(icnl.ne.0) then 
         write(ierr,*) 'Bai model not implemented in 2D'
         write(ierr,*) 'stopping in stress_perm.f'
         
      endif        
!     
!     **************************** 3D
!     
      if(icnl.eq.0) then 
         
         frac_bx = spm1f(iispmd)
         frac_by = spm2f(iispmd)
         frac_bz = spm3f(iispmd)
         knx_stressperm = spm4f(iispmd)
         ksx = spm5f(iispmd)
         phid = spm6f(iispmd)
         
         kny_stressperm = knx_stressperm
         knz_stressperm = knx_stressperm
         ksy = ksx
         ksz = ksx	     
         ipmd7_nmx = 0.
         ipmd7_nmy = 0.
         ipmd7_nmz = 0.
         ipmd7_shx = 0.
         ipmd7_shy = 0.
         ipmd7_shz = 0.
         
         perx_m=1.e4
         pery_m=1.e4
         perz_m=1.e4
!     initial stress - current stress	   
         ipmd7_dsx = estr_x0(i) - (str_x(i)-phi(i))
         ipmd7_dsy = estr_y0(i) - (str_y(i)-phi(i))
         ipmd7_dsz = estr_z0(i) - (str_z(i)-phi(i))
         ipmd7_dsxy = abs(str_xy0(i) - str_xy(i))
         ipmd7_dsxz = abs(str_xz0(i) - str_xz(i))
         ipmd7_dsyz = abs(str_yz0(i) - str_yz(i))
         
         if(ipmd7_dsx.lt.0) ipmd7_dsx = 0.
         if(ipmd7_dsy.lt.0) ipmd7_dsy = 0.
         if(ipmd7_dsz.lt.0) ipmd7_dsz = 0.
         
         kbx1 = ipermx(i,1)
         kbx2 = ipermx(i,2)
         kby1 = ipermy(i,1)
         kby2 = ipermy(i,2)
         kbz1 = ipermz(i,1)
         kbz2 = ipermz(i,2)
!     
!     identify displacements
!     
         disx = (cord(kbx2,1)-cord(kbx1,1))/2.
         disy = (cord(kby2,2)-cord(kby1,2))/2.
         disz = (cord(kbz2,3)-cord(kbz1,3))/2.
         
!     
!     fracture dilation (normal and shear)        
!     
         if(frac_bx.ne.0.) then
            ipmd7_nmx = ipmd7_dsx/(knx_stressperm*frac_bx) + disx/frac_bx       &
      *((ipmd7_dsx-poisson(i)*(ipmd7_dsy+ipmd7_dsz))/elastic_mod(i)  &
             +alp(i)*(t(i)-tini(i)))
            
            if(str_x(i)-phi(i).lt.0) then
               ipmd7_shx = 0.
            else     
               ipmd7_shx = ((disy/e3(i)+1/ksy)*ipmd7_dsxy            &
         +(disz/e3(i)+1/ksz)*ipmd7_dsxz)*tan(phid/180*pi)/frac_bx
            endif
            
         endif 
         
         if(frac_by.ne.0.) then
              ipmd7_nmy = ipmd7_dsy/(kny_stressperm*frac_by) + disy/frac_by    &
        *((ipmd7_dsy-poisson(i)*(ipmd7_dsx+ipmd7_dsz))/elastic_mod(i)  &
                +alp(i)*(t(i)-tini(i)))
              
              if(str_y(i)-phi(i).lt.0) then
                 ipmd7_shy = 0.
              else
                 ipmd7_shy = ((disx/e3(i)+1/ksx)*ipmd7_dsxy  &
          +(disz/e3(i)+1/ksz)*ipmd7_dsyz)*tan(phid/180*pi)/frac_by
              endif
              
           endif
           
           if(frac_bz.ne.0.) then
              ipmd7_nmz = ipmd7_dsz/(knz_stressperm*frac_bz) + disz/frac_bz  &
        *((ipmd7_dsz-poisson(i)*(ipmd7_dsx+ipmd7_dsy))/elastic_mod(i)  &
                  +alp(i)*(t(i)-tini(i)))
              
              if(str_z(i)-phi(i).lt.0) then
                 ipmd7_shy = 0.
              else
                 ipmd7_shz = ((disx/e3(i)+1/ksx)*ipmd7_dsxz  &
          +(disy/e3(i)+1/ksy)*ipmd7_dsyz)*tan(phid/180*pi)/frac_bz
              endif
              
           endif
           
! check
           check(i) = ipmd7_shy*frac_by    
!     
!     perm enhancement    
!     
           
           if(frac_by.ne.0.or.frac_bz.ne.0) then
              pnx(i) = pnx0(i)/(frac_by**3+frac_bz**3)*  &
                  ( frac_by**3*(1+ipmd7_nmy+ipmd7_shy)**3 &
                  + frac_bz**3*(1+ipmd7_nmz+ipmd7_shz)**3 ) 
           endif
           
           if(frac_bx.ne.0.or.frac_bz.ne.0) then
              pny(i) = pny0(i)/(frac_bx**3+frac_bz**3)*  &
                  ( frac_bx**3*(1+ipmd7_nmx+ipmd7_shx)**3  &
                  + frac_bz**3*(1+ipmd7_nmz+ipmd7_shz)**3 )                 
           endif
           
           if(frac_bx.ne.0.or.frac_by.ne.0) then
              pnz(i) = pnz0(i)/(frac_bx**3+frac_by**3)*  &
                  ( frac_bx**3*(1+ipmd7_nmx+ipmd7_shx)**3  &
                  + frac_by**3*(1+ipmd7_nmy+ipmd7_shy)**3 )
           endif     
           
           
!     pnx(i) = min(perx_m*pnx0(i),pnx(i))
!     pny(i) = min(pery_m*pny0(i),pny(i))
!     pnz(i) = min(perz_m*pnz0(i),pnz(i))
!     pnx(i) = max(0.01*pnx0(i),pnx(i))
!     pny(i) = max(0.01*pny0(i),pny(i))  
!     pnz(i) = max(0.01*pnz0(i),pnz(i))
           
        endif   
          return
          
          end
!....................................................................