(***********************************************************************)
(*                                                                     *)
(*                           Objective Caml                            *)
(*                                                                     *)
(*            Pierre Weis, projet Cristal, INRIA Rocquencourt          *)
(*                                                                     *)
(*  Copyright 2002 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)

(* $Id$ *)

(** Formatted input functions. *)

let bad_input ib s =
  let i = Scanning.char_count ib in
  failwith
    (Printf.sprintf
      "scanf: bad input at char number %i, while scanning %s" i s);;

let bad_input_buff ib = failwith "scanf: bad input";;

let bad_format fmt i fc =
  invalid_arg
    (Printf.sprintf
       "scanf: bad format %c, at char number %i of format %s" fc i fmt);;

(* Extracting tokens from ouput token buffer. *)
let token_int ib =
  let s = Scanning.token ib in
  try Pervasives.int_of_string s
  with Failure "int_of_string" -> bad_input ib s;;

let token_bool ib =
  match Scanning.token ib with
  | "true" -> true
  | "false" -> false
  | s -> bad_input ib ("a boolean, found " ^ s);;

let token_char ib =
  (Scanning.token ib).[0];;

let token_float ib =
  let s = Scanning.token ib in
  float_of_string s;;

let token_string = Scanning.token;;

(* To scan native ints, int32 and int64 integers.
We cannot access to convertion to from strings: Nativeint.of_string,
Int32.of_string, and Int64.of_string, since those module are not
available to scanf. However, we can bind and use the primitives that are
available in the runtime. *)

external nativeint_of_string: string -> nativeint = "nativeint_of_string";;
external int32_of_string : string -> int32 = "int32_of_string";;
external int64_of_string : string -> int64 = "int64_of_string";;

let token_nativeint ib =
  let s = Scanning.token ib in
  nativeint_of_string s;;

let token_int32 ib =
  let s = Scanning.token ib in
  int32_of_string s;;

let token_int64 ib =
  let s = Scanning.token ib in
  int64_of_string s;;

(* Scanning numbers. *)

let scan_sign max ib =
  let c = Scanning.peek_char ib in
  match c with
  | '+' -> Scanning.store_char ib c max
  | '-' -> Scanning.store_char ib c max
  | c -> max;;

(* Decimal case is optimized. *)
let rec scan_decimal_digits max ib =
  if max = 0 || Scanning.end_of_input ib then max else
  match Scanning.peek_char ib with
  | '0' .. '9' as c ->
      let max = Scanning.store_char ib c max in
      scan_decimal_digits max ib
  | c -> max;;

(* Other cases uses a predicate argument to scan_digits. *)
let rec scan_digits digitp max ib =
  if max = 0 || Scanning.end_of_input ib then max else
  match Scanning.peek_char ib with
  | c when digitp c ->
     let max = Scanning.store_char ib c max in
     scan_digits digitp max ib
  | _ -> max;;

let scan_binary_digits =
  let is_binary = function
  | '0' .. '1' -> true
  | _ -> false in
  scan_digits is_binary;;

let scan_octal_digits =
  let is_octal = function
  | '0' .. '8' -> true
  | _ -> false in
  scan_digits is_octal;;

let scan_hexadecimal_digits =
  let is_hexa = function
  | '0' .. '9' | 'a' .. 'f' -> true
  | _ -> false in
  scan_digits is_hexa;;

let scan_Hexadecimal_digits =
  let is_Hexa = function
  | '0' .. '9' | 'A' .. 'F' -> true
  | _ -> false in
  scan_digits is_Hexa;;

(* Decimal integers. *)
let scan_unsigned_decimal_int max ib =
  if max = 0 || Scanning.end_of_input ib then bad_input ib "an int" else
  scan_decimal_digits max ib;;

let scan_optionally_signed_decimal_int max ib =
  let max = scan_sign max ib in
  scan_unsigned_decimal_int max ib;;

(* Scan an unsigned integer that could be given in any (common) basis.
   If digits are prefixed by 0b for one of x, X, o, b the number is
   assumed to be written respectively in hexadecimal, hexadecimal,
   octal, or binary. *)
let scan_unsigned_int max ib =
  match Scanning.peek_char ib with
  | '0' as c ->
      let max = Scanning.store_char ib c max in
      if max = 0 || Scanning.end_of_input ib then max else
      let c = Scanning.peek_char ib in
      begin match c with
      | 'x' -> scan_hexadecimal_digits (Scanning.store_char ib c max) ib
      | 'X' -> scan_Hexadecimal_digits (Scanning.store_char ib c max) ib
      | 'o' -> scan_octal_digits (Scanning.store_char ib c max) ib
      | 'b' -> scan_binary_digits (Scanning.store_char ib c max) ib
      | c -> scan_decimal_digits max ib end
  | c -> scan_decimal_digits max ib;;

let scan_optionally_signed_int max ib =
  let max = scan_sign max ib in
  if max = 0 || Scanning.end_of_input ib then bad_input ib "an int" else
  scan_unsigned_int max ib;;

let scan_int c max ib =
  match c with
  | 'd' -> scan_optionally_signed_decimal_int max ib
  | 'i' -> scan_optionally_signed_int max ib
  | 'o' -> scan_octal_digits max ib 
  | 'u' -> scan_unsigned_decimal_int max ib
  | 'x' -> scan_hexadecimal_digits max ib
  | 'X' -> scan_Hexadecimal_digits max ib
  | c -> assert false;;

(* Scanning floating point numbers. *)
let scan_frac_part max ib = scan_unsigned_decimal_int max ib;;

let scan_exp_part max ib =
  if max = 0 || Scanning.end_of_input ib then max else
  let c = Scanning.peek_char ib in
  match c with
  | 'e' | 'E' as c ->
     scan_optionally_signed_int (Scanning.store_char ib c max) ib
  | _ -> max;;

let scan_float max ib =
  let max = scan_optionally_signed_decimal_int max ib in
  if max = 0 || Scanning.end_of_input ib then max else
  let c = Scanning.peek_char ib in
  match c with
  | '.' ->
     let max = Scanning.store_char ib c max in
     let max = scan_frac_part max ib in
     scan_exp_part max ib
  | c -> scan_exp_part max ib;;

(* Scan a regular string: it stops with a space or one of the
   characters in stp. *)
let scan_string stp max ib =
  let rec loop max =
    if max = 0 || Scanning.end_of_input ib then max else
    let c = Scanning.peek_char ib in
    if stp = [] then
      match c with
      | ' ' | '\t' | '\n' | '\r' -> max
      | c -> loop (Scanning.store_char ib c max) else
    if List.mem c stp then max else loop (Scanning.store_char ib c max) in 
  loop max;;

(* Scan a char: peek strictly one character in the input, whatsoever. *)
let scan_char max ib =
  if max = 0 || Scanning.end_of_input ib then bad_input ib "a char" else
  Scanning.store_char ib (Scanning.peek_char ib) max;;

let char_for_backslash =
  match Sys.os_type with
  | "Unix" | "Win32" | "Cygwin" ->
      begin function
      | 'n' -> '\010'
      | 'r' -> '\013'
      | 'b' -> '\008'
      | 't' -> '\009'
      | c   -> c
      end
  | "MacOS" ->
      begin function
      | 'n' -> '\013'
      | 'r' -> '\010'
      | 'b' -> '\008'
      | 't' -> '\009'
      | c   -> c
      end
  | x -> assert false;;

let char_for_decimal_code ib c0 c1 c2 =
  let c =
    100 * (int_of_char c0 - 48) + 10 * (int_of_char c1 - 48) +
    (int_of_char c2 - 48) in
  if c < 0 || c > 255
  then bad_input ib (Printf.sprintf "\\ %c%c%c" c0 c1 c2)
  else char_of_int c;;

let bad_escape c = failwith ("illegal escape character " ^ String.make 1 c);;

(* Called when encountering '\\' as starter of a char.
   Stops before the corresponding '\''. *)
let scan_backslash_char max ib =
  if max = 0 || Scanning.end_of_input ib then bad_input ib "a char" else
  let c = Scanning.peek_char ib in
  match c with
  | '\\' | '\'' | '"' | 'n' | 't' | 'b' | 'r' (* '"' helping Emacs *) ->
     Scanning.store_char ib (char_for_backslash c) max
  | '0' .. '9' as c ->
     let get_digit () =
       Scanning.next_char ib;
       let c = Scanning.peek_char ib in
       match c with
       | '0' .. '9' as c -> c
       | c -> bad_escape c in
     let c0 = c in
     let c1 = get_digit () in
     let c2 = get_digit () in
     Scanning.store_char ib (char_for_decimal_code ib c0 c1 c2) (max - 2)
  | c -> bad_escape c;;

let scan_Char max ib =
  let rec loop s max =
   if max = 0 || Scanning.end_of_input ib then bad_input ib "a char" else
   let c = Scanning.peek_char ib in
   match c, s with
   | '\'', 3 -> Scanning.next_char ib; loop 2 (max - 1)
   | '\'', 1 -> Scanning.next_char ib; max - 1
   | '\\', 2 -> Scanning.next_char ib; loop 1 (scan_backslash_char (max - 1) ib)
   | c, 2 -> loop 1 (Scanning.store_char ib c max)
   | c, _ -> bad_escape c in
  loop 3 max;;

let scan_String stp max ib =
  let rec loop s max =
    if max = 0 || Scanning.end_of_input ib then bad_input ib "a string" else
    let c = Scanning.peek_char ib in
    if stp = [] then
      match c, s with
      | '"', true (* '"' helping Emacs *) ->
         Scanning.next_char ib; loop false (max - 1)
      | '"', false (* '"' helping Emacs *) ->
         Scanning.next_char ib; max - 1
      | '\\', false ->
         Scanning.next_char ib; loop false (scan_backslash_char (max - 1) ib)
      | c, false -> loop false (Scanning.store_char ib c max)
      | c, _ -> bad_input ib (String.make 1 c) else
    if List.mem c stp then max else loop s (Scanning.store_char ib c max) in
  loop true max;;

let scan_bool max ib =
  let m =
    match Scanning.peek_char ib with
    | 't' -> 4
    | 'f' -> 5
    | _ -> 0 in
  scan_string [] (min max m) ib;;

type char_set =
   | Pos_set of string
   | Neg_set of string;;

let read_char_set fmt i =
  let lim = String.length fmt - 1 in

  let rec find_in_set i j =
    if j > lim then bad_format fmt j fmt.[lim - 1] else
    match fmt.[j] with
    | ']' -> String.sub fmt i (j - i), j
    | c -> find_in_set i (j + 1)

  and find_set_sign i =
    if i > lim then bad_format fmt i fmt.[lim - 1] else
    match fmt.[i] with
    | '^' -> let set, i = find_set (i + 1) in i, Neg_set set
    | _ -> let set, i = find_set i in i, Pos_set set

  and find_set i =
    if i > lim then bad_format fmt i fmt.[lim - 1] else
    match fmt.[i] with
    | ']' -> find_in_set i (i + 1)
    | c -> find_in_set i i in

  find_set_sign i;;

let make_setp stp char_set =
  let make_predv set =
    let v = Array.make 256 false in
    let lim = String.length set - 1 in
    let rec loop b i =
      if i <= lim then
      match set.[i] with
      | '-' when b ->
         (* if i = 0 then b is false (since the initial call is loop false 0)
          hence i >= 1 and the following is safe. *) 
          let c1 = set.[i - 1] in
          let i = i + 1 in
          if i > lim then loop false (i - 1) else
          let c2 = set.[i] in
          for j = int_of_char c1 to int_of_char c2 do v.(j) <- true done;
          loop false (i + 1)
      | c -> v.(int_of_char set.[i]) <- true; loop true (i + 1) in
    loop false 0;
    v in
  match char_set with
  | Pos_set set ->
      let v = make_predv set in
      List.iter (fun c -> v.(int_of_char c) <- false) stp;
      (fun c -> v.(int_of_char c))
  | Neg_set set ->
      let v = make_predv set in
      List.iter (fun c -> v.(int_of_char c) <- true) stp;
      (fun c -> not (v.(int_of_char c)));;

let scan_chars_in_char_set stp char_set max ib =
  let setp = make_setp stp char_set in
  let rec loop max ib =
    if max = 0 || Scanning.end_of_input ib then max else
    let c = Scanning.peek_char ib in
    if setp c then loop (Scanning.store_char ib c max) ib else max in
  loop max ib;;

let rec skip_whites ib =
  if not (Scanning.end_of_input ib) then
  match Scanning.peek_char ib with
  | ' ' | '\r' | '\t' | '\n' -> Scanning.next_char ib; skip_whites ib
  | _ -> ();;

external string_of_format : ('a, 'b, 'c) format -> string = "%identity";;

(* Main scanning function:
   it takes an input buffer, a format and a function.
   Then it scans the format and the buffer in parallel to find out
   values as specified by the format. When it founds some it applies it
   to the function f and continue. *) 
let bscanf ib (fmt : ('a, Scanning.scanbuf, 'c) format) f =
  let fmt = string_of_format fmt in
  let lim = String.length fmt - 1 in

  let return v = Obj.magic v () in
  let delay f x () = f x in
  let stack f = delay (return f) in

  let rec scan spc f i =
    if i > lim then return f else
    match fmt.[i] with
    | '%' -> scan_width spc f (i + 1)
    | '@' as t ->
        let i = i + 1 in
        if i > lim then bad_format fmt (i - 1) t else begin
        match fmt.[i] with
        | fc when Scanning.end_of_input ib -> bad_input_buff ib
        | '@' as fc when Scanning.peek_char ib = fc ->
           Scanning.next_char ib; scan spc f (i + 1)
        | fc when Scanning.peek_char ib = fc ->
           Scanning.next_char ib; scan false f (i + 1)
        | fc -> bad_input_buff ib end
    | ' ' | '\r' | '\t' | '\n' -> skip_whites ib; scan spc f (i + 1)
    | fc when Scanning.end_of_input ib -> bad_input_buff ib
    | fc when Scanning.peek_char ib = fc ->
        Scanning.next_char ib; scan spc f (i + 1)
    | fc -> bad_input_buff ib

  and scan_width spc f i =
    if i > lim then bad_format fmt i '%' else
    match fmt.[i] with
    | '0' .. '9' as c ->
         let rec read_width accu i =
           if i > lim then accu, i else
           match fmt.[i] with
           | '0' .. '9' as c ->
               let accu = 10 * accu + (int_of_char c - int_of_char '0') in
               read_width accu (i + 1)
           | _ -> accu, i in
         let max, j = read_width 0 i in
         scan_conversion spc max f j
    | _ -> scan_conversion spc max_int f i

  and scan_conversion spc max f i =
    if i > lim then bad_format fmt i fmt.[lim - 1] else
    match fmt.[i] with
    | 'c' | 'C' as conv ->
        let x = if conv = 'c' then scan_char max ib else scan_Char max ib in
        scan true (stack f (token_char ib)) (i + 1)
    | c ->
       if spc then skip_whites ib;
       match c with
       | fc when Scanning.end_of_input ib -> bad_input_buff ib
       | '%' as fc when Scanning.peek_char ib = fc ->
           Scanning.next_char ib; scan true f (i + 1)
       | '%' as fc -> bad_input_buff ib
       | 'd' | 'i' | 'o' | 'u' | 'x' | 'X' ->
           let x = scan_int c max ib in
           scan true (stack f (token_int ib)) (i + 1)
       | 'f' | 'g' | 'G' | 'e' | 'E' ->
           let x = scan_float max ib in
           scan true (stack f (token_float ib)) (i + 1)
       | 's' | 'S' as conv ->
           let i, stp = scan_stoppers (i + 1) in
           let x =
             if conv = 's'
             then scan_string stp max ib
             else scan_String stp max ib in
           scan true (stack f (token_string ib)) (i + 1)
       | 'b' ->
           let x = scan_bool max ib in
           scan true (stack f (token_bool ib)) (i + 1)
       | '[' ->
           let i, char_set = read_char_set fmt (i + 1) in
           let i, stp = scan_stoppers (i + 1) in
           let x = scan_chars_in_char_set stp char_set max ib in
           scan true (stack f (token_string ib)) (i + 1)
       | 'l' | 'n' | 'L' as t ->
           let i = i + 1 in
           if i > lim then bad_format fmt (i - 1) t else begin
           match fmt.[i] with
           | 'd' | 'i' | 'o' | 'u' | 'x' | 'X' as c ->
              let x = scan_int c max ib in
              begin match t with
              | 'l' -> scan true (stack f (token_int32 ib)) (i + 1)
              | 'L' -> scan true (stack f (token_int64 ib)) (i + 1)
              | _ -> scan true (stack f (token_nativeint ib)) (i + 1) end
           | fc -> bad_format fmt i fc end
       | 'N' ->
           let x = Scanning.char_count ib in
           scan true (stack f x) (i + 1)
       | 'r' ->
           Obj.magic (fun reader arg ->
             let x = reader ib arg in
             scan spc (stack f x) (succ i))

       | c -> bad_format fmt i c

  and scan_stoppers i =
    if i > lim then i - 1, [] else
    match fmt.[i] with
    | '@' when i < lim -> let i = i + 1 in i, [fmt.[i]]
    | _ -> i - 1, [] in

  Scanning.reset_token ib;
  scan true (fun () -> f) 0;;

let fscanf ic = bscanf (Scanning.from_channel ic);;

let scanf fmt = fscanf stdin fmt;;

let sscanf s = bscanf (Scanning.from_string s);;
