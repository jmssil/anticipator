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

;; define Anticipator netlister
(procedure
 (anticipatorNetlister)

 ;; check netlisting mode: hierarchic or flat?
 (cond
  ((fnlCurrentInst)
   inst = fnlCurrentInst()
   hier = nil
   )
  (hnlCurrentInst
   inst = hnlCurrentInst
   hier = t
   )
  (t
   error("Anticipator: cannot devise netlisting mode.")
   )
  )

 ;; get netlisting information and invoke netlister
 cdf = (cdfGetInstCDF inst)
 si = cdf->simInfo->hspiceD
 netlistProcedure = si->netlistProcedure
 (anticipatorNetlister_default hier inst cdf netlistProcedure)
 )


;; replace iPar's
(procedure
 (parseAEL inst expr parameters)

 (rexCompile "iPar(\"\\([a-zA-Z]+\\)\")")
 (while (rexExecute expr)
   prop = (rexSubstitute "\\1")
   value = (dbGetPropByName inst prop)->value
   (when (equal value nil)
     value = (get parameters prop)
     )
   expr = (rexReplace expr value 1)
   )
 expr
 )


;; check if the argument is an expression
(procedure
 (parseExpr expr)
 (if (equal (aelEngNotation expr) "NaN") then
   (strcat "'" expr "'")
   else
   (sprintf nil "%L" (evalstring expr))
   )
 )


;; http://www.cadence.com/Community/forums/p/22778/1312009.aspx
procedure( abHandleHspiceMathExpr(exprValue)
    let( (found env compExpr result newValue)
        cond(
            (numberp(exprValue) exprValue)
            (blankstrp(exprValue) exprValue)
            (stringp(exprValue)
                (cond
                    ((newValue=aelEngNotation(exprValue))&&!isNaN(atof(newValue)) newValue)
                    (!(env = aelEnvCreate("os" t nil)) 
                        warn("An environment to evaluate an AEL expression %L cannot be created.\n" exprValue)
                    ) 
                    (!(compExpr = aelEnvCompile(env exprValue)) 
                        warn("The AEL expression %L cannot be compiled.\n" exprValue)
                    ) 
                    (!(result = aelEnvExecute(compExpr)) 
                        warn("The AEL expression %L cannot be executed.\n" exprValue) 
                        aelEnvFreeCompExpr(compExpr)
                    ) 
                    (t 
                        exprValue = result 
                        aelEnvFreeCompExpr(compExpr)
                    )
                )
                found = aelNumber(exprValue) || rexMatchp("^[a-zA-Z_]+[a-zA-Z0-9_\\.]*$" exprValue)
                unless(found 
                    sprintf(exprValue "%c%s%c" 
                        '\' exprValue 
                        '\'
                    )
                )
                exprValue
            )
        )
    )
)
