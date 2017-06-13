#include "fabm_driver.h"

!-----------------------------------------------------------------------
!BOP
!
! !MODULE: FABM model library
!
! !INTERFACE:
   module fabm_library
!
! !USES:
   use fabm_types, only: type_base_model_factory, type_base_model

   use fabm_builtin_models

   ! Auto-generated references to institute-specific modules with model libraries:
   use au_model_library
   use bb_model_library
   use examples_model_library
   use gotm_model_library
   use pclake_model_library
   use pml_model_library
   use niva_model_library
   use akvaplan_model_library

   ! Hard-coded references to modules of specific institutes and models:
   ! This is DEPRECATED - if institutes provide their own model library
   ! using recommended naming conventions (http://fabm.net/wiki), CMake
   ! will auto-generate the required code and insert it above.
   use aed_models
   use fabm_metu_mnemiopsis
   use fabm_klimacampus_phy_feedback
   use fabm_hzg_omexdia_p
   use fabm_msi_ergom1
   use iow_model_library

   implicit none

   private

   type,extends(type_base_model_factory) :: type_factory
      contains
      procedure :: create
      procedure :: initialize
   end type

   type (type_factory),save,target,public :: fabm_model_factory

!EOP
!-----------------------------------------------------------------------

contains

   subroutine initialize(self)
      class (type_factory), intent(inout) :: self

      ! Auto-generated registration of institute-specific model libraries:
      call self%add(au_model_factory,'au')
      call self%add(bb_model_factory,'bb')
      call self%add(examples_model_factory,'examples')
      call self%add(gotm_model_factory,'gotm')
      call self%add(pclake_model_factory,'pclake')
      call self%add(pml_model_factory,'pml')
      call self%add(niva_model_factory,'niva')
      call self%add(akvaplan_model_factory,'akvaplan')

      ! Manual registration of model libraries. This is DEPRECATED.
      ! If institutes provide their own model library using recommended
      ! naming conventions (http://fabm.net/wiki), CMake will auto-generate
      ! the required code and insert it above.
      call self%add(builtin_factory)
      call self%add(aed_model_factory)
      call self%add(iow_model_factory)

      ! Go through default initializaton steps.
      ! This also allows new added child model factories to initialize.
      call self%type_base_model_factory%initialize()
   end subroutine initialize

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Subroutine returning a specific biogeochemical model given a model name.
!
! !INTERFACE:
   subroutine create(self,name,model)
!
! !INPUT PARAMETERS:
      class (type_factory),intent(in) :: self
      character(*),        intent(in) :: name
      class (type_base_model),pointer :: model
!
!EOP
!-----------------------------------------------------------------------
!BOC
      nullify(model)

      ! Manual references to individual models. This is DEPRECATED, and unnecessary
      ! if institutes provide their own model library using recommended
      ! naming conventions (http://fabm.net/wiki).
      select case (name)
         case ('metu_mnemiopsis');           allocate(type_metu_mnemiopsis::model)
         case ('klimacampus_phy_feedback');  allocate(type_klimacampus_phy_feedback::model)
         case ('hzg_omexdia_p');             allocate(type_hzg_omexdia_p::model)
         case ('msi_ergom1');                allocate(type_msi_ergom1::model)
         case default
            call self%type_base_model_factory%create(name,model)
      end select

      ! Store name that was used to create this model, so we can re-create it in the future.
      if (associated(model)) model%type_name = name
   end subroutine create
!EOC

!-----------------------------------------------------------------------

   end module fabm_library

!-----------------------------------------------------------------------
! Copyright by the FABM team under the GNU Public License - www.gnu.org
!-----------------------------------------------------------------------
