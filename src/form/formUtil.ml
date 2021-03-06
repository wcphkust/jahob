(**  Utility functions for manipulating {!Form} formulas. *)

(* TODO: cleanup and ordering *)

open Form
open TypeVars


(* {6 Debug messages} *)
let debug_id = Debug.register_debug_module "FormUtil"
let debug_lmsg = Debug.debug_lmsg debug_id
let debug_msg = Debug.debug_msg debug_id


let arrayName = "Array"
let shortArrayStateId = "arrayState"
let arrayStateId = arrayName ^ "." ^ shortArrayStateId
let arrayStateVar = Var arrayStateId

let shortArrayLengthId = "length"
let arrayLengthId = arrayName ^ "." ^ shortArrayLengthId
let arrayLengthVar = Var arrayLengthId


(** {6 Formula makers} *)

let mk_true = Const (BoolConst true)
let mk_false = Const (BoolConst false)
let mk_bool b = if b then mk_true else mk_false
let mk_int k = Const (IntConst k)
let mk_not f = App (Const Not, [f])
let mk_and cs = match cs with
| [] -> mk_true
| [f] -> f
| _ -> App (Const And, cs)
let mk_metaand cs = match cs with
| [] -> mk_true
| [f] -> f
| _ -> App (Const MetaAnd, cs)
let mk_or ds = App (Const Or, ds)
let mk_eq (lhs, rhs) = App (Const Eq, [lhs; rhs])
let mk_neq (lhs, rhs) = mk_not (mk_eq(lhs,rhs))
let mk_seteq (lhs, rhs) = App (Const Seteq, [lhs; rhs])
let mk_subset (lhs, rhs) = App (Const Subset, [lhs; rhs])
let mk_subseteq (lhs, rhs) = App (Const Subseteq, [lhs; rhs])
let mk_lt (lhs, rhs) = App (Const Lt, [lhs; rhs])
let mk_gt (lhs, rhs) = App (Const Gt, [lhs; rhs])
let mk_lteq (lhs, rhs) = App (Const LtEq, [lhs; rhs])
let mk_gteq (lhs, rhs) = App (Const GtEq, [lhs; rhs])
let mk_impl (lhs, rhs) = App (Const Impl, [lhs; rhs])
let mk_metaimpl (lhs, rhs) = App (Const MetaImpl, [lhs; rhs])
let mk_iff (lhs, rhs) = App (Const Iff, [lhs; rhs])
let mk_forall(v,t,f) = Binder(Forall,[(v,t)],f)
let mk_foralls(vts,f) = Binder(Forall,vts,f)
let mk_exists(v,t,f) = Binder(Exists,[(v,t)],f)
let mk_existses(vts,f) = Binder(Exists,vts,f)
let mk_var v = Var v
let mk_string s = Const (StringConst s)

let mk_let e (v,t) f = App(Const Let,[e;Binder(Lambda,[(v,t)],f)])
let mk_def (v,f) = mk_eq(mk_var v,f)
let mk_fieldRead f x = App(Const FieldRead, [f;x])
let mk_fieldWrite f x y = App(Const FieldWrite,[f;x;y])
let mk_arrayLength arrObj = mk_fieldRead arrayLengthVar arrObj
let mk_arrayRead arr arrObj index = 
  App(Const ArrayRead,[arr;arrObj;index])
let mk_arrayRead1 arrObj index = mk_arrayRead arrayStateVar arrObj index
let mk_arrayWrite arr arrObj index v =
  App(Const ArrayWrite,[arr;arrObj;index;v])
let mk_arrayWrite1 arrObj index v =
  App(Const ArrayWrite,[arrayStateVar;arrObj;index;v])
let mk_null = Const NullConst

(** {4 Arithmetic operations} *)

let mk_plus (lhs, rhs) = App (Const Plus, [lhs; rhs])
let mk_uminus x = App(Const UMinus, [x])
let mk_minus (lhs, rhs) = App (Const Minus, [lhs; rhs])
let mk_mult (lhs, rhs) = App (Const Mult, [lhs; rhs])
let mk_div (lhs, rhs) = App (Const Div, [lhs; rhs])
let mk_mod (lhs, rhs) = App (Const Mod, [lhs; rhs])

(** {4 Set operations} *)

let mk_elem (lhs, rhs) = App(Const Elem, [lhs;rhs])
let mk_notelem (lhs, rhs) = mk_not (mk_elem (lhs, rhs))
let mk_setdiff (lhs, rhs) = App (Const Diff, [lhs; rhs])
let mk_cup (lhs, rhs) = App (Const Cup, [lhs; rhs])
let mk_cap (lhs, rhs) = App (Const Cap, [lhs; rhs])
let mk_finite_set fs = App (Const FiniteSetConst, fs)
let mk_emptyset = Const EmptysetConst
let mk_univ = Const UniversalSetConst
let mk_singleton x = mk_finite_set [x]
let mk_card f = App (Const Card, [f])
let mk_tuple fs = App (Const Tuple, fs)
let mk_singleton_relation ids = mk_singleton (mk_tuple (List.map mk_var ids))

(** {4 Miscellaneous operations} *)

let mk_list fs = App(Const ListLiteral, fs)
let mk_old f = App(Const Old, [f])
let mk_objlocs f = App(Const ObjLocs, [f])
let mk_typedvar (id:ident) (ty:typeForm) : form = TypedForm((Var id),ty)
let mk_typedform (f, t) = TypedForm(f,t)
let mk_typevar id = TypeVar (String.sub id 1 (String.length id - 1))
let mk_ite (f1, f2, f3) = App(Const Ite, [f1;f2;f3])

let mk_unit = Const Unit

let mk_comment s f = 
  if s="" then f 
  else App(Const Comment,[Const (StringConst s);f])
   
(** {4 Test the shape of a formula} *)

let rec is_var = function
  | Var _ -> true
  | App(Const Comment, [_; f0])
  | TypedForm(f0, _) -> is_var f0
  | _ -> false

(** {4 Deconstruct a formula} *)

let rec unvar = function
  | TypedForm(f0, _) -> unvar f0
  | Var id -> id
  | _ -> invalid_arg "FormUtil.unvar"

let rec name_of_field = function
  | TypedForm(f0, _) -> name_of_field f0
  | App (Const FieldRead, [name; _])
  | App (Const FieldWrite, [name; _; _]) -> PrintForm.string_of_form name
  | _ -> invalid_arg "FormUtil.name_of_field"

let rec recv_of_field = function
  | TypedForm(f0, _) -> name_of_field f0
  | App (Const FieldRead, [_; recv])
  | App (Const FieldWrite, [_; recv; _]) -> PrintForm.short_string_of_form recv
  | f -> invalid_arg "FormUtil.recv_of_field"

let rec arg_of_fieldWrite = function
  | TypedForm(f0, _) -> name_of_field f0
  | App (Const FieldWrite, [_; _; arg]) -> PrintForm.short_string_of_form arg
  | f -> invalid_arg "FormUtil.arg_of_fieldWrite"


let dummify_tv (v,t) = (v,TypeUniverse)
(** Remove type information. *)

let rec strip_types = function
    | App(f1,fs) -> App(strip_types f1, List.map strip_types fs)
    | Binder(b,tvs,f1) -> 
        Binder(b,List.map dummify_tv tvs, strip_types f1)
    | Var _ as f -> f
    | Const _ as f -> f
    | TypedForm(f1,t) -> strip_types f1
(** Strip types from formula. *)

let strip_sq_types (fs, f) = 
  (List.map strip_types fs, strip_types f)

(** Hint processing *)

let encode_hints hints = 
  if hints = [] then "" else "HINTS:" ^ String.concat "," hints

let decode_hints msg = 
  match Util.split_by "HINTS:" msg with
    | [msg0;hint_str] -> Some (Util.split_by "," hint_str, msg0)
    | _ -> None

let is_hinted hints f = 
  match (strip_types f) with
    | App(Const Comment,[Const (StringConst s);_]) ->
	(List.exists (fun hint -> Util.substring hint s) hints)
    | _ -> false

let remove_hints msg =
  match decode_hints msg with
    | None -> msg
    | Some (hs, msg0) -> msg0

let mk_hint_comment hints msg f = 
  if msg = "" && hints = [] then f
  else App(Const Comment,[Const (StringConst (msg ^ encode_hints hints));f])

(** Smart type makers. *)

let mk_unit_type = TypeApp(TypeUnit,[])
let mk_int_type = TypeApp(TypeInt,[])
let mk_string_type = TypeApp(TypeString, [])
let mk_bool_type = TypeApp(TypeBool,[])
let mk_object_type = TypeApp (TypeObject,[])

let mk_fun_type (arg_tys:typeForm list) (res_ty:typeForm) : typeForm =
  match res_ty with
  | TypeFun (arg_tys', res_ty') -> TypeFun (arg_tys @ arg_tys', res_ty')
  |  _ -> TypeFun (arg_tys, res_ty)

let mk_class_type name =
(* TypeApp(TypeDefined name,[]) *)
  mk_object_type

let mk_set_type t = TypeApp(TypeSet,[t])
let mk_obj_set_type = mk_set_type mk_object_type
let mk_list_type t = TypeApp (TypeList, [t])
let mk_map it et = TypeApp(TypeArray,[it;et])
let mk_array et = mk_map mk_int_type et
let mk_field_type t = mk_map mk_object_type t
let mk_state_array et = mk_field_type (mk_array et)

let mk_product_type ts = TypeProd ts

let objset_str = "objset"

let mk_type_from_ident t =
  if t = objset_str
  then mk_set_type mk_object_type
  else TypeApp(TypeDefined t,[])

let mk_obj_emptyset = mk_typedform(mk_emptyset, mk_obj_set_type)
let mk_obj_univ = mk_typedform(mk_univ, mk_obj_set_type)

(* Variable denoting receiver parameter *)
let this_id = "this"
let this_tv = (this_id, mk_object_type)
let this_var = mk_var this_id

(* Make set comprehension defining a relation *)
let mk_relation_comprehension tids f = 
  let ts = Util.fresh_name "p" in
  let mk_coord (v,t) = Var v in
  let tuple = mk_tuple (List.map mk_coord tids) in
  let prod_ty = mk_product_type (List.map snd tids) in
  let res = 
    Binder(Comprehension,[(ts, prod_ty)],
	   Binder(Exists,tids,
		  App(Const And, [mk_eq(Var ts,tuple);f])))
    (* Binder (Comprehension, tids, f) *)
  in
(*
  let _ = print_string ("\nRel comprehension ML:" ^ MlPrintForm.string_of_form res ^ "\n") in
  let _ = print_string ("\nRel comprehension ASCII:" ^ PrintForm.string_of_form res ^ "\n") in
*)
    res

let mk_relation fs f =
  match fs with
    | [Var id] ->
	Binder (Comprehension, [(id, TypeUniverse)], f)
    | [App(Const Tuple, fs0)] -> 
	let ids = List.map unvar fs0 in
	  mk_relation_comprehension 
	    (List.map (fun x -> (x, TypeUniverse)) ids) f
    | _ -> 
	let msg = List.fold_left
	  (fun x y -> x ^ (PrintForm.string_of_form y) ^ "; ") "" fs in
	  failwith ("mk_relation: [" ^ msg ^ "]")
	    
let mk_set_expr lhs = function
  | [] -> mk_finite_set lhs
  | [f] -> mk_relation lhs f
  | rhs ->
      let msg = List.fold_left
	(fun x y -> x ^ (PrintForm.string_of_form y) ^ "; ") "" rhs in
	Util.fail ("mk_set_expr: [" ^ msg ^ "]")

let mk_starred_rtrancl f = App(Const Rtrancl, [f])

let mk_elem_try_trancl pair tc =
  match pair, tc with
    | App(Const Tuple, [x; y]),
      App(Const Rtrancl,
	  [Binder(Comprehension,[(_ (* ts *), _)],
	     Binder(Exists,[(v1,t1); (v2,t2)],
		    App(Const And,
			[App(Const Eq, [Var _ (* ts' *); 
					App(Const Tuple,[Var _ (* v1' *);Var _ (* v2' *)])]);
			 f1])))]) (* when ts'=ts && v1'=v1 && v2'=v2 *)
    | App(Const Tuple, [x; y]),
      App(Const Rtrancl,
	  [Binder(Comprehension,[(v1, t1); (v2, t2)], f1)])
      -> Some 
	(App(Var "rtrancl_pt",
	     [Binder(Lambda,[(v1,t1); (v2,t2)],f1); x; y]))
    | _ -> None

let mk_elem_rtrancl_smart (elemf, setf) =
  match mk_elem_try_trancl elemf setf with
    | Some f -> f
    | None -> mk_elem(elemf,setf)

let mk_notelem_rtrancl_smart (elemf, setf) = 
  mk_not (mk_elem_rtrancl_smart(elemf,setf))

let fv f = 
  let add v bv acc = 
    if (List.mem v bv) || (List.mem v acc) 
    then acc
    else v::acc in
  let rec fv1 bv acc = function
  | App(f1,fs) -> fv1 bv (List.fold_left (fv1 bv) acc fs) f1
  | Binder(_,tvs,f1) -> fv1 (List.rev_append (List.rev_map fst tvs) bv) acc f1
  | Var v -> add v bv acc
  | Const _ -> acc
  | TypedForm(f1,t) -> fv1 bv acc f1
in fv1 [] [] f

let fv_by_type env tys f =
  List.filter (fun x -> 
    try List.mem (List.assoc x env) tys
    with Not_found -> Util.warn ("missing type for variable " ^ x); true) (fv f)

let consts f =
  let rec consts acc = function
    | Const c -> Util.union [c] acc
    | Var _ -> acc
    | App (f, fs) ->
	List.fold_left consts acc (f :: fs)
    | Binder (_, _, f)
    | TypedForm (f, _) -> consts acc f
  in consts [] f

(** Adding types *)

(** Add types to integer constants in a formula. *)
let type_int_consts (f0 : form) : form =
  let rec add (f : form) : form = match f with
    | TypedForm(Const (IntConst _),_) -> f
    | TypedForm(f1,t) -> TypedForm(add f1,t)
    | Const (IntConst _) -> TypedForm(f, mk_int_type)
    | Const _ -> f
    | Binder(k,vts,f1) -> Binder(k,vts,add f1)
    | App(f1,fs) -> App(add f1, List.map add fs)
    | Var _ -> f
  in 
  let res = add f0 in
    res

(** Smart constructors: construct a formula out of components and
    perhaps do some local simplifications. *)

let smk_plus (lhs, rhs) = 
  match lhs, rhs with
    | Const (IntConst 0),_ -> rhs
    | _,Const (IntConst 0) -> lhs
    | _,_ -> App (Const Plus, [lhs; rhs])

let smk_cup fs = 
  let rec mkcup1 fs acc = match fs with
  | [] ->
      begin
        match acc with
          | [] -> Const EmptysetConst
          | [f] -> f
          | _ -> App (Const Cup, List.rev acc)
      end
  | App(Const Cup,fs0) :: fs1 -> mkcup1 (List.rev_append fs0 fs1) acc
  | Const EmptysetConst::fs1 -> mkcup1 fs1 acc
  | Const UniversalSetConst::fs1 -> Const UniversalSetConst
  | fs::fs1 -> mkcup1 fs1 (Util.set_add fs acc)
  in mkcup1 fs []

let smk_cap fs = 
  let rec mkcap1 fs acc = match fs with
    | [] -> (match acc with
	       | [] -> Const UniversalSetConst
	       | [f] -> f
	       | _ -> App (Const Cap, List.rev acc))
    | App(Const Cap,fs0) :: fs1 -> mkcap1 (fs0 @ fs1) acc
    | Const UniversalSetConst::fs1 -> mkcap1 fs1 acc
    | Const EmptysetConst::fs1 -> Const EmptysetConst
    | fs::fs1 -> mkcap1 fs1 (Util.set_add fs acc)
  in mkcap1 fs []

let smk_not f =
  match f with
  | Const (BoolConst b) -> Const (BoolConst (not b))
  | App (Const Not, [f']) -> f'
  | _ -> mk_not f

let smk_forall (x,t,f) = 
  if List.mem x (fv f) then mk_forall(x,t,f)
  else f

(** Simplifies an all-quantified formula. Removes unused variables.
Simplifies "for all x: x not in S" where x does not occur in S into "S=emptyset". *)
(*
let smk_foralls (xts,f) = 
  let fvs = fv f in
  let isfree x = List.mem x fvs in
  (* Walks through the variable list, determining for each variable whether it can be removed. *)
  let rec walk_through_xts sofar_f sofar_xts remaining_xts =
    (match remaining_xts with
	[] -> (match sofar_xts with
	    [] -> sofar_f
          | _ -> mk_foralls(sofar_xts,sofar_f) )
      | (id,tf)::xts' -> (if isfree id then 
	  (match sofar_f with 
	      TypedForm(App (Const Not,[App(Const Elem,[TypedForm ((Var id),tf);(TypedForm(some_set,TypeApp(TypeSet,[tf1]))) as typed_set])]),TypeApp(TypeBool,[])) when (tf=tf1 && not (List.mem id (fv some_set))) -> 
		walk_through_xts (TypedForm(App((Const Seteq),[typed_set;(TypedForm((Const EmptysetConst),(TypeApp(TypeSet,[tf]))))]),TypeApp(TypeBool,[]))) sofar_xts xts'
	    | _ -> walk_through_xts sofar_f ((id,tf)::sofar_xts) xts')
	else walk_through_xts sofar_f sofar_xts xts'))
  in walk_through_xts f [] xts
*)

(** Simplifies an all-quantified formula. Removes unused variables. *)
let smk_foralls (xts,f) = 
  let fvs = fv f in
  let isfree (x,t) = List.mem x fvs in
  let useful = List.filter isfree xts in
    match useful with 
	[] -> f
      | _ -> 
	match f with
	  | Binder (Forall, xts', f') -> mk_foralls(useful @ xts', f')
	  | _ -> mk_foralls(useful, f)

let smk_exist (x,t,f) = 
  if List.mem x (fv f) then mk_exists(x,t,f)
  else f

let smk_exists (xts,f) = 
  let fvs = fv f in
  let isfree (x,t) = List.mem x fvs in
  let useful = List.filter isfree xts in
    if useful=[] then f else 
    match f with
    | Binder (Exists, xts', f') -> mk_existses(useful @ xts', f')
    | _ -> mk_existses(useful, f)

let smk_or fs = 
  let rec mkor1 fs acc = match fs with
  | [] -> 
      begin
        match acc with
          | [] -> Const (BoolConst false)
          | [f] -> f
          | _ -> mk_or (List.rev acc)
      end
  | App(Const Or,fs0) :: fs1 -> mkor1 (List.rev_append fs0 fs1) acc
  | Const (BoolConst false)::fs1 -> mkor1 fs1 acc
  | Const (BoolConst true)::fs1 -> Const (BoolConst true)
  | fs::fs1 -> mkor1 fs1 (Util.set_add fs acc)
  in mkor1 fs []

let smk_and fs = 
  let rec mkand1 fs acc = match fs with
    | [] ->
        begin
          match acc with
	    | [] -> Const (BoolConst true)
	    | [f] -> f
	    | _ -> mk_and (List.rev acc)
        end
    | App(Const And, fs0) :: fs1 -> mkand1 (fs0 @ fs1) acc
    | App(Const Comment, [_; Const(BoolConst true)]) :: fs1
    | Const (BoolConst true):: fs1 -> mkand1 fs1 acc
    | App(Const Comment, [_; Const(BoolConst false)]) :: fs1
    | Const (BoolConst false):: fs1 -> Const (BoolConst false)
    | (TypedForm((Const (BoolConst false)),t))::fs1 -> TypedForm((Const (BoolConst false)),t)
    | fs::fs1 -> mkand1 fs1 (Util.set_add fs acc)
  in let res = mkand1 fs [] in
  (* debug_msg ("Simplification of And("^(String.concat "," (List.map MlPrintForm.string_of_form fs))^")\nis\n"^(MlPrintForm.string_of_form res)^".\n"); *)
  res

let smk_metaand fs = 
  let rec mkand1 fs acc = match fs with
    | [] ->
        begin
          match acc with
	    | [] -> Const (BoolConst true)
	    | [f] -> f
	    | _ -> mk_metaand (List.rev acc)
        end
    | (App(Const And,fs0) :: fs1 
      | App(Const MetaAnd,fs0) :: fs1) -> mkand1 (List.rev_append fs0 fs1) acc
    | (App (Const Comment, [_; Const (BoolConst true)]) :: fs1
      | Const (BoolConst true)::fs1) -> mkand1 fs1 acc
    | (App (Const Comment, [_; Const (BoolConst false)]) :: fs1
      | Const (BoolConst false)::fs1) -> Const (BoolConst false)
    | fs::fs1 -> mkand1 fs1 (Util.set_add fs acc)
  in mkand1 fs []

let smk_ite(f1,f2,f3) = 
  match f1 with 
    | Const (BoolConst true) -> f2
    | Const (BoolConst false) -> f3
    | _ -> mk_ite(f1,f2,f3)

let smk_eq (f0 : form) (f1 : form) : form =
  if (f0 = f1) then
    Const (BoolConst true)
  else
    mk_eq(f0, f1)

let smk_impl(f1,f2) = 
  match f1 with
    | Const (BoolConst false) -> Const (BoolConst true)
    | Const (BoolConst true) -> f2
    | App (Const And, fs) when List.mem f2 fs -> mk_true
    | _ -> (match f2 with
	      | App(Const Impl,[f2a;f2b]) -> mk_impl(smk_and [f1;f2a], f2b)
	      |	App(Const MetaImpl, [f2a; f2b]) -> mk_metaimpl (smk_metaand [f1;f2a], f2b)
(*	      | Const (BoolConst false) -> mk_not f1 - this is sound, but confusing. *)
	      | Const (BoolConst true) -> f2
	      | _ -> mk_impl(f1,f2))

let smk_metaimpl(f1,f2) = 
  match f1 with
    | Const (BoolConst false) -> Const (BoolConst true)
    | Const (BoolConst true) -> f2
    | App (Const And, fs) when List.mem f2 fs -> mk_true
    | _ -> (match f2 with
	      | App(Const Impl,[f2a;f2b]) -> mk_metaimpl(smk_and [f1;f2a], f2b)
	      |	App(Const MetaImpl, [f2a; f2b]) -> mk_metaimpl (smk_metaand [f1;f2a], f2b)
(*	      | Const (BoolConst false) -> mk_not f1 - this is sound, but confusing *) (* AM: but helps to keep the formula size small and eliminate some useless quantifiers. *)
	      | TypedForm (Const (BoolConst false), TypeApp (TypeBool,[])) -> mk_typedform ((mk_not f1),(TypeApp (TypeBool,[])))
	      | Const (BoolConst true) -> f2
	      | _ -> mk_metaimpl(f1,f2))

let smk_impl_if_relevant (v : ident) (f1, f2) : form =
  if List.mem v (fv f2) then smk_impl(f1,f2) else f2

(** Normalize type formula *)
let rec normalize_type ty =
  match ty with
  | TypeApp (TypeArray, [ty1;ty2]) ->
      normalize_type (TypeFun ([ty1], ty2))
  | TypeApp (sty, tys) ->
      TypeApp (sty, List.map normalize_type tys)
  | TypeFun (tys, res_ty) ->
      (match (tys, res_ty) with
      |	(_, TypeFun (tys'', res_ty'')) ->
	  normalize_type (TypeFun (tys @ tys'', res_ty''))
      |	(_, TypeApp (TypeArray, [ty'';res_ty''])) ->
	  normalize_type (TypeFun (tys @ [ty''], res_ty''))
      |	([], _) -> normalize_type res_ty
      |	_  -> TypeFun (List.map normalize_type tys, normalize_type res_ty))
  | TypeProd tys ->
      TypeProd (List.map normalize_type tys)
  | _ -> ty

(** Check whether two types are the same *)
let equal_types ty1 ty2 = 
  normalize_type ty1 = normalize_type ty2

(** Normalize formula for pattern matching up to depth [n]. *)
let normalize n f =
  let rec drop n f = match f with
  | Var _ | Const _ -> f
  | App (Const Comment, [_; f]) -> 
      drop n f 
  | App (t, ts) -> 
      if n = 0 then f
      else App (drop (n - 1) t, List.map (drop (n - 1)) ts)
  | Binder (b, vts, f') -> 
      if n = 0 then f 
      else Binder (b, vts, drop (n - 1) f')
  | TypedForm (f, _) -> drop n f
  in drop n f

(** Sequent is just a conjunction of formulas 
    that implies the conclusion. *)

type sequent = form list * form

let string_of_oblig (ob : obligation) = 
  Common.string_of_pos ob.ob_pos  ^ " : " ^ ob.ob_purpose ^ " := \n" ^
  PrintForm.string_of_form ob.ob_form

let short_string_of_oblig (ob : obligation) = 
  Common.string_of_pos ob.ob_pos  ^ " : " ^ ob.ob_purpose ^ " := \n" ^
  PrintForm.short_string_of_form ob.ob_form

let name_of_oblig (ob : obligation) = 
  Common.string_of_pos ob.ob_pos  ^ " : " ^ ob.ob_purpose

let form_of_sequent (fs,f) = 
  if fs=[] then f else mk_metaimpl(smk_metaand fs,f)

let sequent_of_form f =
  let rec add (hyps : (form * string list) list) (asms : form list) = match hyps with
  | [] -> asms
  | (App(Const And, fs), cs)::hyps1 
  | (App(Const MetaAnd, fs), cs)::hyps1 -> 
      add (List.rev_append (List.rev_map (fun f -> (f,cs)) fs) hyps1) asms
  | (App(Const Not, [App (Const Or, fs)]), cs)::hyps1 ->
      add (List.rev_append (List.rev_map (fun f -> (smk_not f, cs)) fs) hyps1) asms
  | (App(Const Not, [App (Const Impl, [f1;f2])]), cs)::hyps1 ->
      add ((f1,cs) :: (smk_not f2,cs)::hyps1) asms
  | (App(Const Not, [App (Const Not, [f])]),cs)::hyps1 ->
      add ((f,cs) :: hyps1) asms
  | (App(Const Comment,[Const (StringConst c);f]),cs)::hyps1 -> 
      add ((f,c::cs) :: hyps1) asms
  | (f,cs)::hyps1 -> 
      let hyp = List.fold_left (fun f c -> mk_comment c f) f cs in
      add hyps1 (hyp::asms)
  in
  let rec gen asms f cs = match f with
  | App(Const Comment, [Const StringConst c; f1]) -> gen asms f1 (c::cs)
  | TypedForm (f1, _) -> gen asms f1 cs
  | App(Const Impl, [f1; f2])
  | App(Const MetaImpl,[f1;f2]) -> gen (add [(f1, [])] asms) f2 cs
  (* | Binder(Forall,vts,f1) -> gen (vts @ env) asms f1 *)
  | _ -> (List.rev asms, List.fold_left (fun f c -> mk_comment c f) f cs)
  in gen [] f []

let string_of_sequent (sq:sequent) : string = 
(*  string_of_form (strip_types (form_of_sequent sq)) *)
  PrintForm.string_of_form (form_of_sequent sq)

let short_string_of_sequent (sq:sequent) : string = 
(*  string_of_form (strip_types (form_of_sequent sq)) *)
  PrintForm.short_string_of_form (form_of_sequent sq)

(** Some simple formula simplification. *)

let rec simplify (f:form) = 
  match f with
    | App(f1,[]) -> simplify f1
    | App(Const And,fs) -> smk_and (List.map simplify fs)
    | App(Const Impl,[f1;f2]) -> smk_impl(simplify f1, simplify f2)
    | Binder(Forall,vts,f1) -> smk_foralls(vts,f1)
    | Var v -> f
    | Const c -> f
    | Binder(k,vts,f1) -> Binder(k,vts,simplify f1)
    | App(f1,fs) -> App(simplify f1, List.map simplify fs)
    | TypedForm(f1,t) -> TypedForm(simplify f1,t)


(** Substitution (ignores types). *)

type substMap = (ident * form) list

(** nsubst [(id_1,g_1);...;(id_n,g_n)] f
    syntactically replaces all free occurences of id_i in f with g_i (i<=n). 
    No renaming takes place. The replacement does not look into g_i (i<=n). *)
let rec nsubst m f = 
  match f with
  | App(f1,fs) -> App(nsubst m f1, List.map (nsubst m) fs)
  | Binder(k,tvs,f1) -> 
      let not_bound (id,f) = not (List.mem_assoc id tvs) in
      let m1 = List.filter not_bound m in
      if m1 = [] then f else
      Binder(k,tvs,nsubst m1 f1)
  | Var v -> (try List.assoc v m with Not_found -> f)
  | Const _ -> f
  | TypedForm(f1,t) -> TypedForm(nsubst m f1,t)

let fv_of_subst m = List.concat (List.map fv (List.map snd m))

(** Auxiliary for {!subst}.
    Computes 'renaming' for the variables that cause variable capture,
    and a new set of bound variables. *)
let rec capture_avoid 
    (vars : ident list)
    (tvs : typedIdent list)
    (subst_acc : substMap)
    (tvs_acc : typedIdent list) : (typedIdent list * substMap) =
  match tvs with
    | [] -> (List.rev tvs_acc, subst_acc)
    | (v,t)::tvs1 when (List.mem v vars) ->
	let fresh_v = Util.fresh_name v in
	  capture_avoid vars tvs1 
            ((v,Var fresh_v)::subst_acc)
            ((fresh_v,t)::tvs_acc)
    | (v,t)::tvs1 ->
	capture_avoid vars tvs1 
          subst_acc
          ((v,t)::tvs_acc)

(** subst [(id_1,g_1);...;(id_n,g_n)] f
    performs capture-free subsitution of free occurences of each id_i 
    by g_i in f (i<=n). The replacement does not look into g_i (i<=n). *)
let subst m f = 
  (* (debug_msg ("subst started with m=["^(String.concat ";" (List.map (fun (x,g) -> ("("^x^","^(PrintForm.string_of_form g)^")")) m))^"] and f="^(PrintForm.string_of_form f)^".\n")); *)
  let res= 
  if m = [] then f else
  let rec subst m f = 
    (* (debug_msg ("internal subst started with m=["^(String.concat ";" (List.map (fun (x,g) -> ("("^x^","^(PrintForm.string_of_form g)^")")) m))^"] and f="^(PrintForm.string_of_form f)^".\n")); *)
    let res=
    match f with
      App(Const And, fs) -> smk_and (List.map (subst m) fs)
    | App(Const MetaImpl,[f1;f2]) -> smk_metaimpl ((subst m f1), (subst m f2))
    | App(f1,fs) -> App(subst m f1, List.map (subst m) fs)
    | Binder(k,tvs,f1) -> 
	let not_bound (id,f) = not (List.mem_assoc id tvs) in
	let m1 = List.filter not_bound m in
	  (** m1 is projection of substitution to 
	      variables that are not bound *)
	  if m1 = [] then f
	  else 
            let tvs1, renaming = 
              capture_avoid (fv_of_subst m1) tvs [] [] in
            let f2 = if renaming=[] then f1 else nsubst renaming f1 in
              if tvs1=[] then f2 else
		(match k with
		    Forall -> smk_foralls (tvs1,(subst m1 f2))
		  | _ -> Binder(k,tvs1,(subst m1 f2)))
    | Var v -> 
	(try List.assoc v m
	 with Not_found -> f)
    | Const _ -> f
    | TypedForm(f1,t) -> TypedForm(subst m f1,t)
    in ((* (debug_msg ("internal subst that started with m=["^(String.concat ";" (List.map (fun (x,g) -> ("("^x^","^(PrintForm.string_of_form g)^")")) m))^"] and f="^(PrintForm.string_of_form f)^" finished with "^(PrintForm.string_of_form res)^".\n")); *) res)
  in subst m f
  in ((* (debug_msg ("subst that started with m=["^(String.concat ";" (List.map (fun (x,g) -> ("("^x^","^(PrintForm.string_of_form g)^")")) m))^"] and f="^(PrintForm.string_of_form f)^" finished with "^(PrintForm.string_of_form res)^".\n")); *) res)

let rec contains_old = function
  | App(Const Old, _) -> true
  | App(f1,fs) -> 
      List.exists contains_old (f1::fs)
  | Binder(k,tvs,f1) -> contains_old f1
  | Var _ -> false
  | Const _ -> false
  | TypedForm(f1,_) -> contains_old f1

let oldname s = "old_" ^ s

let is_oldname s = (String.length s > 4) && (String.sub s 0 4 = "old_")

let unoldname s =
  if is_oldname s then String.sub s 4 (String.length s - 4)
  else invalid_arg "FormUtil.unoldname"

let rec oldify
    (mkold : bool)
    (skip : ident list)
    (f0 : form) : form = 
  match f0 with
    | App(Const Old, [f1]) -> oldify true skip f1
    | App(f1,fs) -> App(oldify mkold skip f1, 
			List.map (oldify mkold skip) fs)
    | Binder(k,tvs,f1) ->
	let new_skip = skip @ List.map fst tvs in
	  Binder(k,tvs,oldify mkold new_skip f1)
    | Var v -> 
	if mkold && (not (List.mem v skip)) then (Var (oldname v))
	else f0
    | Const _ -> f0
    | TypedForm(f1,t) -> TypedForm(oldify mkold skip f1,t)

let transform_old = oldify false []

(* skip is a list of variables that should not be made old *)
let make_old_and_transform f skip = oldify true skip f

(* replace old_x with x *)
let remove_old f =
  let mk_map_x0_x v = 
    if is_oldname v then [(v, mk_var (unoldname v))]
    else [] in
  let m_x0_x = List.concat (List.map mk_map_x0_x (fv f)) in
    subst m_x0_x f

(** {6 Hai's code for type inference in BAPA} *)

(*--------------------------------------------------
  some utility functions
  --------------------------------------------------*)

let is_set_type (t : typeForm) = match t with
  | TypeApp (TypeSet, _) -> true
  | _ -> false

let is_bool_type (t : typeForm) = match t with
  | TypeApp (TypeBool, _) -> true
  | _ -> false

let is_int_type (t : typeForm) = match t with
  | TypeApp (TypeInt, _) -> true
  | _ -> false

let is_object_type (t : typeForm) = match t with
  | TypeApp (TypeObject, _) -> true
  | _ -> false

let get_defined_type_name (t : typeForm) = match t with
  | TypeApp (TypeDefined name, _) -> Some name
  | _ -> None

let is_same_type (t1 : typeForm) (t2 : typeForm) : bool =
  if (is_int_type t1 && is_int_type t2)
    || (is_set_type t1 && is_set_type t2)
    || (is_bool_type t1 && is_bool_type t2) 
    || (is_object_type t1 && is_object_type t2)
    || ((get_defined_type_name t1) = (get_defined_type_name t2))
  then
    true
  else
    false

let is_set_form (f : form) = match f with
  | TypedForm (_, t) -> is_set_type t
  | _ -> false

(** [is_bool_form f]
    returns 
    - true, if the type of the term is always boolean
    - false, if the type of the formula can be nonboolean. *)
let rec is_bool_form (f : form) = match f with
  | TypedForm (_, t) -> is_bool_type t
  | App(Const Eq,[_;_])
  | App(Const MetaEq,[_;_])
  | App(Const Iff,[_;_])
  | App(Const Disjoint,[_;_])
  | App(Const Cardeq,[_;_])
  | App(Const Seteq,[_;_])
  | App(Const Not,[_])
  | App(Const Impl,[_;_]) | App(Const MetaImpl,[_;_]) | App(Const Lt,[_;_]) | App(Const Gt,[_;_]) | App(Const LtEq,[_;_]) | App(Const GtEq,[_;_]) | App(Const Cardleq,[_;_]) | App(Const Cardgeq,[_;_]) | App(Const Subseteq,[_;_]) | App(Const Subset,[_;_])
  | Const (BoolConst _) | Binder(Exists,_,_) | Binder(Forall,_,_) -> true
  | App(Const Comment,[g]) | App(Const Old,[g]) -> is_bool_form g
  | App(Const Ite,[cond;thenpart;elsepart]) -> ((is_bool_form thenpart) && (is_bool_form elsepart))
  | _ -> false

let is_int_form (f : form) = match f with
  | TypedForm (_, t) -> is_int_type t
  | _ -> false

let is_object_form (f : form) = match f with
  | TypedForm (_, t) -> is_object_type t
  | _ -> false

let get_type (f : form) = match f with
  | TypedForm (_, t) -> t
  | _ -> failwith ("form:get_type: not TypedForm")

let get_form (f0 : form) = match f0 with
  | TypedForm (f, _) -> f
  | _ -> failwith ("form:get_form: not TypedForm")



let is_empty_set (f : form) = match f with
  | Const EmptysetConst -> true
  | _ -> false

exception FormulaTypeError of string

(** Extracting annotated types from formulas. *)

let merge_typing 
    (t1 : typedIdent list) 
    (t2 : typedIdent list) : typedIdent list =
  let add (v,t) vts =
    try (let t1 = List.assoc v vts in
	   (if normalize_type t1 <> normalize_type t && (ftv t1 = []) then 
	     Util.warn 
		("FormUtil.merge_typing: conflicting types for variable \"" ^ v ^
		   "\", types \"" ^ 
		   PrintForm.wr_type t1 ^ "\" and \"" ^
		   PrintForm.wr_type t ^ "\".")
	    else ()); vts)
    with Not_found -> (v,t)::vts 
  in
    List.fold_right add t1 t2

let merge_typings (ts : typedIdent list list) : typedIdent list = 
  List.fold_right merge_typing ts []

(** Extract the types of annotated free variables in a formula. *)
let get_annotated_types (f : form) : typedIdent list =
  let rec get_types (bound:ident list) (f:form) : typedIdent list = 
  match f with
  | App(f1,fs) -> 
      merge_typings (List.map (get_types bound) (f1::fs))
  | Binder(k,tvs,f1) ->
      let add_bound (v,t) vs = v::vs in
	get_types (List.fold_right add_bound tvs bound) f1
  | Var v -> []
  | Const _ -> []
  | TypedForm(Var v,t) -> if List.mem v bound then [] else [(v,t)]
  | TypedForm(f1,t) -> get_types bound f1
  in get_types [] f

(** Universally quantify typed free variables of a formula. *)
let forall_annotated_types (f : form) : form =
  smk_foralls(get_annotated_types f,f)

(** Compute order of a type *)
let order_of_type ty =
  let order_simple_type ty =
    match ty with
    | TypeUnit | TypeBool -> 0
    | TypeInt | TypeString
    | TypeObject | TypeSet -> 1
    | TypeList | TypeArray -> 1
    | TypeDefined _ -> raise (Invalid_argument "")
  in
  let rec order ty =
    match ty with
    | TypeApp (ty, tys) -> List.fold_left (fun m ty -> 
	max (order ty) m) 0 tys + order_simple_type ty
    | TypeFun (tys, ty) -> List.fold_left (fun m ty -> 
	max (order ty + 1) m) (order ty) tys
    | TypeProd tys -> List.fold_left (fun m ty -> 
	max (order ty) m) 0 tys
    | TypeUniverse | TypeVar _ -> raise (Invalid_argument "")
  in try Some (order ty) with Invalid_argument _ -> None

(** Add type annotations from environment [env] to free variables in
    formula [f]. *)
let annotate_types env f =
  let rec annot bvs f =
    match f with
      | Var v when not (List.mem v bvs) -> TypedForm (f, List.assoc v env)
      | Const _ | TypedForm (Var _, _) | Var _ -> f
      | App (f1, fs) -> App (annot bvs f1, List.map (annot bvs) fs)
      | TypedForm (f1, ty) -> TypedForm (annot bvs f1, ty)
      | Binder (b, vs, f1) -> Binder (b, vs, annot (List.rev_append (List.map fst vs) bvs) f1)
  in annot [] f

(** Remove type annotations in a formula up to depth [n] of syntax tree 
    (not counting TypedForm). Simplifies pattern matching of formulas *)
let unnotate_types n f =
  let rec drop n f = match f with
  | Var _ | Const _ -> f
  | App (t, ts) -> 
      if n = 0 then f
      else App (drop (n - 1) t, List.map (drop (n - 1)) ts)
  | Binder (b, vts, f') -> 
      if n = 0 then f 
      else Binder (b, vts, drop (n - 1) f')
  | TypedForm (f, _) -> drop n f
  in drop n f

(** Remove all type annotations in a formula *)
let unnotate_all_types = unnotate_types (-1)

(***************************************************)
(** Smart implications. Used to help e.g. BAPA. But there is a bug. *)
(***************************************************)

let extract_definitions1
    (cands : ident list)
    (f : form) : 
    (form list * substMap) =
  (* FIX: check that replaced variable is not on RHS anywhere
     else *)
  let rec extract 
      (cs : form list) (cs0 : form list) (m : substMap) =
    match cs with
      | [] -> (cs0, m)
      | (App(Const Eq,[lhs;rhs]) as c)::cs1 ->
	  (let rec handle lhs rhs = match (lhs,rhs) with
	     | (Var v,rhs) when (List.mem v cands) ->
		 if not (List.mem v (fv rhs)) &&
		   not (List.mem_assoc v m)
		 then extract cs1 cs0 ((v,rhs)::m)
		 else extract cs1 (cs0 @ [c]) m
	     | (TypedForm(lhs1,_),_) -> handle lhs1 rhs
	     | (_,TypedForm(rhs1,_)) -> handle lhs rhs1
	     | (_, Var v) when (List.mem v cands) -> handle rhs lhs 
	     | (_,_) -> extract cs1 (cs0 @ [c]) m in
	     handle lhs rhs)
      | c::cs1 -> extract cs1 (cs0 @ [c]) m in
  let rec handle1 lhs rhs = match (lhs,rhs) with
    | (Var v,rhs) -> 
	if List.mem v cands  &&
	  not (List.mem v (fv rhs))
	then ([],[(v,rhs)])
	else ([f],[])
    | (TypedForm(lhs1,_),_) -> handle1 lhs1 rhs
    | (_,TypedForm(rhs1,_)) -> handle1 lhs rhs1
    | (_, Var v) -> handle1 rhs lhs 
    | (_,_) -> ([f],[])
  in match f with
    | App(Const Eq,[lhs;rhs]) -> handle1 lhs rhs
    | App(Const And, cs) ->
	extract cs [] []
    | _ -> ([f],[])

let extract_definitions (candidates : ident list) (f : form) :
    (form * substMap) =
  let (conjs,defs) = extract_definitions1 candidates f in
    (* ideally we would order defs in topological order if possible,
       but for now we just check that rhs do not contain any lhs in
       defs *)
  let vars = List.map (fun (v,f) -> v) defs in
  let rec check (ds : substMap) (ds0 : substMap) (cs0 : form list) =
    match ds with
      | [] -> (subst ds0 (smk_and cs0), ds0)
      | (v,f)::ds1 -> 
	  if Util.disjoint (fv f) vars then check ds1 ((v,f)::ds0) cs0
	  else check ds1 ds0 (mk_def (v,f)::cs0)
  in check defs [] conjs

let smk_fixand_eq 
    (candidates : ident list)
    (f : form) : form =
  let (f1p,defs) = extract_definitions candidates f in
    smk_and ([subst defs f1p])

let smk_impl_eq 
    (candidates : ident list) 
    ((f1,f2) : form * form) : form =
  let (f1p,defs) = extract_definitions candidates f1 in
    smk_impl(f1p,subst defs f2)

let smk_impl_eq2
    (candidates : ident list) 
    (excands : ident list)
    ((f1,f2) : form * form) : form =
  let (f1p,defs) = extract_definitions candidates f1 in
    smk_impl(f1p,subst defs (smk_fixand_eq excands f2))

let rec no_binder (f : form) : bool = 
  match f with
    | Binder(_,_,_) -> false
    | App(f1,fs) -> 
	no_binder f1 && nos_binder fs    
    | Var _ -> true
    | Const _ -> true
    | TypedForm(f1,t) -> no_binder f1
and nos_binder (fs : form list) : bool =
  match fs with
    | [] -> true
    | f::fs1 -> no_binder f && nos_binder fs1

let rec lambda_or_no_binder (f : form) : bool =
  match f with 
    | Binder(Lambda,_,_) -> true
    | App(Const Comment,[Const (StringConst c);f1]) -> lambda_or_no_binder f1
    | _ -> no_binder f


(** Create formula representing (fdef --> f0).
    fdef is assumed to have the form of list of equalities v=rhs.
    When substitute_formula rhs is true, then equality is substituted,
    otherwise it is conjoined.
*)
let smk_impl_def_eq
    (substitute_formula : form -> bool)
    ((fdefs, f0) : form * form) : form =
  let rec dapply fs f =
    match fs with
      | [] -> f
      | fdef::fs1 ->
	  (match fdef with
	     | App(Const Eq,[Var v;rhs]) 
	     | App(Const Eq, [TypedForm (Var v, _); rhs]) ->
		 if substitute_formula rhs then
		   if not (List.mem v (fv (mk_and (f::fs1)))) then
		     (debug_lmsg 4 (fun () -> "Dropped definition of variable " ^ v ^ " because it does not appear anywhere.");
		     dapply fs1 f)
		   else 
		     (let sub = subst [(v,rhs)] in		     
			dapply (List.map sub fs1) (sub f))
		 else dapply fs1 (smk_impl(fdef,f))
	     | _ -> 
		 (Util.warn 
		    ("formUtil.smk_impl_def_eq: Found a non-equality " ^ PrintForm.string_of_form fdef ^"\nrepresented as:" ^
		       MlPrintForm.string_of_form fdef);
		  dapply fs1 (smk_impl(fdef,f))))
  in
  let _ = debug_lmsg 4 (fun () -> "\nsmk_impl_def_eq fdefs = " ^ MlPrintForm.string_of_form fdefs ^ "\n") in
    match fdefs with
      | Const (BoolConst true) -> f0
      | App(Const And,fs) -> dapply fs f0
      | _ -> dapply [fdefs] f0

(** Replace type variables in a formula with fresh type variables. *)
let fresh_type_vars t0 =
  let (subst : (ident * ident) list ref) = ref [] in
  let process_tvar (tvar : ident) =
    try List.assoc tvar !subst 
    with Not_found ->
      (let fresh = Util.fresh_name tvar in
	 subst := (tvar,fresh) :: !subst;
	 fresh)
  in
  let rec walk t = match t with
      | TypeUniverse -> t
      | TypeVar tv -> TypeVar (process_tvar tv)
      | TypeApp(t1,ts) -> TypeApp(t1,List.map walk ts)
      | TypeFun(ts,t1) -> TypeFun(List.map walk ts,walk t1)
      | TypeProd ts -> TypeProd (List.map walk ts)
  in 
    walk t0

(** Extract as string all first arguments of Comment constant. *)
let extract_comments (f : form) : string =
  let rec extract (acc : string list) = function
    | App(Const Comment,[Const (StringConst s);farg]) ->
	extract (s::acc) farg
    | Var _ -> acc
    | Const _ -> acc
    | App(f1,fs) -> 
	List.fold_right (fun f acc -> extract acc f) (f1::fs) acc
    | Binder(k,tvs,f1) -> extract acc f1
    | TypedForm(f1,t) -> extract acc f1
  in
    String.concat "; " (extract [] f)

let form_to_oblig (f : form) : obligation = { 
  ob_pos = Common.unknown_pos;
  ob_purpose = "";
  ob_form = f
}

let form_to_sqob (f : form) : sq_obligation = { 
  sqob_pos = Common.unknown_pos;
  sqob_purpose = "";
  sqob_sq = ([],f)
}

(** Remove lambda abstractions (currently only beta reduction) *)
let rec unlambda ?(keep_comprehensions=true) (f : form) =
  let unlambda = unlambda ~keep_comprehensions:keep_comprehensions in
  let box_result new_ty f res =
    match f with
    | TypedForm (_, old_ty) -> TypedForm (res, new_ty old_ty)
    | _ -> res
  in
  match f with
  | App (Const Elem, [t; Binder (Comprehension, vs, bf)]) 
  | App (Const Elem, [t; TypedForm (Binder (Comprehension, vs, bf), _)]) when not keep_comprehensions ->
      let t' = unlambda t in
      let ts = match normalize 1 t' with
      |	App (Const Tuple, ts) -> ts 
      |	_ -> [t']
      in
      (try 
	let sigma = List.fold_right2 
	    (fun (v, _) t acc -> (v, t)::acc)
	    vs ts [] 
	in unlambda (subst sigma bf)
      with Invalid_argument _ ->
	let bf' = unlambda bf in
	App (Const Elem, [t'; Binder (Comprehension, vs, bf')])) 
  | App (Const FieldRead, [fld]) -> unlambda fld
  | App (Const FieldRead, fld::fs) -> unlambda (App (fld, fs))
  | App (Binder (Lambda, vs, t) as head, args) |
    App (TypedForm (Binder (Lambda, vs, t), _) as head, args) ->
      let vs', sigma, args' = 
	List.fold_left (function 
	  | ((v, _)::vs', sigma, _) -> fun t -> (vs', (v, t)::sigma, [])
	  | ([], sigma', args') -> fun t -> ([], sigma', t::args')) (vs, [], []) args
      in
      let t' = subst (List.rev sigma) t in
      let new_ty ty = 
	let res_ty = match ty with
	| TypeApp (TypeArray, [_; res_ty]) -> res_ty
	| TypeFun (_, res_ty) -> res_ty
	| _ -> ty
	in
	normalize_type (TypeFun (List.map snd vs', res_ty))
      in
      if vs' = [] then if args' = [] then unlambda t'
      else unlambda (App (box_result new_ty head t', List.rev args'))
      else box_result new_ty head (Binder (Lambda, vs', unlambda t'))
  | App (t, ts) -> 
      let t' = unlambda t in
      (match t' with
      |	Binder _ | TypedForm (Binder _, _) -> unlambda (App (t', ts))
      |	_ -> App (t', List.map unlambda ts))
  | Binder (Comprehension, [(v,_)], App(Const Elem, [Var v'; f])) 
  | Binder (Comprehension, [(v,_)], App(Const Elem, [TypedForm (Var v', _); f])) 
    when v = v' && not (List.mem v (fv f)) -> unlambda f 
  | Binder (b, vs, t) -> Binder (b, vs, unlambda t)
  | TypedForm (f', ty) -> TypedForm (unlambda f', ty)
  | _ -> f
     
(** reduce formulas such that (ALL f g. reduce f = reduce g <-> equal f g).
   This means that equal/reduce can be used for hashing of formulas *)
let reduce (f : form) : form =
  let fv_f = fv f in
  let rec fresh_var (i, replace_map) x = 
    let new_x = Printf.sprintf "bv_%d" i in
    if List.mem new_x fv_f then fresh_var (i+1, replace_map) x 
    else ((i+1, (x, new_x)::replace_map), new_x)
  in
  let get_name replace_map x =
    try List.assoc x (snd replace_map)
    with Not_found -> x
  in
  let rec reduce replace_map f =
    match f with
    | App (Const UMinus, [Const (IntConst i)]) 
    | App (Const UMinus, [TypedForm (Const (IntConst i), _)]) ->
	Const (IntConst (-1 * i))
    | Const _ -> f
    | Var x -> mk_var (get_name replace_map x)
    | App (Const FieldRead, [f; t]) -> 
        App (reduce replace_map f, [reduce replace_map t])
    | App (Const Comment, [_; f1]) -> reduce replace_map f1 
    | App (Const And, [f1]) | App (Const Or, [f1]) -> reduce replace_map f1
    | App (f, fs) -> 
        App (reduce replace_map f, List.map (reduce replace_map) fs)
    | TypedForm (f, ty) -> reduce replace_map f
    | Binder (b, xs, f) ->
	let replace_map', xs' = List.fold_right 
	    (fun (x, ty) (replace_map, xs') -> 
	      let replace_map', x' = fresh_var replace_map x in
	      (replace_map', (x', normalize_type ty)::xs')) 
	    xs (replace_map, [])
	in
	let f' = reduce replace_map' f in
	Binder (b, xs', f')
  in reduce (0, []) f

let is_unifiable (mgu : substMap) (unifiable_vs : ident list) 
    (f1 : form) (f2 : form) : bool * substMap =
  let rec unify bvs mgu f1 f2 =
    let unify_var x f =
      let fv_f = fv f in
      (List.mem x unifiable_vs || List.mem x bvs) &&
      (Util.disjoint fv_f bvs || List.mem x bvs &&
      (match f with Var x' -> List.mem x' bvs | _ -> false)) &&
      not (List.mem x fv_f),
      (x, f) :: List.map (fun (x', t) -> (x', subst [(x, f)] t)) mgu
    in
    match (f1, f2) with
    | (App (Const UMinus, [Const (IntConst i1)]), (Const (IntConst i2))) 
    | (Const (IntConst i2), App (Const UMinus, [Const (IntConst i1)])) ->
	(-1 * i1) = i2, mgu
    | (Const c1, Const c2) -> c1 = c2, mgu
    | (TypedForm (f1', ty1), TypedForm (f2', ty2)) -> 
	if equal_types ty1 ty2 then 
	  unify bvs mgu f1' f2'
	else (false, mgu)
    | (TypedForm (f1', _), _) -> unify bvs mgu f1' f2
    | (_, TypedForm (f2', _)) -> unify bvs mgu f1 f2'
    | Var x1 as t1, t2
    | t2, (Var x1 as t1) ->
	(match subst mgu t1, subst mgu t2 with
	| Var x1', Var x2' when x1' = x2' -> true, mgu
	| Var x1' as t1', t2' -> 
	    let unifiable, mgu' = unify_var x1' t2' in
	    if unifiable then true, mgu'
	    else 
	      (match t2' with
	      | Var x2' -> 
		  unify_var x2' t1'
	      |	_ -> false, mgu)
	| t1', t2' -> unify bvs mgu t1' t2')
    | (App (Const FieldRead, [f; x]), f')
    | (f', App (Const FieldRead, [f; x])) -> unify bvs mgu (App (f, [x])) f'
    | (App (Const Comment, [f1']), _) -> unify bvs mgu f1' f2
    | (_, App (Const Comment, [f2'])) -> unify bvs mgu f1 f2'
    | (App (Const And, [f1']), _)
    | (App (Const Or, [f1']), _) -> unify bvs mgu f1' f2
    | (_, App (Const And, [f2']))
    | (_, App (Const Or, [f2'])) -> unify bvs mgu f1 f2'  
    | (App (g1, gs1), App (g2, gs2)) ->
	(try 
	  List.fold_left2 
	    (fun (unifiable, mgu) t1 t2 ->
	      if unifiable then
		unify bvs mgu t1 t2
	      else unifiable, mgu)
	    (true, mgu) (g1::gs1) (g2::gs2)
	with Invalid_argument _ -> false, mgu)
    | (Binder (b1, bvs1, g1), Binder (b2, bvs2, g2)) ->
	(try
	  let bvs', mgu', same_types = 
	    List.fold_left2 (fun (bvs', mgu', same_types) (x1, ty1) (x2, ty2) ->
	      if equal_types ty1 ty2 then
		x1 :: x2 :: bvs', (x1, mk_var x2) :: mgu', same_types
	      else (bvs', mgu', false)) ([], mgu, true) bvs1 bvs2
	  in
	  if b1 = b2 && same_types then
	    let unifiable, rmgu = unify (bvs' @ bvs) mgu' g1 g2 in
	    unifiable, List.filter (fun (x, _) -> not (List.mem x bvs')) rmgu
	  else false, mgu
	with Invalid_argument _ -> false, mgu)
    | _ -> false, mgu
  in unify [] mgu f1 f2

(** Check syntactic equality of formulas up to alpha renaming 
   of bound variables, type annotations, and some other symmetries 
   which can be checked in linear time. *)
let equal (f1 : form) (f2 : form) : bool =
  let rec eq sigma f1 f2 =
    match (f1, f2) with
    | (App (Const UMinus, [Const (IntConst i1)]), (Const (IntConst i2))) 
    | (Const (IntConst i2), App (Const UMinus, [Const (IntConst i1)])) ->
	(-1 * i1) = i2
    | (Const c1, Const c2) -> c1 = c2
    | (Var x1, Var x2) ->
	let x1' = 
	  try List.assoc x1 sigma 
	  with Not_found -> x1
	in x1' = x2
    | (App (Const FieldRead, [f; x]), _) -> eq sigma (App (f, [x])) f2
    | (_, App (Const FieldRead, [f; x])) -> eq sigma f1 (App (f, [x]))
    | (App (Const Comment, [f1']), _) -> eq sigma f1' f2
    | (_, App (Const Comment, [f2'])) -> eq sigma f1 f2'
    | (App (Const And, [f1']), _)
    | (App (Const Or, [f1']), _) -> eq sigma f1' f2
    | (_, App (Const And, [f2']))
    | (_, App (Const Or, [f2'])) -> eq sigma f1 f2'  
    | (App (g1, gs1), App (g2, gs2)) ->
	(try 
	  List.for_all2 (eq sigma) (g1::gs1) (g2::gs2)
	with Invalid_argument _ -> false)
    | (Binder (b1, bvs1, g1), Binder (b2, bvs2, g2)) ->
        b1 = b2 &&
	    (try
	       let sigma', same_types = 
		 List.fold_left2 (fun (sigma', same_types) (x1, ty1) (x2, ty2) ->
		   if normalize_type ty1 = normalize_type ty2 then
		     ((x1, x2)::sigma', same_types)
		   else (sigma', false)) (sigma, true) bvs1 bvs2
	       in same_types && eq sigma' g1 g2
	     with Invalid_argument _ -> false)
    | (TypedForm (f1', _), _) -> eq sigma f1' f2
    | (_, TypedForm (f2', _)) -> eq sigma f1 f2'
    | _ -> false
  in 
  eq [] f1 f2


(** A hash table module using formulas as hash keys *)
module FormHashtbl = 
  Hashtbl.Make(struct 
    type t = form
    let equal = equal
    let hash f = Hashtbl.hash (reduce f)
  end)

(** Substituting subformulas. *)

type gsubstMap = (form * form) list

(** Naive substitution, ignores var capture.
    Substitution are tried on larger formulas first,
    and for a given formula substitutions earlier in map are tried first. *)
let rec ngsubst (m:gsubstMap) (f:form) : form = 
  if m=[] then f else
    try Util.find_map (fun (f1, f2) -> if equal f1 f then Some f2 else None) m with Not_found ->
      match f with
	| App(f1,fs) -> App(ngsubst m f1, List.map (ngsubst m) fs)
	| Binder(k,tvs,f1) ->
	    let vs = List.map fst tvs in
	    let not_bound (f_r,_) = 	      
	      List.for_all (fun x -> not (List.mem x (fv f_r))) vs in
	    let m1 = List.filter not_bound m in
	      Binder(k,tvs,ngsubst m1 f1)
	| Var _ -> f
	| Const _ -> f
	| TypedForm(f1,t) -> TypedForm(ngsubst m f1,t)

(** Compute negation normal form of a formula *)
let rec negation_normal_form (f : form) : form =
  match f with
    | App(Const Not, [Const (BoolConst true)]) -> Const (BoolConst false)
    | App(Const Not, [Const (BoolConst false)]) -> Const (BoolConst true)
    | App(Const Not, [App(Const Not, [f1])]) -> negation_normal_form f1
    | App(Const Not, [Binder(Forall, til, f1)]) -> 
	Binder(Exists, til, negation_normal_form(App(Const Not, [f1])))
    | App(Const Not, [Binder(Exists, til, f1)]) ->
	Binder(Forall, til, negation_normal_form(App(Const Not, [f1])))
    | App(Const Not, [App(Const And, fs)]) ->
	smk_or
          (List.map (fun x -> negation_normal_form (App(Const Not, [x]))) fs)
    | App(Const Not, [App(Const Or, fs)]) ->
	smk_and
          (List.map (fun x -> negation_normal_form (App(Const Not, [x]))) fs)
    | App(Const Not, [App(Const Impl, [f1; f2])]) ->
	smk_and [negation_normal_form f1;
                 negation_normal_form (mk_not f2)]
    | App(Const Not, [App(Const Iff, [f1; f2])]) ->
	let f3 = App(Const Impl, [f1; f2]) in
	let f4 = App(Const Impl, [f2; f1]) in
	  negation_normal_form (App(Const Not, [App(Const And, [f3; f4])]))
    | App(Const Not, [App(Const Eq, [Const (BoolConst true); f0])])
    | App(Const Not, [App(Const Eq, [f0; Const (BoolConst true)])])
    | App(Const Eq, [Const (BoolConst false); f0])
    | App(Const Eq, [f0; Const (BoolConst false)]) ->
	negation_normal_form (App(Const Not, [f0]))
    | App(Const Not, [App(Const Eq, [Const (BoolConst false); f0])])
    | App(Const Not, [App(Const Eq, [f0; Const (BoolConst false)])])
    | App(Const Eq, [Const (BoolConst true); f0])
    | App(Const Eq, [f0; Const (BoolConst true)]) ->
	negation_normal_form f0
    | App(Const GtEq, [f1; f0])
    | App(Const Not, [App(Const Gt, [f0; f1])])
    | App(Const Not, [App(Const Lt, [f1; f0])]) ->
	App(Const LtEq, [negation_normal_form f0; negation_normal_form f1])
    | App(Const Gt, [f1; f0])
    | App(Const Not, [App(Const GtEq, [f0; f1])])
    | App(Const Not, [App(Const LtEq, [f1; f0])]) ->
	App(Const Lt, [negation_normal_form f0; negation_normal_form f1])
    | App(Const Impl, [f1; f2]) ->
	App(Const Or, [negation_normal_form(App(Const Not, [f1]));
                       negation_normal_form f2])
    | App(Const Iff, [f1; f2]) ->
	negation_normal_form (App(Const And, [App(Const Impl, [f1; f2]); 
                                              App(Const Impl, [f2; f1])]))
    (* | App(Const Ite, _) ->
	failwith ("negation_normal_form: Can't handle " ^ (PrintForm.string_of_form f)) *)
    | App(f1, fs) -> 
	App((negation_normal_form f1), (List.map negation_normal_form fs))
    | Binder(b, til, f) -> Binder(b, til, (negation_normal_form f))
    | TypedForm(f, ty) -> TypedForm (negation_normal_form f, ty) 
    | _ -> f

(** Apply substitutions to a formula in appropriate order,
    assuming they are acyclic.  Used to apply shorthands and variable definitions. *)
let apply_defs 
    (defs : (ident * form) list)
    (f : form) : form =
  let app_to_form (id_def,f_def) f =
    subst [(id_def,f_def)] f in
  let app_to_def (id_def,f_def) (id,f) =
    (id, app_to_form (id_def,f_def) f) in
  let good_def (id,fid) = not (List.mem id (fv fid)) in
  let rec appdef defs f =
    match defs with
      | [] -> f
      | (id,fid)::defs1 ->
	  if List.mem id (fv f) then
	    if good_def (id,fid) then
	      (debug_msg ("*** FormUtil.apply_defs: expanding " ^ id ^ "\n");
	       appdef 		  
		 (List.map (app_to_def (id,fid)) defs1)
		 (app_to_form (id,fid) f))
            else
	      (Util.warn ("Cycle in definitions:\n  " ^ id ^ " == " ^
			    PrintForm.string_of_form fid);
	       f)
	  else (debug_msg ("apply_defs: no ocurrences of " ^ id ^ ".\n");
		appdef defs1 f)
  in
  let _ = debug_msg ("Before apply_defs: " ^ PrintForm.string_of_form f ^ "\n DEFS:") in
  let _ = List.iter (fun (id,f) -> debug_msg (id ^ " ")) defs in
  let _ = debug_msg "\n"; flush_all() in
  let f1 = appdef defs f in
  let _ = debug_msg ("After apply_defs: " ^ PrintForm.string_of_form f1 ^ "\n") in
    appdef defs f

(*
let apply_defs_possibly_old
    (defs : (ident * form) list)
    (f : form) : form =
  let make_old ((id,f1):(ident * form)) : (ident * form) =
    (oldname id, oldify true (fv f1) f1) in
  let defs1 = List.map make_old defs in
    apply_defs (defs1 @ defs) f
*)

(* Conjoin definitions of variables on which formula depends.
let conjoin_defs
    (defs : (ident * form) list)
    (f : form) : form =
  let app_to_form (id_def,f_def) f =
    subst [(id_def,f_def)] f in
  let app_to_def (id_def,f_def) (id,f) =
    (id, app_to_form (id_def,f_def) f) in
  let good_def (id,fid) = not (List.mem id (fv fid)) in
  let def_to_eq (id,fid) = mk_eq(mk_var id,fid) in
  let rec get_fresh_sub
      (defs : (ident * form) list)
      (sub : (ident * form) list) : (ident * form) list =
    match defs with
      | [] -> sub
      | ((id,f)::defs1) ->
	  (let id_f = Util.fresh_name id in
	     get_fresh_sub defs1 ((id,mk_var id_f)::sub))
  in
  let rec condef defs to_reconsider fvs fdefs =
    match defs with
      | [] -> 
	  (let sub = get_fresh_sub fdefs [] in
	   let f1 = smk_impl(smk_and (List.map def_to_eq fdefs),f) in
	     subst sub f1
	  )
      | (id,fid)::defs1 ->
	  if List.mem id fvs then
	    (debug_msg ("*** FormUtil.apply_defs: expanding " ^ id ^ "\n");
	     condef
	       (defs1 @ to_reconsider)
	       []
	       ((fv fid) @ (Util.difference fvs [id]))
	       ((id,fid)::fdefs))
	  else (debug_msg ("apply_defs: no ocurrences of " ^ id ^ ".\n");
		condef defs1 to_reconsider fvs fdefs)
  in
  let _ = debug_lmsg 0 (fun () -> "Before conjoin_defs: " ^ PrintForm.string_of_form f ^ "\n DEFS:") in
  let _ = List.iter (fun (id,f) -> debug_msg (id ^ " ")) defs in
  let _ = debug_msg "\n"; flush_all() in
  let f1 = condef defs [] (fv f) [] in
  let _ = debug_lmsg 0 (fun () -> "After conjoin_defs: " ^ PrintForm.string_of_form f1 ^ "\n") in
   f1

let conjoin_defs_possibly_old
    (defs : (ident * form) list)
    (f : form) : form =
  let make_old ((id,f1):(ident * form)) : (ident * form) =
    (oldname id, oldify true (fv f1) f1) in
  let defs1 = List.map make_old defs in
    conjoin_defs (defs1 @ defs) f
*)

let points_to_name = "pointsto"
let points_to_name_f = mk_var points_to_name

let mk_points_to (a : form) (f : form) (b : form) : form =
  App(points_to_name_f, [a; f; b])

let mk_points_to_expansion : form -> form -> form -> form =
  let xid = Util.fresh_name "x" in
  let xvar = mk_var xid in
  fun (a : form) (f : form) (b : form) ->
    mk_forall(xid,mk_object_type,
	      mk_impl(mk_elem(xvar,a),
		      mk_elem(mk_fieldRead f xvar, b)))

(** Eliminate quantifiers and minimize scopes *)
let elim_quants f =
  let rec split_conjuncts f =
    match f with
    | App (Const And, fs) | App (Const MetaAnd, fs) -> 
	List.concat (List.rev_map split_conjuncts fs)
    | _ -> [f]
  in
  let elim_vars candidates fs =
    let rec elim fs fs' sigma =
      let substitute (v, t as sb) fs fs' sigma =
	let sub = subst [sb] in
	elim (List.map sub fs) (List.map sub fs') (sb :: List.map (fun (v, t) -> (v, sub t)) sigma)
      in
      match fs with
      | [] -> fs', sigma
      | f::fs ->
	  match normalize 2 f with
	  | App (Const Eq, [Var v1; Var v2]) 
	  | App (Const Seteq, [Var v1; Var v2]) ->
	      if List.mem v2 candidates then
		substitute (v2, Var v1) fs fs' sigma
	      else if List.mem v1 candidates then
		substitute (v1, Var v2) fs fs' sigma
	      else elim fs (f::fs') sigma
	  | App (Const Eq, [Const (BoolConst true); rhs])
	  | App (Const Eq, [rhs; Const (BoolConst true)]) ->
	      elim (rhs::fs) fs' sigma
	  | App (Const Eq, [Var v; rhs])
	  | App (Const Eq, [rhs; Var v])
	  | App (Const Seteq, [rhs; Var v])
	  | App (Const Seteq, [Var v; rhs])
	  | App (Const Iff, [Var v; rhs])
	  | App (Const Iff, [rhs; Var v])
	    when List.mem v candidates && not (List.mem v (fv rhs)) ->
	      substitute (v, rhs) fs fs' sigma
	  | Var v when List.mem v candidates ->
	      substitute (v, mk_true) fs fs' sigma
	  | App (Const Not, [Var v]) when List.mem v candidates ->
	      substitute (v, mk_false) fs fs' sigma
	  | _ -> elim fs (f::fs') sigma
    in elim fs [] []
  in
  let rec minimize f =
    match f with
    | Const _ | Var _ -> f 
    | App (f0, args) -> 
	App (minimize f0, List.map minimize args)
    | Binder (Comprehension as b, vs, f0)
    | Binder (Lambda as b, vs, f0) -> 
	Binder (b, vs, minimize f0)
    | Binder (Forall, vs, f0) ->
	(match f0 with 
	| App (Const Impl, [f;g])
	| App (Const MetaImpl, [f;g]) ->
	    let fs', sigma = elim_vars (List.rev_map fst vs) (split_conjuncts f) in
	    smk_foralls (vs, minimize (smk_impl (smk_and fs', subst sigma g)))
	| App (Const And, fs) ->
	    smk_and (List.rev_map (fun f -> minimize (mk_foralls (vs, f))) fs)
	| _ -> smk_foralls (vs, minimize f0))
    | Binder (Exists, vs, f0) ->
	(match f0 with
	| App (Const Or, fs) ->
	    smk_or (List.rev_map (fun f -> minimize (mk_existses (vs, f))) fs)
	| _ ->
	    let fs, _ = elim_vars (List.rev_map fst vs) (split_conjuncts f0) in
	    smk_exists (vs, minimize (smk_and fs)))
    | TypedForm (f0, ty) -> TypedForm (minimize f0, ty)
  in minimize f

(** Eliminate free variables (substitute definition equality assumptions) *)
let elim_free_vars keep_bool ?(keep_bool_defs=false) ?(avoid_subst=[]) prefered ((fs, g) : sequent) : sequent * substMap =
  let rec elimfree fs fs' sigma fvs evs =
    let substitute (v, t as sb) fs acc sigma new_fvs =
      let sub = subst [sb] in
      let sigma' = sb :: 
	if List.mem v fvs then
	  List.rev_map (fun (v, t) -> (v, sub t)) sigma 
	else sigma 
      in
      let acc' = List.map sub acc in
      elimfree fs acc' sigma' new_fvs (v :: evs)
    in
    match fs with
    | [] -> (fs', subst sigma g), sigma
    | f::fs ->
	let f = 
	  let fv_f = fv f in
	  if Util.disjoint fv_f evs then f 
	  else subst sigma f 
	in
	match normalize 2 f with
	| App (Const Eq, [Const (BoolConst true); rhs])
	| App (Const Eq, [rhs; Const (BoolConst true)]) ->
	    elimfree (rhs::fs) fs' sigma fvs evs
(*	| App (Const Eq, [Const (BoolConst false); rhs])
	| App (Const Eq, [rhs; Const (BoolConst false)]) ->
	    elimfree ((mk_not rhs)::fs) fs' g' sigma*)
	| App (Const Eq, [Var v1; Var v2]) ->
	    if not (List.mem v2 prefered) then
	      substitute (v1, Var v2) fs fs' sigma (Util.union [v2] fvs)
	    else substitute (v2, Var v1) fs fs' sigma (Util.union [v1] fvs)
	| App (Const Eq, [Var v; rhs])
	| App (Const Eq, [rhs; Var v])
	| App (Const Seteq, [rhs; Var v])
	| App (Const Seteq, [Var v; rhs]) ->
	    let fv_rhs = fv rhs in
	    if Util.disjoint (v::avoid_subst) fv_rhs &&
	      (List.mem v prefered ||  not (List.exists (fun v -> List.mem v fv_rhs) prefered))
	    then substitute (v, rhs) fs fs' sigma (Util.union fv_rhs fvs)
	    else elimfree fs (f :: fs') sigma fvs evs
	| App (Const Iff, [Var v; rhs])
	| App (Const Iff, [rhs; Var v]) ->
	    let fv_rhs = fv rhs in
	    if not keep_bool_defs &&
	      Util.disjoint (v::avoid_subst) fv_rhs && 
	      (List.mem v prefered || 
	      not (List.exists (fun v -> List.mem v fv_rhs) prefered)) 
	    then substitute (v, rhs) fs fs' sigma (Util.union fv_rhs fvs)
	    else elimfree fs (f::fs') sigma fvs evs
	| Var v when not keep_bool -> 
	    substitute (v, mk_true) fs fs' sigma fvs 
	| App (Const Not, [Var v]) when not keep_bool -> 
	    substitute (v, mk_false) fs fs' sigma fvs 
	| _ -> elimfree fs (f::fs') sigma fvs evs
  in elimfree fs [] [] [] []


let elim_fv_in_seq keep_bool ?(keep_bool_defs=false) (s : sequent) : sequent = 
  fst (elim_free_vars keep_bool ~keep_bool_defs [] s)

(** Names of variables used as constants. *)
let str_rtrancl = "rtrancl_pt"
let str_trancl = "trancl_pt"
let str_tree = "tree"
let str_ptree = "ptree"

(** Types of some of the pseudoconstants. *)
let typeOf_pseudoconst_rtrancl = mk_fun_type [mk_fun_type [mk_object_type; mk_object_type] mk_bool_type; mk_object_type; mk_object_type] mk_bool_type
let typeOf_pseudoconst_tree = mk_fun_type [mk_list_type (mk_field_type mk_object_type)] mk_bool_type
let typeOf_pseudoconst_ptree = mk_fun_type [mk_field_type mk_object_type; mk_list_type (mk_field_type mk_object_type)] mk_bool_type

let pseudo_constants = [str_rtrancl; str_tree; str_ptree]
let pseudo_constants_with_types = [(str_rtrancl,typeOf_pseudoconst_rtrancl); (str_tree,typeOf_pseudoconst_tree); (str_ptree,typeOf_pseudoconst_ptree)]

(** field constraints *)

let field_constraint f = 
  match normalize 5 f with
  | Binder (Forall, [(x1, _) as v1; (y1, _) as v2], 
	    App(Const Impl, [App (Const Eq, [App (Var fld, [Var x2]); Var y2]); _]))
  | Binder (Forall, [(x1, _) as v1; (y1, _) as v2], 
	    App(Const Impl, [App (Const Eq, [App (Const FieldRead, [Var fld; Var x2]); Var y2]); _]))
  | Binder (Forall, [(x1, _) as v1; (y1, _) as v2], 
	    App(Const Iff, [App (Const Eq, [App (Var fld, [Var x2]); Var y2]); _]))
  | Binder (Forall, [(x1, _) as v1; (y1, _) as v2], 
	    App(Const Iff, [App (Const Eq, [App (Const FieldRead, [Var fld; Var x2]); Var y2]); _]))
    when x1 = x2 && y1 = y2 ->
      (match f with
      |	Binder (Forall, _, App(Const Impl, [_; fld_def])) 
      |	App (Const Comment, [_; Binder (Forall, _, App(Const Impl, [_; fld_def]))]) -> Some (fld, v1, v2, fld_def)
      |	_ -> None)
  | _ -> None

let is_tree_constraint f =
  match normalize 3 f with
  | App (Var p, [App (Const ListLiteral, _)]) when p = str_tree -> true
  | _ -> false

let is_ptree_constraint f =
  match normalize 3 f with
  | App (Var p, [fld; App (Const ListLiteral, _)]) when p = str_ptree -> true
  | _ -> false
  
let is_field_constraint f = 
  match field_constraint f with
  | None -> false
  | Some _ -> true

let rec is_binder_free (f : form) : bool =
  match f with
    | Var _ | Const _ -> true
    | Binder(_, _, _) -> false
    | TypedForm(f0, _) -> is_binder_free f0
    | App(f0, fs) -> 
	is_binder_free f0 && List.for_all is_binder_free fs

(** constructor for rtrancl_pt *)

let mk_rtrancl_pt =
  let x = Util.fresh_name "v" in
  let y = Util.fresh_name "v" in
  let xv = mk_var x in
  let yv = mk_var y in
  fun fields ->
    let r x y = 
      smk_or (List.rev_map (fun fld -> mk_eq (App (fld, [x]), y)) fields) 
    in
    App (Var str_rtrancl, [Binder (Lambda, [(x, TypeUniverse);(y, TypeUniverse)], r xv yv)])

(** Abstract away given constructs to prevent reasoner from getting confused. *)
(*
let abstract_constructs (constrs : string list) (f0 : form) : form =
  let rec abst f =
    match f with
      | App(Var v,f1) when List.mem v constrs ->
	  let fvs = fv (mk_and f1) in
	  let unv = Util.fresh_name v in
	    App(Var unv,List.map mk_var fvs)
      | App(TypedForm(Var v,t),f1) when List.mem v constrs ->
	  let fvs = fv (mk_and f1) in
	  let unv = Util.fresh_name v in
	    App(TypedForm(Var unv,t),List.map mk_var fvs)
      | App(Const c,f1) when List.mem (string_of_const c) constrs ->
	  let fvs = fv (mk_and f1) in
	  let unv = Util.fresh_name (string_of_const c) in
	    App(Var unv,List.map mk_var fvs)
      | App(TypedForm(Const c,t),f1) when List.mem (string_of_const c) constrs ->
	  let fvs = fv (mk_and f1) in
	  let unv = Util.fresh_name (string_of_const c) in
	    App(TypedForm(Var unv,t),List.map mk_var fvs)
      | App(f1,f2) -> App(abst f1, List.map abst f2)
      | Var _ -> f
      | Const _ -> f
      | Binder(k,tvs,f1) -> Binder(k,tvs,abst f1)
      | TypedForm(f1,t) -> TypedForm(abst f1,t)
  in
  abst f0
*)

(* Improved version of abstract_constructs. Allows abstraction of partially applied functions and uses common subterm replacement. *)
(** [smart_abstract_construct [(s_1,n_1);...;(s_k,n_k)] f]
    replaces in the formula f the terms (s_1 t_{1,1} ... t_{1,n_1}), ... , (s_k t_{k,1} ... t_{k,n_k}) by fresh symbols. 
    Equal terms are replaced by equal symbols. *)
let smart_abstract_constructs (constrs : (form * int) list) (f0 : form) : form =
  let replace_map = FormHashtbl.create 0 in
  let rec consume i acc ts tys_opt =
    if i = 0 then (List.rev acc, ts, tys_opt) else
    match ts with
    | t::ts -> consume (i - 1) (t::acc) ts (Util.some_apply List.tl tys_opt)
    | _ -> (List.rev acc, ts, tys_opt)
  in
  let replace (f : form) (fs : form list) (bv : ident list) =
    let key = (App (f, fs)) in
    try FormHashtbl.find replace_map key 
    with Not_found ->
      let fvs = List.flatten (List.map fv fs) in
      let ids = List.filter (fun x -> List.mem x fvs) bv in
      let args = List.map mk_var ids in
      let newv = mk_var (Util.fresh_name "v_") in
      let f' = if args = [] then newv else App(newv, args) in
      FormHashtbl.add replace_map key f'; f'
  in
  let rec abst (bv : ident list) (f : form) : form =
    match f with
    | Const _ 
    | Var _  ->
	if List.exists (fun (f', _) -> f' = f) constrs 
	then replace f [] bv
	else f
    | App (TypedForm (f1, ty), fs) when
	List.exists (function (f', _) -> f1 = f') constrs 
      ->
	let tys, res_ty = match normalize_type ty with
	| TypeFun (tys, res_ty) -> (tys, res_ty)
	| ty -> ([], ty)
	in
	let i = List.assoc f1 constrs in
	let consumed_fs, remaining_fs, remaining_tys =
	  consume i [] fs (Some tys)
	in 
	let f' = replace f1 consumed_fs bv in
	let ty' = normalize_type (TypeFun (Util.unsome remaining_tys, res_ty)) in
	(match remaining_fs with
	| [] -> TypedForm (f', res_ty)
	| _ -> App (TypedForm (f', ty'), List.map (abst bv) remaining_fs))
    | App (f1, fs) when 
	List.exists (function (f', _) -> f1 = f') constrs 
      ->
	let i = List.assoc f1 constrs in
	let consumed_fs, remaining_fs, _ =
	  consume i [] fs None
	in 
	let f' = replace f1 consumed_fs bv in
	(match remaining_fs with
	| [] -> f'
	| _ -> App (f', List.map (abst bv) remaining_fs))
    | App (f1, fs) ->
	App (abst bv f1, List.map (abst bv) fs)
    | Binder (b, vs, f1) ->
	let bv', _ = List.split vs in
	Binder (b, vs, abst (bv @ bv') f1)
    | TypedForm (f1, ty) ->
	TypedForm (abst bv f1, ty)
  in abst [] f0

let has_const (c : constValue) (f0 : form) : bool =
  let rec has f =
    match f with
    | Const _ -> true
    | Var _ -> false
    | TypedForm(f,t) -> has f
    | Binder(k,tvs,f1) -> has f1
    | App(f1,fs) -> hass (has f1) fs
  and hass b fs =
    if b then b
    else (match fs with
	    | [] -> false
	    | f1::fs1 -> hass (has f1) fs1)
  in has f0

let rec contains_var (f : form) (id : ident) : bool =
  match f with
    | Const _ -> false
    | Var v -> v == id
    | TypedForm(f0, _) -> contains_var f0 id
    | Binder(_, til, f0) ->
	(not (List.exists (fun (v, _) -> (v == id)) til)) &&
	  (contains_var f0 id)
    | App(f0, f1) ->
	(contains_var f0 id) || (List.exists (contains_var_rev id) f1)
and contains_var_rev (id : ident) (f : form) : bool =
  contains_var f id

let expand_function 
    (func_name : string) (** name of function to expand *)
    (expansion : form list -> form) (** mapping from arguments to function body *)
    (f0 : form) (** formula in which to replace *)
    : form = (** result *)
  let rec repl f = match f with
    | Const _ -> f
    | Var v -> (if v=func_name then expansion [] else f)
    | TypedForm(f1, t) -> TypedForm(repl f1, t)
    | Binder(b, til, f1) -> Binder(b,til,repl f1)
    | App(TypedForm(Var found_func,t),args) when found_func=func_name 
	-> expansion args
    | App(Var found_func,args) when found_func=func_name 
	-> expansion args
    | App(f1, f2) -> App(repl f1, List.map repl f2)	
  in repl f0


(** Make application, while parsing some
    predefined functions as constants *)
let parse_mk_app (f : form) (args : form list) : form =
  match f with
    | Var "intplus" -> App(Const Plus,args)
    | Var "intless" -> App(Const Lt,args)
    | _ -> App(f,args)

(** Remove comments from a formula for easier matching. *)
let rec remove_comments (f : form) : form =
  match f with
    | App(Const Comment, [_; f1]) -> remove_comments f1
    | App(f1, fs) -> App((remove_comments f1), (List.map remove_comments fs))
    | Binder(b, til, f1) -> Binder(b, til, (remove_comments f1))
    | TypedForm(f1, t1) -> TypedForm(remove_comments f1, t1)
    | _ -> f

(** Remove types from a formula for easier matching. 
    List strip types but does not dummify bound variables. *)
let rec remove_typedform (f : form) : form =
  match f with
    | App(f1, fs) -> App((remove_typedform f1), (List.map remove_typedform fs))
    | Binder(b, til, f1) -> Binder(b, til, (remove_typedform f1))
    | TypedForm(f1, t1) -> remove_typedform f1
    | _ -> f

(** Simultaneously removes types and comments. *)
let rec remove_comments_and_typedform (f : form) : form =
  match f with
    | App(Const Comment, [_; f1]) -> 
	remove_comments_and_typedform f1
    | App(f1, fs) -> 
	App((remove_comments_and_typedform f1), 
	    (List.map remove_comments_and_typedform fs))
    | Binder(b, til, f1) -> 
	Binder(b, til, (remove_comments_and_typedform f1))
    | TypedForm(f1, _) -> 
	remove_comments_and_typedform f1
    | _ -> f

(** Returns the list of conjuncts making up f. *)
let get_conjuncts (f : form) : form list =
  let rec get_conjuncts_rec (fs : form list) (f : form) : form list =
    match f with
      | TypedForm(App(Const And, fs0), _)
      | App(Const And, fs0) -> List.fold_left get_conjuncts_rec fs fs0
      | _ -> fs @ [f]
  in
    get_conjuncts_rec [] f

(** Returns the list of conjuncts making up f. *)
let get_disjuncts (f : form) : form list =
  let rec get_disjuncts_rec (fs : form list) (f : form) : form list =
    match f with
      | TypedForm(App(Const Or, fs0), _)
      | App(Const Or, fs0) -> List.fold_left get_disjuncts_rec fs fs0
      | _ -> fs @ [f]
  in
    get_disjuncts_rec [] f

(** Flattens nested and's and or's. *)
let rec flatten (f : form) : form =
  match f with
    | App(Const And, fs) ->
	smk_and (process_conjuncts fs [])
    | App(Const Or, fs) ->
	smk_or (process_disjuncts fs [])
    | App(Const Comment, [f0; f1]) ->
	App(Const Comment, [f0; (flatten f1)])
    | App(f0, fs) ->
	let f1 = flatten f0 in
	let fs0 = List.map flatten fs in
	  App(f1, fs0)
    | Binder(b, til, f0) ->
	Binder(b, til, (flatten f0))
    | TypedForm (f, tf) ->
	TypedForm ((flatten f), tf)
    | _ -> f
and process_conjuncts
    (to_process : form list) 
    (processed : form list) : form list =
  match to_process with
    | [] -> processed
    | TypedForm(App(Const And, fs0), _) :: to_process0
    | App(Const And, fs0) :: to_process0 -> 
	process_conjuncts to_process0 (processed @ fs0)
    | App(Const Comment, [f0; f1]) :: to_process0 ->
	process_conjuncts (f1 :: to_process0) processed
    | f0 :: to_process0 ->
	let f1 = flatten f0 in
	  process_conjuncts to_process0 (processed @ [f1])
and process_disjuncts
    (to_process : form list) 
    (processed : form list) : form list =
  match to_process with
    | [] -> processed
    | TypedForm(App(Const Or, fs0), _) :: to_process0
    | App(Const Or, fs0) :: to_process0 -> 
	process_disjuncts to_process0 (processed @ fs0)
    | App(Const Comment, [f0; f1]) :: to_process0 ->
	process_disjuncts (f1 :: to_process0) processed
    | f0 :: to_process0 ->
	let f1 = flatten f0 in
	  process_disjuncts to_process0 (processed @ [f1])

(** Rewrites "(a and b) or (b and c)" into "b and (a or c)". *)
let rec factor_common_conjuncts (f : form) : form =
  let is_conjunction (f : form) : bool =
    match f with
      | TypedForm(App(Const And, _), _)
      | App(Const And, _)
      | App(Const Comment, [_; App(Const And, _)]) -> true
      | _ -> false in
  let get_conjuncts (f : form) : form list =
    match f with
      | TypedForm(App(Const And, fs), _)
      | App(Const And, fs)
      | App(Const Comment, [_; App(Const And, fs)]) -> fs
      | _ -> [] in
  let in_common (fss : form list list) (f : form) : bool =
    List.for_all (fun (fs) -> List.mem f fs) fss in
  let remove_common 
      (common : form list)
      (to_filter : form list) : form list =
    List.filter (fun (f) -> (not (List.mem f common))) to_filter in
  let handle_disjuncts (disjuncts : form list) : form =
    match disjuncts with
      | d0 :: ds0  ->
	  let c0 = get_conjuncts d0 in
	  let cs0 = List.map get_conjuncts ds0 in
	  let common, not_common = List.partition (in_common cs0) c0 in
	  let cs1 = List.map (remove_common common) cs0 in
	  let conjuncts = List.map smk_and (not_common :: cs1) in
	    smk_and (common @ [smk_or conjuncts])
      | _ -> App(Const Or, disjuncts) in
    match f with
      | App(Const Or, fs) when (List.for_all is_conjunction fs) ->
	  let fs0 = List.map factor_common_conjuncts fs in
	    handle_disjuncts fs0
      | App(f0, fs) ->
	  let f1 = factor_common_conjuncts f0 in
	  let fs0 = List.map factor_common_conjuncts fs in
	    App(f1, fs0)
      | Binder(b, til, f0) ->
	  Binder(b, til, (factor_common_conjuncts f0))
      | TypedForm(f0, tf) ->
	  TypedForm((factor_common_conjuncts f0), tf)
      | _ -> f

(** Performs substitution on formulae in fs and rm according to rm, in 
   the given order.

   Example: 
     rm := [(a, b), (b, a)] 
     f := [a + b = c]
   Result: 
     b + b = c
*)
let rec substitute 
    (fs : form list)
    (rm : substMap)
    (usedMappings : substMap) : form list * substMap =
  match rm with
    | [] -> fs, usedMappings
    | mapping :: rm0 ->
	let rm1 = List.map (fun (id, f) -> (id, (subst [mapping] f))) rm0 in
	let fs0 = List.map (subst [mapping]) fs in
	  substitute fs0 rm1 (usedMappings @ [mapping])

(** This pass is for robustness. In some cases, a boolean constant may
   get parsed incorrectly as a variable. We should never really have
   variables named true or false, so this pass turns them properly into
   constants. *)
let rec sanitize_booleans (f : form) : form =
  match f with
    | Var "True" | Var "true" -> mk_true
    | Var "False" | Var "false" -> mk_false
    | App(f0, fs) -> 
	App((sanitize_booleans f0), (List.map sanitize_booleans fs))
    | Binder(b, til, f0) -> Binder(b, til, (sanitize_booleans f0))
    | TypedForm(f0, ty) -> TypedForm((sanitize_booleans f0), ty)
    | _ -> f 

let rec structural_comp (f0 : form) (f1 : form) : int =
  let binder_comp (b0 : binderKind) (b1 : binderKind) : int =
    let int_of_binder (b : binderKind) : int =
      match b with
	| Lambda -> 0
	| Forall -> 1
	| Exists -> 2
	| Comprehension -> 3
    in
      (int_of_binder b0) - (int_of_binder b1)
  in
  let const_comp (c0 : constValue) (c1 : constValue) : int =
    match c0, c1 with
      | IntConst i0, IntConst i1 -> i0 - i1
      | IntConst _, _ -> -1
      | _, IntConst _ -> 1
      | BoolConst b0, BoolConst b1 -> 
	  if b0 = b1 then 0
	  else if not b0 && b1 then -1
	  else 1
      | BoolConst _, _ -> -1
      | _, BoolConst _ -> 1
      | StringConst s0, StringConst s1 -> String.compare s0 s1
      | StringConst _, _ -> -1
      | _, StringConst _ -> 1
      | _ -> String.compare (string_of_const c0) (string_of_const c1)
  in
    match f0, f1 with
      | App(Const Comment, [_; f0']), _
      | TypedForm(f0', _), _ -> structural_comp f0' f1
      | _, App(Const Comment, [_; f1'])
      | _, TypedForm(f1', _) -> structural_comp f0 f1'
      | Binder(b0, til0, f0'), Binder(b1, til1, f1') ->
	  let bcomp = binder_comp b0 b1 in
	    if bcomp != 0 then
	      bcomp
	    else
	      let tcomp = List.length til0 - List.length til1 in
		if tcomp != 0 then
		  tcomp
		else structural_comp f0' f1'
      | Binder _, _ -> -1
      | _, Binder _ -> 1
      | App(fa0, fs0), App(fa1, fs1) ->
	  let acomp = structural_comp fa1 fa1 in
	    if acomp != 0 then
	      acomp
	    else 
	      let lcomp = List.length fs0 - List.length fs1 in
		if lcomp != 0 then
		  lcomp
		else structural_list_comp fs0 fs1
      | App _, _ -> -1
      | _, App _ -> 1
      | Const c0, Const c1 -> const_comp c0 c1
      | Const _, _ -> -1
      | _, Const _ -> 1
      | _ -> 0
and structural_list_comp (fs0 : form list) (fs1 : form list) : int =
  match fs0, fs1 with
    | (f0 :: fs0'), (f1 :: fs1') ->
	let fcomp = structural_comp f0 f1 in
	  if fcomp != 0 then
	    fcomp
	  else structural_list_comp fs0' fs1'
    | [], [] -> 0
    | _ -> failwith "structural_list_comp: lists not of equal length\n"

let rec bound_variables (ids : ident list) (f : form) : ident list =
  match f with
    | TypedForm(f0, _) -> bound_variables ids f0
    | Binder(_, til, f0) ->
	let ids0, _ = List.split til in
	let ids1 = Util.union ids ids0 in
	  bound_variables ids1 f0
    | App(f0, fs) ->
	let ids0 = bound_variables ids f0 in
	  List.fold_left bound_variables ids0 fs
    | _ -> ids

let rename_fvs (f : form) (bad_ids : ident list) : form =
  let c = ref 0 in
  let rec fresh_var (y : ident) : ident * form =
    let new_y = Printf.sprintf "y%d" !c in
      c := !c + 1;
      if List.mem new_y bad_ids then fresh_var y
      else (y, (mk_var new_y))
  in
  let sm = List.map fresh_var (fv f) in
    subst sm f

let rec remove_types (f : form) : form =
  match f with
    | App(f0, fs) ->
	let f0' = remove_types f0 in
	let fs' = List.map remove_types fs in
	  App(f0', fs')
    | TypedForm(f0, _) ->
	remove_types f0
    | Binder(b, til, f0) ->
	let til' = List.map (fun (v, _) -> (v, TypeUniverse)) til in
	let f0' = remove_types f0 in
	  Binder(b, til', f0')
    | _ -> f

let rec normalize_for_matching (f : form) (bad_ids : ident list) : form =
  let rec sort_assumptions (f : form) : form =
    match f with
      | App(Const Comment, [_; f0])
      | TypedForm(f0, _) -> sort_assumptions f0
      | App(Const MetaAnd, fs) -> 
	  let fs' = List.sort structural_comp fs in
	    App(Const MetaAnd, fs')
      | _ -> f
  in
    match f with
      | App(Const Comment, [_; f0])
      | TypedForm(f0, _) -> normalize_for_matching f0 bad_ids
      | App(Const MetaImpl, [f0; f1]) ->
	  let f0' = sort_assumptions f0 in
	  let f' = reduce (App(Const MetaImpl, [f0'; f1])) in
	    remove_types (rename_fvs f' bad_ids)
      | _ -> f

let ids_in_use (f : form) : ident list =
  bound_variables (fv f) f

(** Renames bound variables so that variable names are unique. *)
let rec unique_variables (f : form) (used : ident list) : (form * ident list) =
  let mk_binder b vt = function
    | Binder (b', vts, f) when b = b' -> Binder(b, vt :: vts, f)
    | f -> Binder (b, [vt], f)
  in
  match f with
    | Binder (b, [(i,t)], f0) ->
	if (List.mem i used) then
	  let ni = (Util.fresh_name i) in
	  let renamed = subst [(i, (Var ni))] f0 in
	  let (f1, nused) = unique_variables renamed used in
	    (Binder(b, [(ni, t)], f1), nused)
	else
	  let (f1, nused) = unique_variables f0 (i :: used) in
	  (mk_binder b (i, t) f1, nused)
    | Binder (b, (i,t) :: til, f0) ->
	if (List.exists (fun(x) -> x = i) used) then
	  let ni = (Util.fresh_name i) in
	  let renamed = subst [(i, (Var ni))] (Binder(b, til, f0)) in
	  let (f1, nused) = unique_variables renamed used in
	    (mk_binder b (ni, t) f1, nused)
	else
	  let (f1, nused) = unique_variables (Binder(b, til, f0)) (i :: used) in
	  (mk_binder b (i, t) f1, nused)
    | App (f0, fs) ->
	let (f1, used0) = unique_variables f0 used in
	let (fs1, used1) = unique_variables_list fs used0 in
	(App(f1, fs1), used1)
    | TypedForm (f,t) ->
	let (f1, used1) = unique_variables f used in (TypedForm(f1, t), used1)
    | _ -> (f, used)
and unique_variables_list 
    (fs : form list) (used : ident list) : (form list * ident list) =
  match fs with
    | [] -> (fs, used)
    | f0 :: fs0 ->
	let (f1, used0) = unique_variables f0 used in
	let (fs1, used1) = unique_variables_list fs0 used0 in
	  ((f1 :: fs1), used1)

let make_unique_variables (f : form) = 
  let (res,_) = unique_variables f (fv f) in res

(** Undo invariant quantification over all instances of class **)
let remove_forall_this (f : form) : form =
  match f with
    | Binder(Forall, [("this", _)], 
	     App(Const Impl,
		 [App(Const And, 
		      [App(Const Elem, [(Var "this"); (Var "Object.alloc")]);
		       App(Const Elem, [(Var "this"); (Var class_name)])]); 
		  f0])) -> f0 (** TODO: check that class_name is valid **)
    | _ -> f

let pr_substMap (map : substMap) =
  "[ "
  ^ (String.concat "; "
       (List.map (fun (x, y) -> x ^ "->" ^ PrintForm.string_of_form y) map))
  ^ " ]"

(** Triggers for SMT solvers *)

(* due to type checking we define smt_trigger for the different types of triggers*)
let smt_trigger_bool = "smt_trigger_bool"
let smt_trigger_obj = "smt_trigger_obj"
let smt_trigger_obj_bool = "smt_trigger_obj_bool"
let smt_trigger_bool_bool = "smt_trigger_bool_bool"
let smt_trigger = "smt_trigger"

let is_trigger v = 
  v = smt_trigger_bool ||
  v = smt_trigger_obj ||
  v = smt_trigger_obj_bool ||
  v = smt_trigger_bool_bool 
  
