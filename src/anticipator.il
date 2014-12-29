;; Copyright 2012-2014 João M. S. Silva

;; This file is part of Anticipator.

;; Anticipator is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation, either version 3 of the License,
;; or (at your option) any later version.

;; Anticipator is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Anticipator.  If not, see
;; <http://www.gnu.org/licenses/>.

;; load Anticipator files
(procedure
 (loadAnticipatorFiles)
 anticipatorPrefix = (getShellEnvVar "ANTICIPATOR")
 (load (strcat anticipatorPrefix "/src/anticipatorSetup.il"))
 (load (strcat anticipatorPrefix "/src/anticipatorForm.il"))
 (load (strcat anticipatorPrefix "/src/anticipatorNetlister.il"))
 (load (strcat anticipatorPrefix "/src/anticipatorNetlister_default.il"))
 )
(loadAnticipatorFiles)

;; create Anticipator Setup form
(anticipatorSetupForm)

;; create Anticipator Setup menu entry
anticipatorSetupMenuItem = (hiCreateMenuItem
			    ?name 'anticipatorSetupMenuItem
			    ?itemText "Anticipator Setup"
			    ?callback "(hiDisplayForm anticipatorSetupForm)"
			    ) 

;; create Anticipator form
(anticipatorForm)

;; create Anticipator menu entry
anticipatorMenuItem = (hiCreateMenuItem
		       ?name 'anticipatorMenuItem
		       ?itemText "Anticipator"
		       ?callback "(hiDisplayForm anticipatorForm)"
		       ) 

;; create menu
anticipatorMenu = (hiCreatePulldownMenu
		   'anticipatorMenu
		   "Anticipator"
		   (list anticipatorSetupMenuItem anticipatorMenuItem)
		   )

;; add menu to toolbar
(procedure 
 (anticipator)
 (hiInsertBannerMenu
  (window 1)
  anticipatorMenu
  (length (hiGetBannerMenus (window 1))) + 1
  )
 )
