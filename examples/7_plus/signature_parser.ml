open Cil

module L = List

(* the function with given name if exists *)
let findFunc (f:file) (name:string) : fundec option =
  let rec search glist =
    match glist with
    | GFun (func,_) :: rest when func.svar.vname = name
                              && isFunctionType func.svar.vtype ->
      Some func
    | _ :: rest -> search rest
    | [] -> None
  in search f.globals

(* a list with the return type and parameter names and types of func 
[return_type, [param1, type1], [param2, type2], ... , [param_n, type_n]]*)
let typeList (fundec:func) : list = 
	func.svar.vtype :: typeListParameters func.sformals

let typeListParameters (parameter_list: varinfo list) : list = 
	L.map(fun formal ->
	formal.vname :: [formal.vtype]) parameter_list


