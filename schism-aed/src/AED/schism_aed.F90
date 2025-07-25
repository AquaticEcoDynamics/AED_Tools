!###############################################################################
!#                                                                             #
!# schism_aed.F90                                                              #
!#                                                                             #
!# The interface between schism and libaed-xxx                                 #
!#                                                                             #
!# Developed by :                                                              #
!#     AquaticEcoDynamics (AED) Group                                          #
!#     School of Agriculture and Environment                                   #
!#     The University of Western Australia                                     #
!#                                                                             #
!#     http://aquatic.science.uwa.edu.au/                                      #
!#                                                                             #
!# Copyright 2025 - The University of Western Australia                        #
!#                                                                             #
!#  This is free software: you can redistribute it and/or modify               #
!#  it under the terms of the GNU General Public License as published by       #
!#  the Free Software Foundation, either version 3 of the License, or          #
!#  (at your option) any later version.                                        #
!#                                                                             #
!#  This is distributed in the hope that it will be useful,                    #
!#  but WITHOUT ANY WARRANTY; without even the implied warranty of             #
!#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
!#  GNU General Public License for more details.                               #
!#                                                                             #
!#  You should have received a copy of the GNU General Public License          #
!#  along with this program.  If not, see <http://www.gnu.org/licenses/>.      #
!#                                                                             #
!###############################################################################

#include "aed_api.h"

#define AED_MODL_NO 13
#define NC_FILLER    (9.9692099683868690d+36)


!#----------------------------------------------------------------------------#!
!# CAB: Some DEBUG bits want DEBUG to be non-zero ; some want > 1
#define DEBUG  1
#define TRACE  1
#if DEBUG
# define DPRINT IF (myrank==0) print*,
# define DPRINTF IF (myrank==0) print
# if TRACE
#  define DTPRINT IF (myrank==0) print*,
# else
#  define DTPRINT !
# endif
#else
# define DPRINT  !
# define DPRINTF !
# define DTPRINT !
#endif
#if TRACE
# define TPRINT IF (myrank==0) print*,
# define TPRINTF print
#else
# define TPRINT  !
# define TPRINTF !
#endif
!#----------------------------------------------------------------------------#!


!#----------------------------------------------------------------------------#!
MODULE schism_aed
!
   USE IEEE_ARITHMETIC
!
   USE netcdf
!
  !# "elements" in schism are what we call columns
  !# layers are indexed from the bottom up
  !# kbe(col) is the bottom (0 based)
  !#
  !# These are commented as in schism_glbl.F90 which may not make sense yet
  USE schism_glbl,ONLY: rkind

  USE schism_glbl,ONLY: ne        ! Local number of resident elements
! USE schism_glbl,ONLY: neg       ! Local number of ghost elements
! USE schism_glbl,ONLY: nea       ! Local number of elements in augmented subdomain (ne+neg)
  USE schism_glbl,ONLY: nvrt      ! Number of vertical layers
! USE schism_glbl,ONLY: np,npg,npa,iplg,ipgl       ! ??

  USE schism_glbl,ONLY: kbe       ! Element bottom vertical indices
  USE schism_glbl,ONLY: idry_e    ! wet/dry flag (integer; == 0 means active)

  USE schism_glbl,ONLY: ze        ! z-coord (local frame - vertical up) 2D 
  USE schism_glbl,ONLY: dpe       ! Depth at element (min of all nodes)

  USE schism_glbl,ONLY: area      ! Element areas [col] - all layers in a column are the same?
  USE schism_glbl,ONLY: xlon_el,ylat_el ! Element center lat/lon coordinates in _degrees_

  !# look at schism/src/Hydro/schism_step.F90:9037 in the #ifdef OLDIO sectio...
  !# there are a bunch of write statement outputing data with descriptions

  USE schism_glbl,ONLY: erho      ! (effective?) density  [layers,columns]
  USE schism_glbl,ONLY: rho0      ! density (?)
  USE schism_glbl,ONLY: grav      ! along with rho0 for calculating internal pressure
  USE schism_glbl,ONLY: tr_el     ! [tracers, layers, columns]
  USE schism_glbl,ONLY: tr_nd     ! [tracers, layers, nodes] tracer concentration @ node and whole levels
  USE schism_glbl,ONLY: irange_tr ! [??, model]
! USE schism_glbl,ONLY: bdy_frc, wsett !

  !# elnode is a mapping array where, when index-1 = 3, index-2 maps nodes to elements
  !# i34 determines the type and it seems we can use it for index-1 
  USE schism_glbl,ONLY: i34       ! elem. type (3 or 4) [col]
  USE schism_glbl,ONLY: elnode    ! Element-node tables [n, col]

  USE schism_glbl,ONLY: windx,windy     ! wind vector [nodes]

  USE schism_glbl,ONLY: airt1, airt2, prec_rain, prec_snow  ! [nodes]
  USE schism_glbl,ONLY: srad    ! surface radiation?
  USE schism_glbl,ONLY: shum1   ! surface humidity?
  USE schism_glbl,ONLY: pr      ! air pressure?
  USE schism_glbl,ONLY: pr2     ! or is this ?? air pressure?

  USE schism_glbl,ONLY: dt      ! timestep

! !Velocity at nodes & whole levels at current timestep. If ics=2, it's in ll frame
! real(rkind),save,allocatable, target :: uu2(:,:),vv2(:,:),ww2(:,:)
  USE schism_glbl,ONLY: uu2,vv2,ww2

  USE schism_glbl,ONLY: fluxevp  !# evaporation  [nodes]
  USE schism_glbl,ONLY: hradd    !# longwave?    [nodes]
  USE schism_glbl,ONLY: tau_bot_node  !# taub    [nodes]

  USE schism_glbl,ONLY: in_dir, len_in_dir
  USE schism_glbl,ONLY: out_dir,len_out_dir

  USE schism_msgp,ONLY: myrank, parallel_abort
  USE schism_msgp,ONLY: nproc_schism, task_id

!
   USE aed_util
   USE aed_common
   USE aed_api
!
   IMPLICIT NONE
!
   PRIVATE ! By default, make everything private
!
   PUBLIC schism_aed_configure_models, schism_aed_init_models
   PUBLIC schism_aed_name_3D_scribes, schism_aed_name_2D_scribes
   PUBLIC schism_aed_create_output, schism_aed_do
   PUBLIC schism_aed_write_output, schism_aed_finalise
   PUBLIC cc_hz, n_vars_ben
#ifdef OLDIO
   PUBLIC aed_writeout
#endif

!
!-------------------------------------------------------------------------------
!MODULE DATA

   TYPE(aed_data_t),DIMENSION(:),ALLOCATABLE,TARGET :: data

   !# Arrays for work, vertical movement, and cross-boundary fluxes
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET   :: cc_hz      !# [n_vars_ben,cols]
   AED_REAL,DIMENSION(:,:,:),ALLOCATABLE,TARGET :: cc_diag    !# [n_diag_vars,layers,cols]
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET   :: cc_diag_hz !# [n_diag_hz_vars,cols]

   !# geometry related
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET :: lheights   !# [layers,cols] Layer Heights
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET :: depth      !# [layers,cols] LayerDepths
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET :: area_      !# [layers,cols] this is filled from extern var "area"
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET :: dz         !# [layers,cols]
   AED_REAL,DIMENSION(:),ALLOCATABLE,TARGET :: col_depth

   !# Arrays for environmental variables not supplied externally.
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET :: par  !# [layers,cols]
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET :: uva  !# [layers,cols]
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET :: uvb  !# [layers,cols]
   AED_REAL,DIMENSION(:,:),ALLOCATABLE,TARGET :: nir  !# [layers,cols]

   AED_REAL,DIMENSION(:,:),POINTER :: cvel     !# [layers,cols]

   AED_REAL,DIMENSION(:,:),POINTER :: temp     !# [layers,cols] - point to tr_el(1,:,:)
   AED_REAL,DIMENSION(:,:),POINTER :: salt     !# [layers,cols] - point to tr_el(2,:,:)
   AED_REAL,DIMENSION(:,:),POINTER :: rho      !# [layers,cols] - point to erho
   AED_REAL,DIMENSION(:,:),POINTER :: rad      !# [layers,cols] - dummied

   AED_REAL,DIMENSION(:,:),POINTER :: pres     !# [layers,cols]

   AED_REAL,DIMENSION(:,:),POINTER :: extc

   AED_REAL,DIMENSION(:),POINTER :: rain
   AED_REAL,DIMENSION(:),POINTER :: air_temp
   AED_REAL,DIMENSION(:),POINTER :: air_pres
   AED_REAL,DIMENSION(:),POINTER :: humidity
   AED_REAL,DIMENSION(:),POINTER :: I_0
   AED_REAL,DIMENSION(:),POINTER :: wind
   AED_REAL,DIMENSION(:),POINTER :: matz

   !# not found
   AED_REAL,DIMENSION(:,:),POINTER :: tss      !# [layers,cols]
   AED_REAL,DIMENSION(:,:),POINTER :: ss1
   AED_REAL,DIMENSION(:,:),POINTER :: ss2
   AED_REAL,DIMENSION(:,:),POINTER :: ss3
   AED_REAL,DIMENSION(:,:),POINTER :: ss4
   AED_REAL,DIMENSION(:,:),POINTER :: wv_t
   AED_REAL,DIMENSION(:,:),POINTER :: wv_uorb
   AED_REAL,DIMENSION(:,:),POINTER :: ustar_bed
   AED_REAL,DIMENSION(:,:),POINTER :: sed_zones
   AED_REAL,DIMENSION(:),POINTER :: evap       !# [cols]
   AED_REAL,DIMENSION(:),POINTER :: sed_zone
   AED_REAL,DIMENSION(:),POINTER :: longwave
   AED_REAL,DIMENSION(:),POINTER :: layer_stress

   !# these are feedback vars
   AED_REAL,DIMENSION(:,:),POINTER :: biodrag    => null()
   AED_REAL,DIMENSION(:,:),POINTER :: bioextc    => null()
   AED_REAL,DIMENSION(:),POINTER :: solarshade   => null()
   AED_REAL,DIMENSION(:),POINTER :: windshade    => null()
   AED_REAL,DIMENSION(:),POINTER :: bathy        => null()
   AED_REAL,DIMENSION(:),POINTER :: rainloss     => null()

   LOGICAL,DIMENSION(:),POINTER :: active !# [cols] - = (idry_e == 0)
   INTEGER,DIMENSION(:),POINTER :: botidx !# [cols] - set to kbe + 1

   INTEGER,TARGET :: n_layers = -1
   INTEGER :: n_cols = -1
   INTEGER :: n_aed_vars = 0, n_vars = 0,      n_vars_ben = 0
   INTEGER ::                 n_vars_diag = 0, n_vars_diag_sheet = 0

   !# These are just to get it compiling for now
   INTEGER :: split_factor, benthic_mode
   AED_REAL,TARGET ::  rain_factor, sw_factor, friction
   AED_REAL,TARGET :: Kw
!  AED_REAL :: Ksed
   LOGICAL :: mobility_off, bioshade_feedback, repair_state
   AED_REAL,TARGET :: timestep, yearday

!#===================================================
!  %% NAMELIST   %%  /aed_config/
   INTEGER  :: solution_method = 1

   !# Switches for configuring model operation and active links with the host model
   LOGICAL  :: link_bottom_drag = .FALSE.
   LOGICAL  :: link_surface_drag = .FALSE.
   LOGICAL  :: link_water_density = .FALSE.
   LOGICAL  :: link_water_clarity = .FALSE.
   LOGICAL  :: link_ext_par = .FALSE.
   AED_REAL :: base_par_extinction = 0.1
   LOGICAL  :: ext_tss_extinction = .FALSE.
   AED_REAL :: tss_par_extinction = 0.2
   LOGICAL  :: do_particle_bgc = .FALSE.
   LOGICAL  :: do_2d_atm_flux = .TRUE.

   LOGICAL  :: do_zone_averaging = .FALSE.
   LOGICAL  :: link_solar_shade = .TRUE.
   LOGICAL  :: link_rain_loss = .FALSE.

   !# debug option
   LOGICAL  :: depress_clutch = .FALSE.
   LOGICAL  :: depress_clutch2 = .FALSE.

   !# Name of files being used to load initial values for benthic
   !  or benthic_diag vars, and the horizontal routing table for riparian flows
!  CHARACTER(len=128) :: init_values_file = ''
   CHARACTER(len=128) :: output_file = 'aed_data'

   LOGICAL  :: do_limiter = .FALSE.

   !# maximum single precision real is 2**128 = 3.4e38
   AED_REAL :: glob_min = -1.0e38
   AED_REAL :: glob_max =  1.0e38
   LOGICAL  :: no_glob_lim = .FALSE.

!  CHARACTER(len=128) :: route_table_file = ''

   AED_REAL :: min_water_depth =  0.0401
   INTEGER  :: n_equil_substep = 1

   LOGICAL  :: link_wave_stress = .FALSE.
   AED_REAL :: wave_factor =  1.0

   LOGICAL  :: display_minmax = .FALSE.

   AED_REAL :: nir_frac =  0.52   ! 0.51
   AED_REAL :: par_frac =  0.43   ! 0.45
   AED_REAL :: uva_frac =  0.048  ! 0.035
   AED_REAL :: uvb_frac =  0.002  ! 0.005

   INTEGER :: debug_interval = 10000
   INTEGER :: debug_col = 1

!  %% END NAMELIST   %%  /aed_config/
!#===================================================

   INTEGER :: ncid = 0  !# nc file id
   INTEGER,DIMENSION(:),ALLOCATABLE :: externalid
   INTEGER,DIMENSION(:),ALLOCATABLE :: zone_id
   INTEGER :: ts_counter = 0 !# time step counter

   REAL :: start = 0.0
   REAL :: prev = 0.0
   REAL :: time_aed_do = 0.0
   REAL :: time_aed_wrt = 0.0
   LOGICAL :: inited = .FALSE.
   TYPE(aed_coupling_t) :: cpl
!
!===============================================================================
CONTAINS

!#            -----------------------------------------------------
!# start of init

!###############################################################################
SUBROUTINE schism_aed_configure_models(ntracers)
!-------------------------------------------------------------------------------
!ARGUMENTS
   INTEGER,INTENT(inout) :: ntracers
!
!LOCALS
   CHARACTER(len=80) :: fname
   INTEGER :: namlst, status
!
   NAMELIST /aed_config/ solution_method, link_bottom_drag,                    &
                         link_surface_drag, link_water_density,                &
                         link_water_clarity, link_ext_par,                     &
                         base_par_extinction, ext_tss_extinction,              &
                         tss_par_extinction,                                   &
                         do_particle_bgc, do_2d_atm_flux, do_zone_averaging,   &
                         link_solar_shade, link_rain_loss,                     &
!                        init_values_file,                                     &
                         output_file,                                          &
                         do_limiter, glob_min, glob_max, no_glob_lim,          &
                         min_water_depth,                                      &
                         n_equil_substep,                                      &
                         link_wave_stress, wave_factor,                        &
                         nir_frac,par_frac, uva_frac, uvb_frac,                &
                         display_minmax,                                       &
                         depress_clutch, depress_clutch2,                      &
                         debug_interval, debug_col
!
!-------------------------------------------------------------------------------
!BEGIN
   CALL CPU_TIME(start)
   prev = start
   print*,"schism_aed_configure_models: Hello World"

   fname = "aed.nml"
   namlst = find_free_lun()
   OPEN(namlst,file=fname,action='read',status='old',iostat=status)
   IF ( status /= 0 ) THEN
     print*,"Cannot open file ", TRIM(fname)
     RETURN
   ENDIF
   READ(namlst, nml=aed_config, iostat=status)
   IF ( status /= 0 ) THEN
     print*,"Cannot read aed_config from file ", TRIM(fname)
     RETURN
   ENDIF
   CLOSE(namlst);
   inited = .TRUE.

   Kw = base_par_extinction
!  Ksed = tss_par_extinction

   cpl%par_fraction =  par_frac
   cpl%nir_fraction =  nir_frac
   cpl%uva_fraction =  uva_frac
   cpl%uvb_fraction =  uvb_frac

   cpl%mobility_off = mobility_off
   cpl%bioshade_feedback = bioshade_feedback
   cpl%repair_state = repair_state
   cpl%link_rain_loss = link_rain_loss
   cpl%link_solar_shade = link_solar_shade
   cpl%link_bottom_drag = link_bottom_drag

   cpl%split_factor = split_factor
   cpl%benthic_mode = benthic_mode

   cpl%rain_factor => rain_factor
   cpl%sw_factor => sw_factor
   cpl%friction => friction

   cpl%Kw => Kw
!  cpl%Ksed = Ksed

   print *,'    link options configured between SCHISM & AED - '
   print *,'        link_ext_par       :  ',link_ext_par
   print *,'        link_water_clarity :  ',link_water_clarity
   print *,'        link_surface_drag  :  ',link_surface_drag,' (not implemented)'
   print *,'        link_bottom_drag   :  ',link_bottom_drag
   print *,'        link_wave_stress   :  ',link_wave_stress
   print *,'        link_solar_shade   :  ',link_solar_shade
   print *,'        link_rain_loss     :  ',link_rain_loss
   print *,'        link_particle_bgc  :  ',do_particle_bgc,' (under development)'
   print *,'        link_water_density :  ',link_water_density,' (not implemented)'

   !# set aed coupling parameters
   CALL aed_set_coupling(cpl)

   !# Initialise the model, which will read the file provided in "fname"
   fname = "aed.nml"
   n_aed_vars = aed_configure_models(fname, n_vars, n_vars_ben, n_vars_diag, n_vars_diag_sheet)
   DTPRINT "model initied with ",n_aed_vars, n_vars, n_vars_ben, n_vars_diag, n_vars_diag_sheet

   ntracers=n_vars
   TPRINT "schism_aed_configure_models done; ntracers = ",ntracers
END SUBROUTINE schism_aed_configure_models
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE schism_to_aed_env()
!-------------------------------------------------------------------------------
!# Fills local copies of enviroment data per column with values computed from 
!# schism "nodes"
!#
!# Not sure yet what to do about feedback if necessary
!-------------------------------------------------------------------------------
!ARGUMENTS
!
!LOCALS
   INTEGER :: lev, col, idx, dep
   AED_REAL :: localext = zero_
!
!# a little macro for simplicity.
#define SCHISM_N2E_VAL(ar) (sum(ar(elnode(1:idx, col))) / idx)
#define SCHISM_N2E_VALS(ar,X) (sum(ar(X,elnode(1:idx, col))) / idx)
!-------------------------------------------------------------------------------
!BEGIN
   !# need to put index ranges in for mpi run stuff - indexes are different
   active(1:n_cols) = (idry_e(1:n_cols) == 0)
   botidx(1:n_cols) = kbe(1:n_cols) !+ 1
   n_layers = nvrt

   DO col=1,n_cols
      IF ( .NOT. active(col) ) CYCLE

!# There are 2 ways of defining layers not sure which way is right yet
#if 1
      !# re-compute the layer heights and depths
      col_depth(col) = dpe(col) + ze(n_layers,col)
      lheights(1,col) = dpe(col) + ze(1,col)
      dz(1,col) = dpe(col) + ze(1,col)
      depth(1,col) = col_depth(col)
      DO lev=2,n_layers
         lheights(lev,col) = dpe(col)+ze(lev,col)
         dz(lev,col) = lheights(lev,col) - lheights(lev-1,col)
         depth(lev,col) = col_depth(col) - lheights(lev,col)
      ENDDO
#else
      depth(:, col) = 0.
      dz(:, col) = 0.
      lheights(:, col) = 0.

  !   col_depth(col) = -(ze(kbe(col), col)+ze(kbe(col)+1, col))/2
  !   dz(kbe(col)+1:nvrt,col)       =   ze(kbe(col)+1:nvrt,col)-ze(kbe(col):nvrt-1,col)
  !   depth(kbe(col)+1:nvrt,col)    = -(ze(kbe(col)+1:nvrt,col)+ze(kbe(col):nvrt-1,col))/2
  !   lheights(kbe(col)+1:nvrt,col) = col_depth(col) - depth(kbe(col)+1:nvrt,col)

      col_depth(col) = -ze(kbe(col), col)
      dz(kbe(col)+1:nvrt,col)       =  ze(kbe(col)+1:nvrt,col)-ze(kbe(col):nvrt-1,col)
      depth(kbe(col):nvrt,col)      = -ze(kbe(col):nvrt,col)
      lheights(kbe(col):nvrt,col)   = col_depth(col) - depth(kbe(col):nvrt,col)
#endif

#if 0
 !# This stuff is for debugging the depth/dz/heights stuff
 print*,"ze sizing (",size(ze,1),",",size(ze,2),") .. dpe size ",size(dpe)
 print*,"col = ",col, " dpe(col) = ",dpe(col), " col_depth(col) = ",col_depth(col), " nvrt = ",nvrt," kbe(col) = ",kbe(col)
 do lev=1, nvrt
   print '("ze = ",f16.8, " ; lheights = ", f16.8," ; dz = ",f16.8," ; depth = ",f16.8)', &
            ze(lev,col),      lheights(lev,col),      dz(lev,col),     depth(lev,col)
 enddo
 stop
#endif

      !# Now map environs schism->aed
      idx=i34(col)

      rain(col) =      SCHISM_N2E_VAL(prec_rain)
      air_temp(col) =  SCHISM_N2E_VAL(airt1)
      air_pres(col) =  SCHISM_N2E_VAL(pr)
      wind(col) = sqrt(SCHISM_N2E_VAL(windx)**2 + SCHISM_N2E_VAL(windy)**2)

      I_0(col) =       SCHISM_N2E_VAL(srad)

  !#  CALL update_light(column, nvrt)
      par(:,col) = I_0(col) * par_frac * EXP(-(Kw+localext)*1e-6*dz(:,col))

      nir(:,col) = (par(:,col)/par_frac) * nir_frac
      uva(:,col) = (par(:,col)/par_frac) * uva_frac
      uvb(:,col) = (par(:,col)/par_frac) * uvb_frac

      humidity(col) =  SCHISM_N2E_VAL(shum1)

      layer_stress  =  SCHISM_N2E_VALS(tau_bot_node,1)
      evap          =  SCHISM_N2E_VAL(fluxevp)
      longwave      =  SCHISM_N2E_VAL(hradd)

      cvel(:,col) = sqrt(SCHISM_N2E_VALS(uu2,:)**2 + SCHISM_N2E_VALS(vv2,:)**2)

      DO lev=1,n_layers
        dep = max(lev, kbe(col))
        pres(lev,col) = rho0 * grav * ABS(ze(n_layers, col)-ze(dep, col)) * 1.e-4
      ENDDO
      pres(:,col) = pres(:,col)+SCHISM_N2E_VAL( pr2 ) * 1.e-4
   ENDDO
END SUBROUTINE schism_to_aed_env
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#if DEBUG
!###############################################################################
SUBROUTINE debug_oxy(msg)
!-------------------------------------------------------------------------------
!ARGUMENTS
   CHARACTER(*),INTENT(in) :: msg
!LOCALS
   INTEGER :: i, k, v, col

   TYPE(aed_variable_t),POINTER :: tv
!
   CHARACTER(len=8) :: act
!
!-------------------------------------------------------------------------------
!BEGIN
   v = 0
   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( .NOT. tv%sheet ) THEN
            IF ( tv%var_type == V_STATE ) THEN
               v = v + 1
               IF ( tv%name == "OXY_oxy" ) THEN
                  EXIT  !# exit the loop with v being the index for oxy_oxy
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDDO

   DO col=1,n_cols
      IF ( active(col) ) THEN
         k = kbe(col)+1
         IF (isnan(MINVAL(data(col)%cc(v,k:nvrt))) .OR. isnan(MAXVAL(data(col)%cc(v,k:nvrt))) ) THEN
            print*, "DEBUG_OXY : myrank = ",myrank," msg = ",msg," col = ",col
            DPRINTF '(1X,"V: ",I2,1X,A14," <=> ",f20.8,f20.8," : (",A,")")', &
                             v,TRIM(tv%name),MINVAL(data(col)%cc(v,k:nvrt)),MAXVAL(data(col)%cc(v,k:nvrt)),TRIM(tv%units)
            DO i=k,nvrt
               IF ( isnan(data(col)%cc(v,i)) ) print*,"on levl",i
            ENDDO
            STOP
         ENDIF
      ENDIF
   ENDDO
END SUBROUTINE debug_oxy
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE debug_max_min(msg)
!-------------------------------------------------------------------------------
!ARGUMENTS
   CHARACTER(*),INTENT(in) :: msg
!LOCALS
   INTEGER :: i, v, d, vs, ds, col, sza, k

   TYPE(aed_variable_t),POINTER :: tv
!
   CHARACTER(len=8) :: act
!
!-------------------------------------------------------------------------------
!BEGIN
   IF ( myrank /= 0 ) RETURN

   print*, "myrank = ",myrank," msg = ",msg, nproc_schism, task_id, n_cols

   col = debug_col
   sza = size(active)
   IF (col >= sza) col = sza
   IF ( .NOT. active(col) ) THEN
      DO col = 1,sza
        IF ( active(col) ) EXIT
      ENDDO
      IF (col >= sza) THEN
        print*,"no active col found"
        RETURN
      ENDIF
   ENDIF

   IF ( .NOT. active(col) ) return ! how did we et here?
   act = "active"
   k = kbe(col)

   print*,"values at col = ", col, " of ", n_cols, " which is ",act
   print*,"yearday=",yearday,"longitude=",xlon_el(col),"latitude=",ylat_el(col)
   v = 0; d = 0; vs = 0 ; ds = 0
   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( .NOT. tv%sheet ) THEN
            IF ( tv%var_type == V_STATE ) THEN
               v = v + 1
               DPRINTF '(1X,"V: ",I2,1X,A14," <=> ",f20.8,f20.8," : (",A,")")', &
                                       v,TRIM(tv%name),MINVAL(data(col)%cc(v,k:nvrt)),MAXVAL(data(col)%cc(v,k:nvrt)),TRIM(tv%units)
            ELSE IF ( tv%var_type == V_DIAGNOSTIC .AND. .NOT. no_glob_lim ) THEN
               d = d + 1
               DPRINTF '(1X,"D: ",I2,1X,A14," <=> ",f20.8,f20.8," : (",A,")")', &
                              d,TRIM(tv%name),MINVAL(data(col)%cc_diag(d,:)),MAXVAL(data(col)%cc_diag(d,:)),TRIM(tv%units)
            ENDIF
         ELSE
            !# sheet
            IF ( tv%var_type == V_STATE ) THEN
               vs = vs + 1
               DPRINTF '(1X,"v: ",I2,1X,A14," <=> ",f20.8,f20.8," : (",A,")")', &
                                       vs,TRIM(tv%name),MINVAL(cc_hz(vs,:)),MAXVAL(cc_hz(vs,:)),TRIM(tv%units)
            ELSEIF ( tv%var_type == V_DIAGNOSTIC .AND. .NOT. no_glob_lim ) THEN
               ds = ds + 1
               DPRINTF '(1X,"d: ",I2,1X,A14," <=> ",f20.8,f20.8," : (",A,")")', &
                              ds,TRIM(tv%name),MINVAL(cc_diag_hz(ds,:)),MAXVAL(cc_diag_hz(ds,:)),TRIM(tv%units)
            ENDIF
         ENDIF
      ENDIF
   ENDDO

#if 0
#define DFMTSTR '(1X,"E: ",I2,1X,A14," <=> ",f20.8,f20.8," : ",A)'
#define DR_ARGS(ar,nm,info) v,nm,MINVAL(ar),MAXVAL(ar),info
#define DIPRINT(ar,nm,info) DPRINTF DFMTSTR, DR_ARGS(ar,nm,info)
   v=1   ; DIPRINT(temp(:,col),"temperature","temp => tr_el(1,:,col)")
   v=v+1 ; DIPRINT(salt(:,col),"salinity","salt => tr_el(2,:,col)")
   v=v+1 ; DIPRINT(rho(:,col),"density","rho  => erho(:,:)")
   v=v+1 ; DIPRINT(cvel(:,col),"velocity","cvel(:,col) = sqrt(SCHISM_N2E_VALS(uu2,:)**2 + SCHISM_N2E_VALS(vv2,:)**2)")
   v=v+1 ; DIPRINT(depth(:,col),"depth","depth calculated from dpe and ze")
   v=v+1 ; DIPRINT(pres(:,col),"pressure","pres calculated from rho0 and grav")
   v=v+1 ; DIPRINT(dz(:,col),"thick","dz calculated from dpe and ze")
   v=v+1 ; DIPRINT(area_(:,col),"area", "area_ extended from 'area' to 3D")
   v=v+1 ; DIPRINT(extc(:,col),"extc", "extc NOT FOUND")

   v=v+1 ; DIPRINT(I_0(:),"I_0 (par_sf)","I_0(col) = SCHISM_N2E_VAL(srad)")
   v=v+1 ; DIPRINT(par(:,col),"par","par(:,col) = I_0(col) * par_frac * EXP(-(Kw+localext)*1e-6*dz(:,col))")
   v=v+1 ; DIPRINT(nir(:,col),"nir","nir(:,col) = (par(:,col)/par_frac) * nir_frac")
   v=v+1 ; DIPRINT(uva(:,col),"uva","uva(:,col) = (par(:,col)/par_frac) * uva_frac")
   v=v+1 ; DIPRINT(uvb(:,col),"uvb","uvb(:,col) = (par(:,col)/par_frac) * uvb_frac")

   v=v+1 ; DIPRINT(tss(:,col),"tss","tss NOT FOUND");
   v=v+1 ; DIPRINT(ss1(:,col),"ss1","ss1 NOT FOUND");
   v=v+1 ; DIPRINT(ss2(:,col),"ss2","ss2 NOT FOUND");
   v=v+1 ; DIPRINT(ss3(:,col),"ss3","ss3 NOT FOUND");
   v=v+1 ; DIPRINT(ss4(:,col),"ss4","ss4 NOT FOUND");

   v=v+1 ; DIPRINT(air_pres(:),"air_pres","air_pres(col) = SCHISM_N2E_VAL(pr)")
   v=v+1 ; DIPRINT(air_temp(:),"air_temp","air_temp(col) = SCHISM_N2E_VAL(airt1)")
   v=v+1 ; DIPRINT(rain(:),"rain", "rain(col) = SCHISM_N2E_VAL(prec_rain)")
   v=v+1 ; DIPRINT(wind(:),"wind","wind(col) = sqrt(SCHISM_N2E_VAL(windx)**2 + SCHISM_N2E_VAL(windy)**2)")
   v=v+1 ; DIPRINT(humidity(:),"humidity","humidity(col) = SCHISM_N2E_VAL(shum1)")
   v=v+1 ; DIPRINT(evap(:),"evap","evap = SCHISM_N2E_VAL(fluxevp)")

   v=v+1 ; DIPRINT(col_depth(:),"col_depth","col_depth calculated from dpe and ze")
!  v=v+1 ; DIPRINT(col_area(:),"col_area","area_(nvrt)")

   v=v+1 ; DIPRINT(layer_stress(:),"layer_stress","layer_stress = SCHISM_N2E_VALS(tau_bot_node,1) ? bottom_stress?")
   v=v+1 ; DIPRINT(longwave(:),"longwave","longwave = SCHISM_N2E_VAL(hradd)")

   v=v+1 ; DIPRINT(ustar_bed(:,col),"ustar_bed","ustar_bed NOT FOUND");
   v=v+1 ; DIPRINT(wv_uorb(:,col),"wv_uorb","wv_orb NOT FOUND");
   v=v+1 ; DIPRINT(wv_t(:,col),"wv_t","wv_t NOT FOUND");
 ! print*," Feedback vars:"
 ! v=v+1 ; DIPRINT(biodrag(:,col),"biodrag"," feedback")
 ! v=v+1 ; DIPRINT(bioextc(:,col),"bioextc"," feedback")
 ! v=v+1 ; DIPRINT(solarshade(col),"solarshade"," feedback")
 ! v=v+1 ; DIPRINT(windshade(col),"windshade"," feedback")
 ! v=v+1 ; DIPRINT(bathy(:),"bathy"," feedback")
 ! v=v+1 ; DIPRINT(rainloss(:),"rainloss"," feedback")
#endif

!#    env(col)%sed_zones     => sed_zones(:,col)  !# internal to AED really
!#    env(col)%sed_zone      => sed_zone(col)     !# internal to AED really
   print*, "------------ done with msg = ",msg

END SUBROUTINE debug_max_min
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#endif


!###############################################################################
SUBROUTINE aed_set_up_schism_env(xlon_el, ylat_el)
!-------------------------------------------------------------------------------
!ARGUMENTS
   real(rkind),target :: xlon_el(:),ylat_el(:)
!
!LOCALS
   INTEGER :: status, col, lev

   TYPE(aed_env_t) :: env(n_cols)
!
!-------------------------------------------------------------------------------
!BEGIN
   TPRINT "aed_set_up_schism_env"
   IF ( .NOT. inited ) RETURN
   IF ( n_cols <= 0 ) RETURN ! Nothing to do

   !# Allocate arrays for local copies of stuff thats not directly provided by schism
   ALLOCATE(lheights(n_layers,n_cols)) ; lheights = zero_
   ALLOCATE(depth(n_layers,n_cols))    ; depth = zero_
   ALLOCATE(area_(n_layers,n_cols))    ; area_ = zero_

   ALLOCATE(dz(n_layers,n_cols))    ; dz = zero_
   ALLOCATE(col_depth(n_cols))      ; col_depth = zero_

   temp => tr_el(1,:,:)  ! temp from schism
   salt => tr_el(2,:,:)  ! salinity from schism
   rho  => erho(:,:)     ! effective density from schism

   ALLOCATE(active(n_cols))  ! => idry_e
   ALLOCATE(botidx(n_cols))  ! => kbe + 1

   !# Allocate array for photosynthetically active radiation (PAR).
   !# This will be calculated internally during each time step.
   ALLOCATE(par(n_layers, n_cols))  ; par = zero_
   ALLOCATE(nir(n_layers, n_cols))  ; nir = zero_
   ALLOCATE(uva(n_layers, n_cols))  ; uva = zero_
   ALLOCATE(uvb(n_layers, n_cols))  ; uvb = zero_
   ALLOCATE(extc(n_layers,n_cols))  ; extc = zero_

   !# allocate arrays for surface data
   ALLOCATE(rad(n_layers,n_cols))   ; rad = zero_

   ALLOCATE(cvel(n_layers,n_cols))  ; cvel = zero_

   !# Allocate array for local pressure.
   !# This will be calculated [approximated] from layer depths internally
   !# during each time step.
   ALLOCATE(pres(n_layers,n_cols))  ; pres = zero_

   !# allocate arrays for Met data
   ALLOCATE(rain(n_cols))       ; rain = zero_
   ALLOCATE(wind(n_cols))       ; wind = zero_
   ALLOCATE(I_0(n_cols))        ; I_0 = zero_
   ALLOCATE(air_temp(n_cols))   ; air_temp = zero_
   ALLOCATE(air_pres(n_cols))   ; air_pres = zero_
   ALLOCATE(humidity(n_cols))   ; humidity = zero_

   ALLOCATE(matz(n_cols))       ; matz = zero_

   ALLOCATE(tss(n_layers,n_cols))   ; tss = zero_
   ALLOCATE(ss1(n_layers,n_cols))   ; ss1 = zero_
   ALLOCATE(ss2(n_layers,n_cols))   ; ss2 = zero_
   ALLOCATE(ss3(n_layers,n_cols))   ; ss3 = zero_
   ALLOCATE(ss4(n_layers,n_cols))   ; ss4 = zero_

   ALLOCATE(ustar_bed(n_layers,n_cols)) ; ustar_bed = zero_
   ALLOCATE(wv_uorb(n_layers,n_cols))   ; wv_uorb = zero_
   ALLOCATE(wv_t(n_layers,n_cols))      ; wv_t = zero_

   ALLOCATE(sed_zones(n_layers,n_cols)) ; sed_zones = zero_
   ALLOCATE(sed_zone(n_cols))           ; sed_zone = zero_

   ALLOCATE(layer_stress(n_cols))       ; layer_stress = zero_
   ALLOCATE(evap(n_cols))               ; evap = zero_
   ALLOCATE(longwave(n_cols))           ; longwave = zero_

!  ALLOCATE(biodrag(n_layers,n_cols))   ; biodrag = zero_     !# feedback
!  ALLOCATE(bioextc(n_layers,n_cols))   ; bioextc = zero_     !# feedback
!  ALLOCATE(solarshade(n_cols))         ; solarshade = zero_  !# feedback
!  ALLOCATE(windshade(n_cols))          ; windshade = zero_   !# feedback
!  ALLOCATE(rainloss(n_cols))           ; rainloss = zero_    !# feedback
!  ALLOCATE(bathy(n_cols))              ; bathy = zero_       !# feedback

   !# fill the local arrays per column computed from node arrays
   CALL schism_to_aed_env

   timestep = dt

   DO col=1,n_cols
      env(col)%n_layers  =  n_layers
      env(col)%active    => active(col)
      env(col)%top_idx   => n_layers
      env(col)%bot_idx   => botidx(col)

      env(col)%yearday   => yearday
      env(col)%timestep  => timestep

      env(col)%longitude => xlon_el(col)
      env(col)%latitude  => ylat_el(col)

      !# These are locally allocated but we can compute them
      env(col)%height        => lheights(:,col) ! layer heights (calculated)
      env(col)%area          => area_(:,col)    ! layer areas (expanded from 2 to 3 D)
      env(col)%dz            => dz(:,col)       ! height diff (calculated)
      env(col)%depth         => depth(:,col)    ! layer depths (calculated)

      env(col)%col_depth     => col_depth(col)

      env(col)%pres          => pres(:,1)
      env(col)%rad           => rad(:,col)
      env(col)%extc          => extc(:,col)     ! locally computed

      !# These we can just point to
      env(col)%temp          => temp(:,col)  !# tr_el(1,:,col)  ! temp from schism
      env(col)%salt          => salt(:,col)  !# tr_el(2,:,col)  ! salinity from schism
      env(col)%rho           => rho(:,col)   !# erho(:,col)     ! effective density from schism

      env(col)%rain          => rain(col)

      env(col)%I_0           => I_0(col)
      env(col)%wind          => wind(col)
      env(col)%air_temp      => air_temp(col)
      env(col)%air_pres      => air_pres(col)
      env(col)%humidity      => humidity(col)
      env(col)%evap          => evap(col)
      env(col)%layer_stress  => layer_stress(col)
      env(col)%longwave      => longwave(col)

      env(col)%cvel          => cvel(:,col)

      !# These are yet to be found
      env(col)%tss           => tss(:,col)
      env(col)%ss1           => ss1(:,col)
      env(col)%ss2           => ss2(:,col)
      env(col)%ss3           => ss3(:,col)
      env(col)%ss4           => ss4(:,col)
      env(col)%ustar_bed     => ustar_bed(:,col)
      env(col)%wv_uorb       => wv_uorb(:,col)
      env(col)%wv_t          => wv_t(:,col)

      env(col)%sed_zones     => sed_zones(:,col)  !# internal to AED really
      env(col)%sed_zone      => sed_zone(col)     !# internal to AED really
      env(col)%mat_id        => matz(col)         !# internal to AED really

      !# these get computed from I_0 (par_sf)
      env(col)%par => par(:,col)
      env(col)%nir => nir(:,col)
      env(col)%uva => uva(:,col)
      env(col)%uvb => uvb(:,col)

      !# feedback data
      IF (ASSOCIATED(biodrag))    env(col)%biodrag       => biodrag(:,col)
      IF (ASSOCIATED(bioextc))    env(col)%bioextc       => bioextc(:,col)
      IF (ASSOCIATED(solarshade)) env(col)%solarshade    => solarshade(col)
      IF (ASSOCIATED(windshade))  env(col)%windshade     => windshade(col)
      IF (ASSOCIATED(bathy))      env(col)%bathy         => bathy(col)
      IF (ASSOCIATED(rainloss))   env(col)%rainloss      => rainloss(col)
   ENDDO

   CALL aed_set_model_env(env, n_cols, n_layers)

   DTPRINT "aed_set_up_schism_env done"
END SUBROUTINE aed_set_up_schism_env
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE schism_aed_init_models()
!-------------------------------------------------------------------------------
!ARGUMENTS
!
!LOCALS
   INTEGER :: col, istart, idx_s, idx_e
   INTEGER :: i, v
   TYPE(aed_variable_t),POINTER :: tv
!
!-------------------------------------------------------------------------------
!BEGIN
   TPRINT "schism_aed_init_models with ", ne, " columns each with ", nvrt, "layers"
   IF ( .NOT. inited ) RETURN
   IF ( ne <= 0 ) RETURN ! Nothing to do

   n_cols = ne        !# (or should it be nea is the larger so lets be safe)
   n_layers = nvrt    !#

   ALLOCATE(data(n_cols))
   ALLOCATE(cc_hz(n_vars_ben, n_cols))
   ALLOCATE(cc_diag(n_vars_diag, nvrt, n_cols))
   ALLOCATE(cc_diag_hz(n_vars_diag_sheet, n_cols))

!  n_zones = whatever

! no zones yet
!  IF (n_zones > 0) &
!     CALL aed_set_schism_zones(n_vars, n_vars_ben, n_vars_diag, n_vars_diag_sheet)

   !# Setup environmental variables
   CALL aed_set_up_schism_env(xlon_el, ylat_el)

   istart = irange_tr(1,AED_MODL_NO)

   !# sanity check
   IF ( irange_tr(2,AED_MODL_NO) - irange_tr(1,AED_MODL_NO) + 1 < n_vars) THEN
      print*,"istart = ",istart,"iend = ", irange_tr(2,AED_MODL_NO), " n_vars = ", n_vars
      stop
   ENDIF

   DO col=1,n_cols
      idx_s = istart ; idx_e = idx_s + n_vars - 1
      data(col)%cc => tr_el(idx_s:idx_e, :, col)

      data(col)%cc_hz => cc_hz(:, col)

      data(col)%cc_diag => cc_diag(:,:, col)
      data(col)%cc_diag_hz => cc_diag_hz(:, col)
   ENDDO

   CALL aed_set_model_data(data, n_cols, n_layers)

   CALL aed_check_model_setup

   !# schism_init wants init values on the nodes
   v = 0 ; idx_s = istart - 1
   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( .NOT. tv%sheet .AND. ( tv%var_type == V_STATE ) ) THEN
            v = v + 1
            tr_nd(idx_s+v, :, :) = tv%initial
         ENDIF
      ENDIF
   ENDDO

#if DEBUG
   IF (display_minmax) CALL debug_max_min("schism_aed_init_models at step 0")
#endif
   TPRINT 'done schism_aed_init_models'
END SUBROUTINE schism_aed_init_models
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

!# end of init
!#            -----------------------------------------------------
!# start of step

!###############################################################################
SUBROUTINE schism_aed_do(stepno)
!-------------------------------------------------------------------------------
!ARGUMENTS
   INTEGER, INTENT(in) :: stepno
!
!LOCALS
   INTEGER :: lev, col, idx_s, v, i, k
   AED_REAL :: surf
   TYPE(aed_variable_t),POINTER :: tv
!
   REAL :: now, ltr
!
!-------------------------------------------------------------------------------
!BEGIN
   IF ( .NOT. inited ) RETURN
   IF ( n_cols <= 0 ) RETURN ! Nothing to do

   CALL CPU_TIME(now)
   IF ( MOD(stepno, debug_interval) == 1 ) THEN
      print '("schism_aed_do[",i0, "] step ", i8)', myrank, stepno
#if DEBUG
      IF (display_minmax) CALL debug_max_min("schism_aed_do")
#endif
   ENDIF
   prev = now

   IF (depress_clutch2) RETURN

   !# update our copies of the geometry and environment
   CALL schism_to_aed_env()

! not yet
!  doMobilityP => doMobilityF
!  CALL aed_set_mobility(doMobilityP)

   IF (depress_clutch) RETURN

   CALL aed_run_model(n_cols, n_layers, .TRUE.)

   CALL CPU_TIME(ltr)
   IF ( MOD(stepno, debug_interval) == 1 ) &
      print '("schism_aed_do[",i0,"] step ", i8, " done in : ",f12.3," seconds")', myrank, stepno, ltr-now
   time_aed_do = time_aed_do + ltr-now
END SUBROUTINE schism_aed_do
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

!# end of step
!#                   ------------------------------
!# start of io

!###############################################################################
SUBROUTINE schism_aed_create_output()
!-------------------------------------------------------------------------------
!ARGUMENTS
!
!LOCALS
   CHARACTER(LEN=6) :: rank
   INTEGER :: time_dim, colm_dim, layr_dim, zone_dim=-1
   INTEGER :: time_id
!
!-------------------------------------------------------------------------------
!BEGIN
   TPRINT "schism_aed_create_output"
   IF ( .NOT. inited ) RETURN
   IF ( n_cols <= 0 ) RETURN ! Nothing to do

   write(rank,fmt='(I0.6)') myrank
   CALL check_nc_error( nf90_create(                                           &
                 TRIM(out_dir)//TRIM(output_file)//'_'//TRIM(rank)//'.nc' ,    &
                                        nf90_hdf5, ncid), 'create output file' )

!  CALL check_nc_error( nf90_create(TRIM(out_dir)//TRIM(output_file)//'.nc' ,  &
!                                       nf90_hdf5, ncid), 'create output file' )

   write(rank,fmt='(I0.6)') myrank
   CALL check_nc_error( nf90_def_dim(ncid, 'time',   nf90_unlimited, time_dim) )
   CALL check_nc_error( nf90_def_dim(ncid, 'column', n_cols,         colm_dim) )
   CALL check_nc_error( nf90_def_dim(ncid, 'layer',  n_layers,       layr_dim) )

! not yet
!  CALL check_nc_error( nf90_def_dim(ncid, 'zone',   n_zones,        zone_dim) )

! print*,"time_dim=",time_dim
! print*,"colm_dim=",colm_dim
! print*,"layr_dim=",layr_dim

   CALL check_nc_error( nf90_def_var(ncid, 'time', nf90_double, (/ time_dim /), time_id) )
   CALL check_nc_error( nf90_put_att(ncid, time_id, 'units', 'seconds') )

   CALL schism_aed_create_aed_output(ncid, colm_dim, layr_dim, zone_dim, time_dim)
   TPRINT "schism_aed_create_output done"
END SUBROUTINE schism_aed_create_output
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE schism_aed_name_2D_scribes(out_name, iout_23d, counter_out_name, ncount_2delem)
!-------------------------------------------------------------------------------
!ARGUMENTS
   CHARACTER(*),INTENT(inout) :: out_name(:)
   INTEGER,INTENT(inout) :: iout_23d(:)
   INTEGER,INTENT(inout) :: counter_out_name, ncount_2delem
!
!LOCALS
   INTEGER :: i, ret
   TYPE(aed_variable_t),POINTER :: tv
!
!-------------------------------------------------------------------------------
!BEGIN
   TPRINT "schism_aed_name_2D_scribes"
   ret = 0
   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( tv%sheet .AND. tv%var_type == V_STATE ) THEN
            ret = ret + 1
            ncount_2delem = ncount_2delem + 1
            counter_out_name = counter_out_name + 1

            iout_23d(counter_out_name) = 4
            out_name(counter_out_name) = TRIM(tv%name)
         ENDIF
      ENDIF
   ENDDO
   TPRINT "done schism_aed_name_2D_scribes"
END SUBROUTINE schism_aed_name_2D_scribes
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
FUNCTION schism_aed_name_3D_scribes(out_name, iout_23d, counter_out_name, ncount_3dnode) RESULT(ret)
!-------------------------------------------------------------------------------
!ARGUMENTS
   CHARACTER(*),INTENT(inout) :: out_name(:)
   INTEGER,INTENT(inout) :: iout_23d(:)
   INTEGER,INTENT(inout) :: counter_out_name, ncount_3dnode
!
!LOCALS
   INTEGER :: i, ret
   TYPE(aed_variable_t),POINTER :: tv
!
!-------------------------------------------------------------------------------
!BEGIN
   TPRINT "schism_aed_name_3D_scribes"
   ret = 0
   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( .NOT. tv%sheet .AND. tv%var_type == V_STATE ) THEN
            ret = ret + 1
            ncount_3dnode = ncount_3dnode + 1
            counter_out_name = counter_out_name + 1

            iout_23d(counter_out_name) = 2
            out_name(counter_out_name) = TRIM(tv%name)
         ENDIF
      ENDIF
   ENDDO
   TPRINT "done schism_aed_name_3D_scribes"
END FUNCTION schism_aed_name_3D_scribes
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE schism_aed_write_output(time)
!-------------------------------------------------------------------------------
!ARGUMENTS
   AED_REAL,INTENT(in) :: time
!
!LOCALS
   INTEGER :: time_id, tvr_id, status
   TYPE(aed_variable_t),POINTER :: tv

   INTEGER :: start(4), count(4);
   INTEGER :: iret

   INTEGER :: idx_s, idx_e
   INTEGER  :: i, j, v, d, sv, sd
   LOGICAL :: last = .FALSE.

   REAL :: now, ltr
!
!-------------------------------------------------------------------------------
!BEGIN
   IF ( .NOT. inited ) RETURN
   IF ( n_cols <= 0 ) RETURN ! Nothing to do

   CALL CPU_TIME(now)
!  TPRINTF '("schism_aed_write_output[",i0,"]")', myrank

   ts_counter = ts_counter + 1

   CALL check_nc_error( nf90_inq_varid(ncid, 'time', time_id) )
   CALL check_nc_error( nf90_put_var(ncid, time_id, (/ time /),                &
                                       start=(/ ts_counter /), count=(/ 1 /) ) )

   idx_s = irange_tr(1,AED_MODL_NO) - 1
   idx_e = idx_s + n_vars - 1

   start(1) = 1;  count(1) = n_cols
   v = 0; d = 0; sv = 0; sd = 0

   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         iret = nf90_noerr
         IF ( tv%sheet ) THEN
            start(2) = ts_counter; count(2) = 1
            IF ( tv%var_type == V_DIAGNOSTIC ) THEN
               !# Process and store diagnostic variables.
               sd = sd + 1
               !# Process and store diagnostic variables defined on horizontal slices of the domain.
               iret = nf90_put_var(ncid, externalid(i), cc_diag_hz(sd,:), start, count)
            ELSEIF ( tv%var_type == V_STATE ) THEN  ! not diag
               sv = sv + 1
               !# Store benthic biogeochemical state variables.
               start(2) = sv
               iret = nf90_put_var(ncid, externalid(i), cc_hz(sv,:), start, count)
            ENDIF
         ELSE !# not sheet
            start(2) = 1;           count(2) = n_layers
            start(3) = ts_counter;  count(3) = 1
            IF ( tv%var_type == V_DIAGNOSTIC ) THEN
               d = d + 1
               !# Store diagnostic variable values defined on the full domain.
               start(3) = d
               iret = nf90_put_var(ncid, externalid(i), cc_diag(d, :, :), start, count)
            ELSEIF ( tv%var_type == V_STATE ) THEN  ! not diag
               v = v + 1
               !# Store pelagic biogeochemical state variables.
               start(3) = v
               iret = nf90_put_var(ncid, externalid(i), tr_el(idx_s+v, :, :), start, count)
            ENDIF
         ENDIF
         IF ( iret /= nf90_noerr ) CALL check_nc_error_x(iret, ncid, externalid(i))
      ENDIF
   ENDDO

   status = nf90_sync(ncid)

   CALL CPU_TIME(ltr)
   time_aed_wrt = time_aed_wrt + ltr-now

!  TPRINTF '("schism_aed_write_output[",i0,"] done in ",f12.3," seconds.")', myrank, ltr-now
END SUBROUTINE schism_aed_write_output
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#ifdef OLDIO
!###############################################################################
SUBROUTINE aed_writeout(id_out_var, noutput, npa, tr_nd)
!-------------------------------------------------------------------------------
   USE schism_io, ONLY: writeout_nc
!-------------------------------------------------------------------------------
!ARGUMENTS
   INTEGER,DIMENSION(:),INTENT(inout)   :: id_out_var
   INTEGER,INTENT(inout)                :: noutput
   INTEGER,INTENT(in)                   :: npa
   AED_REAL,DIMENSION(:,:,:),INTENT(in) :: tr_nd
!
!LOCALS
   TYPE(aed_variable_t),POINTER :: tv
   INTEGER :: i, istart, v, sv

   REAL :: now, ltr
!
!-------------------------------------------------------------------------------
!BEGIN
   TPRINT "aed_writeout"
   CALL CPU_TIME(now)

   istart = irange_tr(1,AED_MODL_NO)
   v = 0; sv = 0

   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( tv%sheet ) THEN
            IF ( tv%var_type == V_STATE ) THEN  ! not diag
               sv = sv + 1
               CALL writeout_nc(id_out_var(noutput+sv+4),TRIM(tv%name),4,1,n_cols,cc_hz(sv,:))
               noutput = noutput + 1
            ENDIF
         ELSE ! not sheet
            IF ( tv%var_type == V_STATE ) THEN  ! not diag
               v = v + 1
               CALL writeout_nc(id_out_var(noutput+v+4),TRIM(tv%name),2,nvrt,npa,tr_nd(istart+v-1,:,:))
               noutput = noutput + 1
            ENDIF
         ENDIF
      ENDIF
   ENDDO

   CALL CPU_TIME(ltr)
   time_aed_wrt = time_aed_wrt + ltr-now

   TPRINT "done aed_writeout"
END SUBROUTINE aed_writeout
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#endif

!###############################################################################
INTEGER FUNCTION new_nc_variable(ncid, name, data_type, ndim, dims)
!-------------------------------------------------------------------------------
!ARGUMENTS
   INTEGER,INTENT(in)      :: ncid
   CHARACTER(*),INTENT(in) :: name
   INTEGER,INTENT(in)      :: data_type, ndim
   INTEGER,DIMENSION(:),INTENT(in) :: dims
!
!LOCALS
   INTEGER id;
!
!-------------------------------------------------------------------------------
!BEGIN
   IF (ncid == -1) THEN
      new_nc_variable = -1;
      RETURN
   ENDIF
   CALL check_nc_error( nf90_def_var(ncid, name, data_type, dims, id) );
   new_nc_variable = id;
END FUNCTION new_nc_variable
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE set_nc_attributes(ncid, id, units, long_name, FillValue)
!-------------------------------------------------------------------------------
!ARGUMENTS
   INTEGER,INTENT(in)   :: ncid, id
   CHARACTER(*),INTENT(in) :: units
   CHARACTER(*),INTENT(in),OPTIONAL :: long_name
   AED_REAL,INTENT(in)  :: FillValue
!
!LOCALS
   INTEGER :: status
!
!-------------------------------------------------------------------------------
!BEGIN
   IF (ncid == -1) RETURN;
   status = nf90_put_att(ncid, id, "units", units);
   IF ( PRESENT(long_name) ) THEN
      status = nf90_put_att(ncid, id, "long_name", long_name);
   ENDIF
   status = nf90_put_att(ncid, id, "_FillValue", FillValue);
END SUBROUTINE set_nc_attributes
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE check_nc_error(status, where)
!-------------------------------------------------------------------------------
!ARGUMENTS
   INTEGER,INTENT(in)    :: status
   CHARACTER(*),OPTIONAL :: where
!
!LOCALS
   CHARACTER(256) :: w = 'Unknown NetCDF error'
!
!-------------------------------------------------------------------------------
!BEGIN
   IF (status /= nf90_noerr) THEN
      IF ( PRESENT(where) ) w = where
      CALL parallel_abort('schism-aed: '//trim(w)//' '//trim(nf90_strerror(status)))
   ENDIF
END SUBROUTINE check_nc_error
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE check_nc_error_x(err, ncid, id)
!-------------------------------------------------------------------------------
!ARGUMENTS
   INTEGER :: err, ncid, id
!     
!LOCALS
   CHARACTER(NF90_MAX_NAME) :: name
   INTEGER :: status
!
!-------------------------------------------------------------------------------
!BEGIN
    status = nf90_inquire_variable(ncid, id, name=name)
    CALL parallel_abort("Error : " // nf90_strerror(err) // " on variable " // name)
END SUBROUTINE check_nc_error_x
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


!###############################################################################
SUBROUTINE schism_aed_create_aed_output(ncid, colm_dim, layr_dim, zone_dim, time_dim)
!-------------------------------------------------------------------------------
!  Initialize the output by defining biogeochemical variables.
!-------------------------------------------------------------------------------
!
!ARGUMENTS
   INTEGER,INTENT(in) :: ncid, colm_dim, layr_dim, zone_dim, time_dim
!
!LOCALS
   INTEGER :: i
   INTEGER :: dims(4)

   TYPE(aed_variable_t),POINTER :: tv
!
!-------------------------------------------------------------------------------
!BEGIN
   IF (.NOT.ALLOCATED(externalid)) ALLOCATE(externalid(n_aed_vars)) 

   !# Set up dimension indices for 3D (+ time) variables (longitude,latitude,depth,time).
   dims(1) = colm_dim ; dims(2) = layr_dim ; dims(3) = time_dim

   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( .NOT. tv%sheet .AND. tv%var_type == V_STATE ) THEN
            !# only for state vars that are not sheet
            externalid(i) = new_nc_variable(ncid, TRIM(tv%name), nf90_double, 3, dims(1:3))
            CALL set_nc_attributes(ncid, externalid(i), TRIM(tv%units), TRIM(tv%longname), NC_FILLER)
         ENDIF
      ENDIF
   ENDDO

   !# Set up dimension indices for 3D (+ time) diagnostic variables (longitude,latitude,depth,time).
   dims(1) = colm_dim ; dims(2) = layr_dim ; dims(3) = time_dim

   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( .NOT. tv%sheet .AND. tv%var_type == V_DIAGNOSTIC ) THEN
            !# only for diag vars that are not sheet
            externalid(i) = new_nc_variable(ncid, TRIM(tv%name), nf90_double, 3, dims(1:3))
            CALL set_nc_attributes(ncid, externalid(i), TRIM(tv%units), TRIM(tv%longname), NC_FILLER)
         ENDIF
      ENDIF
   ENDDO

   !# Set up dimension indices for 2D (+ time) variables (longitude,latitude,time).
   dims(1) = colm_dim ; dims(2) = time_dim

   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( tv%sheet .AND. tv%var_type == V_STATE ) THEN
            !# only for state sheet vars
            externalid(i) = new_nc_variable(ncid, TRIM(tv%name), nf90_double, 2, dims(1:2))
            CALL set_nc_attributes(ncid, externalid(i), TRIM(tv%units), TRIM(tv%longname), NC_FILLER)
         ENDIF
      ENDIF
   ENDDO

   !# Set up dimension indices for 2D (+ time) diagnostic variables (longitude,latitude,time).
   dims(1) = colm_dim ; dims(2) = time_dim

   DO i=1,n_aed_vars
      IF ( aed_get_var(i, tv) ) THEN
         IF ( tv%sheet .AND. tv%var_type == V_DIAGNOSTIC ) THEN
            !# only for diag sheet vars
            externalid(i) = new_nc_variable(ncid, TRIM(tv%name), nf90_double, 2, dims(1:2))
            CALL set_nc_attributes(ncid, externalid(i), TRIM(tv%units), TRIM(tv%longname), NC_FILLER)
         ENDIF
      ENDIF
   ENDDO
END SUBROUTINE schism_aed_create_aed_output
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

!# end of IO
!#                   ------------------------------
!# start of finalise


!###############################################################################
SUBROUTINE schism_aed_finalise()
!-------------------------------------------------------------------------------
!ARGUMENTS
!
!LOCALS
   REAL :: now
   INTEGER :: diff, hrs, mns, sec
!
!-------------------------------------------------------------------------------
!BEGIN
   print '("schism_aed_finalise[",i0,"]")', myrank !, ncid
   IF ( .NOT. inited ) RETURN

   IF ( ncid > 0 ) &
      CALL check_nc_error( nf90_close(ncid), "closing AED file" )

   CALL CPU_TIME(now)
!  print '("schism_aed_finalise[",i0,"] : ",f12.3," cpu seconds.")',myrank, now-start

!  IF ( myrank /= 0 ) RETURN

   diff = INT(now-start)
   hrs = diff / 3600
   mns = (diff - (hrs * 3600)) / 60
   sec = (diff - (hrs * 3600) - (mns * 60))
   print '("schism_aed_finalise[",i0,"] done", i4,":",i0.2,":",i0.2, " (",f10.3,")")', myrank, hrs,mns,sec,now-start

   diff = INT(time_aed_do)
   hrs = diff / 3600
   mns = (diff - (hrs * 3600)) / 60
   sec = (diff - (hrs * 3600) - (mns * 60))
   print '("   time in aed_do  [",i0,"] done", i4,":",i0.2,":",i0.2, " (",f10.3,")")', myrank, hrs,mns,sec,time_aed_do

   diff = INT(time_aed_wrt)
   hrs = diff / 3600
   mns = (diff - (hrs * 3600)) / 60
   sec = (diff - (hrs * 3600) - (mns * 60))
   print '("   time in aed_wrt [",i0,"] done", i4,":",i0.2,":",i0.2, " (",f10.3,")")', myrank, hrs,mns,sec,time_aed_wrt

END SUBROUTINE schism_aed_finalise
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

!# end of finalise


END MODULE schism_aed
