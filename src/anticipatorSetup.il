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

;; create Anticipator Setup form
(procedure
 (anticipatorSetupForm)
 
 ;; create widgets
 libName = (hiCreateStringField
	    ?name 'libName
	    ?prompt "Library"
	    ?callback "(ddsUpdateSyncWithForm)"
	    )
 cellName = (hiCreateStringField
	     ?name 'cellName
	     ?prompt "Cell (empty means all)"
	     ?callback "(ddsUpdateSyncWithForm)"
	     )
 overwrite = (hiCreateBooleanButton
	      ?name 'overwrite
	      ?buttonText "Overwrite \"hspice\" views"
	      )
 browse = (hiCreateButton
	   ?name 'browse
	   ?buttonText "Browse"
	   ?callback "(ddsSyncWithForm anticipatorSetupForm 'browse 'libName 'cellName)"
	   )

 ;; create form
 (hiCreateAppForm
  ?name 'anticipatorSetupForm
  ?formTitle "Anticipator Setup"
  ?fields
  (list
   libName
   cellName
   browse
   overwrite
   )
  ?callback 'anticipatorSetupCallback
  )
 )

;; define Anticipator Setup form callback
(procedure
 (anticipatorSetupCallback form)

 ;; get form fields
 libName = form->libName->value
 cellName = form->cellName->value
 overwrite = form->overwrite->value     

 ;; check libName field
 (if (equal libName "") then
   (printf "Anticipator: Please fill-in library name.")
   else
   ;; check cellName field
   (if (equal cellName "") then
     cells = ddGetObj(libName)->cells
     else
     cells = (list (ddGetObj libName cellName))
     )
   ;; process all cells
   (foreach
    cell
    cells
    (printf "cell: %s\n" cell->name)
    (printf "  views: %L\n" cell->views~>name)
    ;; check for "hspiceD" view
    (foreach
     view
     cell->views
     (when
	 (equal view->name "hspiceD")
       (when overwrite
	 cv = (ddGetObj libName cell->name "hspice")
	 (when cv
	   (ddDeleteObj cv)
	   )
	 )
       ;; copy "hspiceD" view to "hspice" view
       (dbCopyCellView 
	(dbOpenCellViewByType libName cell->name view->name)
	libName
	cell->name
	"hspice"
	nil
	nil
	overwrite
	)
       ;; add required properties
       cv = (dbOpenCellViewByType libName cell->name "hspice")
       (when overwrite
	 (dbDeletePropByName cv "hnlHspiceFormatInst")
	 (dbDeletePropByName cv "hnlHspiceParamList")
	 (dbDeletePropByName cv "NLPElementPostamble")
	 )
       (dbCreateProp
	cv
	"hnlHspiceFormatInst"
	"string"
	"(anticipatorNetlister)"
	)
       (dbCreateProp
	cv
	"hnlHspiceParamList"
	"string"
	""
	)
       (dbCreateProp
	cv
	"NLPElementPostamble"
	"ilExpr"
	"(anticipatorNetlister)"
	)
       (dbSave cv)
       (dbClose cv)
       )
     )
    )
   )
 )
