open Cil
open Printf

module L = List

(* convert cil.typ to SMTLIB string*)
let typename_as_string = function
    Cil.TVoid _ -> "unit"
  | Cil.TInt _ -> "Int"
  | Cil.TFloat _ -> "Real"
  | Cil.TPtr _ -> "pointer"
  | Cil.TArray _ -> "array"
  | Cil.TFun _ -> "function"
  | Cil.TNamed _ -> "named-something"
  | Cil.TComp _ -> "composite"
  | Cil.TEnum _ -> "enumeration"
  | Cil.TBuiltin_va_list _ -> "builtin-variable-argument-list"

 
let parameterTypeList (parameter_list: varinfo list) : Cil.typ list = 
	L.map(fun formal -> formal.vtype) parameter_list

let parameterNameList (parameter_list: varinfo list) : string list = 
	L.map(fun formal -> formal.vname) parameter_list

let returnType (t : Cil.typ) : Cil.typ option = 
	match t with 
	| TFun (t,_, _,_) -> Some t
	| _ -> None

(* the return type of the function with given name if it exists *)
let funcReturnType (f:file) (name:string) : Cil.typ option =
  let rec search glist =
    match glist with
    | GFun (func,_) :: rest when func.svar.vname = name
                              && isFunctionType func.svar.vtype ->
      returnType func.svar.vtype 
    | _ :: rest -> search rest
    | [] -> None
  in search f.globals

(* a list of the parameter names of the function with given name if exists *)
let funcParameterNames (f:file) (name:string) : string list option =
  let rec search glist =
    match glist with
    | GFun (func,_) :: rest when func.svar.vname = name
                              && isFunctionType func.svar.vtype ->
      Some (parameterNameList func.sformals) 
    | _ :: rest -> search rest
    | [] -> None
  in search f.globals

(* a list of the parameter types of the function with given name if exists *)
let funcParameterTypes (f:file) (name:string) : Cil.typ list option =
  let rec search glist =
    match glist with
    | GFun (func,_) :: rest when func.svar.vname = name
                              && isFunctionType func.svar.vtype ->
      Some (parameterTypeList func.sformals) 
    | _ :: rest -> search rest
    | [] -> None
  in search f.globals

let itemsOnly (items: 'a list option) : 'a list = 
	match items with
	| Some l -> l 
	| None -> []

(* Includes dummy case of None which is never considered *)
let itemOnly (item: Cil.typ option) : Cil.typ = 
	match item with
	| Some x -> x
	| _ -> Cil.TInt(IInt, [])

(* from: https://www.matt-mcdonnell.com/code/code_ocaml/ocaml_fold/ocaml_fold.html *)
(* Zip two lists (possibly unequal lengths) into a tuple *)
let rec zip lst1 lst2 = match lst1,lst2 with
  | [],_ -> []
  | _, []-> []
  | (x::xs),(y::ys) -> (x,y) :: (zip xs ys);;

(* Test *)

(* Parse file *)
let filename = Sys.argv.(1);;
let name = Sys.argv.(2);;
let parsed_file = Frontc.parse filename ();;

(* Print function return type *)

let rt = funcReturnType parsed_file name;;
let rti = itemOnly rt;;
let rtip = L.iter (Printf.printf "%s\n") [(typename_as_string rti)];;

(* Parameter names *)
let pn = funcParameterNames parsed_file name;;
let pni = itemsOnly pn;;
(*let pnis = L.iter (Printf.printf "%s\n") pni;;*)


(* Parameter types *)
let pt = funcParameterTypes parsed_file name;;
let pti = itemsOnly pt;;
let ptis = L.map typename_as_string pti;;
(*let _ = L.iter (Printf.printf "%s\n") ptis;;*)

(* Print zipped list of parameter names and types *)
let zi = zip pni ptis 
let zis = L.iter (fun (name,cil_type) -> Printf.printf "%s\n%s\n" name cil_type) zi







(*let f x = x+1;;
print_int (f 3)*)

