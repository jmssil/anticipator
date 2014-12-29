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

;; create Anticipator form
(procedure
 (anticipatorForm)

 ;; create widgets
 libName = (hiCreateStringField
	    ?name 'libName
	    ?prompt "Library"
	    ?callback "(ddsUpdateSyncWithForm)"
	    )
 cellName = (hiCreateStringField
	     ?name 'cellName
	     ?prompt "Cell"
	     ?callback "(ddsUpdateSyncWithForm)"
	     )
 viewName = (hiCreateStringField
	     ?name 'viewName
	     ?prompt "View"
	     ?callback "(ddsUpdateSyncWithForm)"
	     )
 browser = (hiCreateButton
	    ?name 'browse
	    ?buttonText "Browse"
	    ?callback "(ddsSyncWithForm anticipatorForm 'browse 'libName 'cellName 'viewName)"
	    )
 hier = (hiCreateBooleanButton
	 ?name 'hier
	 ?buttonText "Hierarchical netlisting"
	 ?value 't
	 )
 projDir = (hiCreateStringField
	    ?name 'projDir
	    ?prompt "Project directory"
	    ?value "./Sim"
	    )

 ;; create form
 (hiCreateAppForm
  ?name 'anticipatorForm
  ?formTitle "Anticipator"
  ?fields
  (list
   libName
   cellName
   viewName
   browser
   hier
   projDir
   )
  ?callback 'anticipatorCallback
  )
 )

;; define Anticipator form callback
(procedure 
 (anticipatorCallback form)

 projDir = form->projDir->value
 libName = form->libName->value
 cellName = form->cellName->value
 viewName = form->viewName->value
 simulator = "hspice"
 outputDir = (strcat projDir "/" cellName "/" simulator "/" viewName "/netlist")

 (simInitEnvWithArgs
  outputDir
  libName
  cellName
  viewName
  simulator
  t
  )

 ;; netlisting options
 simNetlistHier = form->hier->value
 simReNetlistAll = 't        
 hnlMaxNameLength = 128

 (netlist)
 )
