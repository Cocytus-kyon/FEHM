      subroutine allocate_stressperm
c allocate special use arrays for stress/displacement-permeability
      use comai
      use combi
      use comdi
      use comdti
      use comsi
      implicit none

      integer i

c     model 2 and model 4 require an initial setup      
c     
c     
      if(ipermstr2.ne.0.or.ipermstr6.ne.0.or.ipermstr21.ne.0
     &     .or.ipermstr22.ne.0) then
c     allocate space for parameters      
         if(.not.allocated(pnx0)) then
            allocate(pnx0(neq))
            allocate(pny0(neq))
            allocate(pnz0(neq))
            allocate(e10(neq))
            allocate(e20(neq))
            allocate(e30(neq))	 
            pnx0 = pnx
            pny0 = pny
            pnz0 = pnz
            e10 = e1
            e20 = e2
            e30 = e3
         endif
         if(ipermstr6.ne.0) then
c     
c     effective stress damage model - need lowest pressure 
c     at highest elevation  
c     
            elev_high = -1.e30
            do i = 1,n0
               if(cord(i,igrav).gt.elev_high) then
                  elev_high = cord(i,igrav)
                  pres_elev = pho(i)
               endif
            enddo  
            pres_elev = pres_elev-0.1   
         endif
      endif	 
      
      if(ipermstr7.ne.0.or.ipermstr8.ne.0.or.ipermstr5.ne.0) then
         if(.not.allocated(pnx0)) then
            allocate(pnx0(neq))
            allocate(pny0(neq))
            allocate(pnz0(neq))
            pnx0 = pnx
            pny0 = pny
            pnz0 = pnz
         endif
         
         if(ipermstr8.ne.0) then
            allocate(frac_flg(neq))
            do i = 1,n0
               frac_flg(i) = 0
            enddo
         endif
      endif
c     
      
c     
c     model 3 and model 5 require an initial setup      
c     
c     only allocate if there is a model 3, model 5 and model 8
      if(ipermstr3.ne.0.or.ipermstr5.ne.0.or.ipermstr7.ne.0.
     &     .or.ipermstr8.ne.0) then
         if(.not.allocated(ipermx)) then
            allocate(ipermx(n0,2))
            allocate(ipermy(n0,2))
            allocate(ipermz(n0,2))
            ipermx = 0
            ipermy = 0
            ipermz = 0
         endif
      endif  
c     
         
         return
         
         end
c......................................................................