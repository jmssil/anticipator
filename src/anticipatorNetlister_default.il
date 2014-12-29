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

;; generic netlist procedure
(procedure
 (anticipatorNetlister_default hier inst cdf netlistProcedure)

 ;; hierarchical vs. flat netlisting
 (if hier then
   name = hnlCurrentInstName
   else
   name = inst->name
   )

 (printf "instance: %s\n" name)

 ;; get netlisting information
 param = cdf->parameters
 p_names = (mapcar 'stringToSymbol param~>name)
 p_values = param~>value
 parameters = (cons nil (mapcan 'list p_names p_values))
 si = cdf->simInfo->hspiceD

 ;; namePrefix
 (if si->namePrefix then
   line = (strcat si->namePrefix name)
   else
   line = (strcat "X" name)
   )

 ;; termOrder
 (foreach
  term1 
  (mapcar 'symbolToString si->termOrder)
  (foreach
   term2
   inst->instTerms
   (if (equal term2->name term1) then
     line = (strcat line " " term2->net->name)
     )
   )
  )

 ;; the rest of the line depends on the netlist procedure used
 (cond

  ;; empty (default) netlist procedure
  ((equal netlistProcedure nil)

   ;; check type of si->otherParameters
   (if (stringp si->otherParameters) then
     otherParameters = (readstring si->otherParameters)
     else
     otherParameters = si->otherParameters
     )

   ;; model
   (unless (member 'model otherParameters)
     (if model = (get parameters "model") then
	 line = (strcat line " " model)
	 else
	 (if modelname = (get parameters "modelname") then
	     line = (strcat line " " modelname)
	     else
	     (if modelName = (get parameters "modelName") then
		 line = (strcat line " " modelName)
		 else
		 (if componentName = si->componentName then
		     line = (strcat line " " componentName)
		     )
		 )
	     )
	 )
     )

   ;; otherParameters
   (foreach
    param
    otherParameters
    val = (get parameters param)
    (when val
      line = (strcat line " " val)
      )
    )

   ;; instParameters
   (foreach
    param1
    si->instParameters
    param2 = (get si->propMapping param1)
    (if param2 then
      val = (get parameters param2)
      else
      val = (get parameters param1)
      )
    val = parseAEL(inst val parameters)
    ;; (when (rexMatchp "pPar" val)
    ;;   aelEnv = (aelEnvCreate "f")
    ;;   lineage = (list inst inst->cellView)
    ;;   (aelSetLineage aelEnv lineage)
    ;;   val = (aelEnvInterpret aelEnv val)
    ;;   )
    (unless (or (equal val "") (equal val "nil"))
      val = (abHandleHspiceMathExpr val)
      line = (strcat line " " param1 "=" val)
      )
    )

   ;; stringParameters
   (when si->stringParameters
     line = (strcat line " " si->stringParameters)
     )

   ) ; end of empty (default) netlist procedure
  
  ;; hspiceDCompPrim
  ((equal netlistProcedure 'hspiceDCompPrim)
   ;; parameters
   (cond
    ((equal si->componentName 'res)
     line = (strcat line " " (get parameters "r"))
     )
    ((equal si->componentName 'cap)
     line = (strcat line " " (get parameters "c"))
     )
    ((equal si->componentName 'ind)
     line = (strcat line " " (get parameters "l"))
     )
    (t
     (printf "Anticipator: unknown component name \"%s\" from instance \"%s\"\n" si->componentName name)
     )
    )
   ) ; end of hspiceDCompPrim

  ;; hspiceDCompPrim_vdc
  ((equal netlistProcedure 'hspiceDCompPrim_vdc)
   ;; parameters
   line = (strcat line " dc=" (abHandleHspiceMathExpr (get parameters "vdc")))
   ) ; end of hspiceDCompPrim_vdc

  ;; hspiceDCompPrim_idc
  ((equal netlistProcedure 'hspiceDCompPrim_idc)
   ;; parameters
   line = (strcat line " dc=" (abHandleHspiceMathExpr (get parameters "idc")))
   ) ; end of hspiceDCompPrim_idc

  ;; hspiceDCompPrim_vsin
  ((equal netlistProcedure 'hspiceDCompPrim_vsin)
   ;; parameters
   line = (strcat
	   line 
	   " ac " 
	   (get parameters "acm") 
	   " " 
	   (get parameters "acp") 
	   " sin " 
	   (get parameters "vo") 
	   " " 
	   (get parameters "va") 
	   " " 
	   (get parameters "freq")
	   " "
	   (get parameters "td")
	   " "
	   (get parameters "theta")
	   " "
	   (get parameters "phi")
	   )
   ) ; end of hspiceDCompPrim_vsin

  ;; unrecognized netlist procedure
  (t
   (printf "Anticipator: netlist procedure \"%s\" not available (yet).\n" netlistProcedure)
   )
  )

 ;; print netlist line
 (if hier then
   hnlPrintString((strcat line "\n"))
   else
   fnlPrint(line)
   )
 )
