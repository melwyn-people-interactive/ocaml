(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)

(* $Id$ *)

(* type 'a option = None | Some of 'a *)

(* Exceptions *)

external raise : exn -> 'a = "%raise"

let failwith s = raise(Failure s)
let invalid_arg s = raise(Invalid_argument s)

exception Exit

(* Comparisons *)

external ( = ) : 'a -> 'a -> bool = "%equal"
external ( <> ) : 'a -> 'a -> bool = "%notequal"
external ( < ) : 'a -> 'a -> bool = "%lessthan"
external ( > ) : 'a -> 'a -> bool = "%greaterthan"
external ( <= ) : 'a -> 'a -> bool = "%lessequal"
external ( >= ) : 'a -> 'a -> bool = "%greaterequal"
external compare : 'a -> 'a -> int = "%compare"

let min x y = if x <= y then x else y
let max x y = if x >= y then x else y

external ( == ) : 'a -> 'a -> bool = "%eq"
external ( != ) : 'a -> 'a -> bool = "%noteq"

(* Boolean operations *)

external not : bool -> bool = "%boolnot"
external ( & ) : bool -> bool -> bool = "%sequand"
external ( && ) : bool -> bool -> bool = "%sequand"
external ( or ) : bool -> bool -> bool = "%sequor"
external ( || ) : bool -> bool -> bool = "%sequor"

(* Integer operations *)

external ( ~- ) : int -> int = "%negint"
external ( ~+ ) : int -> int = "%identity"
external succ : int -> int = "%succint"
external pred : int -> int = "%predint"
external ( + ) : int -> int -> int = "%addint"
external ( - ) : int -> int -> int = "%subint"
external ( *  ) : int -> int -> int = "%mulint"
external ( / ) : int -> int -> int = "%divint"
external ( mod ) : int -> int -> int = "%modint"

let abs x = if x >= 0 then x else -x

external ( land ) : int -> int -> int = "%andint"
external ( lor ) : int -> int -> int = "%orint"
external ( lxor ) : int -> int -> int = "%xorint"

let lnot x = x lxor (-1)

external ( lsl ) : int -> int -> int = "%lslint"
external ( lsr ) : int -> int -> int = "%lsrint"
external ( asr ) : int -> int -> int = "%asrint"

let min_int = 1 lsl (if 1 lsl 31 = 0 then 30 else 62)
let max_int = min_int - 1

(* Floating-point operations *)

external ( ~-. ) : float -> float = "%negfloat"
external ( ~+. ) : float -> float = "%identity"
external ( +. ) : float -> float -> float = "%addfloat"
external ( -. ) : float -> float -> float = "%subfloat"
external ( *. ) : float -> float -> float = "%mulfloat"
external ( /. ) : float -> float -> float = "%divfloat"
(* external ( ** ) : float -> float -> float = "caml_power_float" "pow" "float" *)
external ( ** ) : float -> float -> float = "caml_power_float_r" "reentrant" "pow" "float"
external exp : float -> float = "caml_exp_float_r" "reentrant" "exp" "float"
external expm1 : float -> float = "caml_expm1_float_r" "reentrant" "caml_expm1" "float"
external acos : float -> float = "caml_acos_float_r" "reentrant" "acos" "float"
external asin : float -> float = "caml_asin_float_r" "reentrant" "asin" "float"
external atan : float -> float = "caml_atan_float_r" "reentrant" "atan" "float"
external atan2 : float -> float -> float = "caml_atan2_float_r" "reentrant" "atan2" "float"
external hypot : float -> float -> float
               = "caml_hypot_float_r" "reentrant" "caml_hypot" "float"
external cos : float -> float = "caml_cos_float_r" "reentrant" "cos" "float"
external cosh : float -> float = "caml_cosh_float_r" "reentrant" "cosh" "float"
external log : float -> float = "caml_log_float_r" "reentrant" "log" "float"
external log10 : float -> float = "caml_log10_float_r" "reentrant" "log10" "float"
external log1p : float -> float = "caml_log1p_float_r" "reentrant" "caml_log1p" "float"
external sin : float -> float = "caml_sin_float_r" "reentrant" "sin" "float"
external sinh : float -> float = "caml_sinh_float_r" "reentrant" "sinh" "float"
external sqrt : float -> float = "caml_sqrt_float_r" "reentrant" "sqrt" "float"
external tan : float -> float = "caml_tan_float_r" "reentrant" "tan" "float"
external tanh : float -> float = "caml_tanh_float_r" "reentrant" "tanh" "float"
external ceil : float -> float = "caml_ceil_float_r" "reentrant" "ceil" "float"
external floor : float -> float = "caml_floor_float_r" "reentrant" "floor" "float"
external abs_float : float -> float = "%absfloat"
external copysign : float -> float -> float
                  = "caml_copysign_float_r" "reentrant" "caml_copysign" "float"
external mod_float : float -> float -> float = "caml_fmod_float_r" "reentrant" "fmod" "float"
external frexp : float -> float * int = "caml_frexp_float_r" "reentrant"
external ldexp : float -> int -> float = "caml_ldexp_float_r" "reentrant"
external modf : float -> float * float = "caml_modf_float_r" "reentrant"
external float : int -> float = "%floatofint"
external float_of_int : int -> float = "%floatofint"
external truncate : float -> int = "%intoffloat"
external int_of_float : float -> int = "%intoffloat"
external float_of_bits : int64 -> float = "caml_int64_float_of_bits_r" "reentrant"
let infinity =
  float_of_bits 0x7F_F0_00_00_00_00_00_00L
let neg_infinity =
  float_of_bits 0xFF_F0_00_00_00_00_00_00L
let nan =
  float_of_bits 0x7F_F0_00_00_00_00_00_01L
let max_float =
  float_of_bits 0x7F_EF_FF_FF_FF_FF_FF_FFL
let min_float =
  float_of_bits 0x00_10_00_00_00_00_00_00L
let epsilon_float =
  float_of_bits 0x3C_B0_00_00_00_00_00_00L

type fpclass =
    FP_normal
  | FP_subnormal
  | FP_zero
  | FP_infinite
  | FP_nan
external classify_float : float -> fpclass = "caml_classify_float"

(* String operations -- more in module String *)

external string_length : string -> int = "%string_length"
external string_create : int -> string = "caml_create_string_r" "reentrant"
external string_blit : string -> int -> string -> int -> int -> unit
                     = "caml_blit_string" "noalloc"

let ( ^ ) s1 s2 =
  let l1 = string_length s1 and l2 = string_length s2 in
  let s = string_create (l1 + l2) in
  string_blit s1 0 s 0 l1;
  string_blit s2 0 s l1 l2;
  s

(* Character operations -- more in module Char *)

external int_of_char : char -> int = "%identity"
external unsafe_char_of_int : int -> char = "%identity"
let char_of_int n =
  if n < 0 || n > 255 then invalid_arg "char_of_int" else unsafe_char_of_int n

(* Unit operations *)

external ignore : 'a -> unit = "%ignore"

(* Pair operations *)

external fst : 'a * 'b -> 'a = "%field0"
external snd : 'a * 'b -> 'b = "%field1"

(* String conversion functions *)

external format_int : string -> int -> string = "caml_format_int_r" "reentrant"
external format_float : string -> float -> string = "caml_format_float_r" "reentrant"

let string_of_bool b =
  if b then "true" else "false"
let bool_of_string = function
  | "true" -> true
  | "false" -> false
  | _ -> invalid_arg "bool_of_string"

let string_of_int n =
  format_int "%d" n

external int_of_string : string -> int = "caml_int_of_string_r" "reentrant"

module String = struct
  external get : string -> int -> char = "%string_safe_get"
end

let valid_float_lexem s =
  let l = string_length s in
  let rec loop i =
    if i >= l then s ^ "." else
    match s.[i] with
    | '0' .. '9' | '-' -> loop (i + 1)
    | _ -> s
  in
  loop 0
;;

let string_of_float f = valid_float_lexem (format_float "%.12g" f);;

external float_of_string : string -> float = "caml_float_of_string_r" "reentrant"

(* List operations -- more in module List *)

let rec ( @ ) l1 l2 =
  match l1 with
    [] -> l2
  | hd :: tl -> hd :: (tl @ l2)

(* I/O operations *)

type in_channel
type out_channel

external open_descriptor_out : int -> out_channel
                             = "caml_ml_open_descriptor_out_r" "reentrant"
external open_descriptor_in : int -> in_channel = "caml_ml_open_descriptor_in_r" "reentrant"

let stdin = open_descriptor_in 0
let stdout = open_descriptor_out 1
let stderr = open_descriptor_out 2

(* General output functions *)

type open_flag =
    Open_rdonly | Open_wronly | Open_append
  | Open_creat | Open_trunc | Open_excl
  | Open_binary | Open_text | Open_nonblock

external open_desc : string -> open_flag list -> int -> int = "caml_sys_open_r" "reentrant"

let open_out_gen mode perm name =
  open_descriptor_out(open_desc name mode perm)

let open_out name =
  open_out_gen [Open_wronly; Open_creat; Open_trunc; Open_text] 0o666 name

let open_out_bin name =
  open_out_gen [Open_wronly; Open_creat; Open_trunc; Open_binary] 0o666 name

external flush : out_channel -> unit = "caml_ml_flush_r" "reentrant"

external out_channels_list : unit -> out_channel list
                           = "caml_ml_out_channels_list_r" "reentrant"

let flush_all () =
  let rec iter = function
      [] -> ()
    | a :: l -> (try flush a with _ -> ()); iter l
  in iter (out_channels_list ())

external unsafe_output : out_channel -> string -> int -> int -> unit
                       = "caml_ml_output_r" "reentrant"

external output_char : out_channel -> char -> unit = "caml_ml_output_char_r" "reentrant"

let output_string oc s =
  unsafe_output oc s 0 (string_length s)

let output oc s ofs len =
  if ofs < 0 || len < 0 || ofs > string_length s - len
  then invalid_arg "output"
  else unsafe_output oc s ofs len

external output_byte : out_channel -> int -> unit = "caml_ml_output_char_r" "reentrant"
external output_binary_int : out_channel -> int -> unit = "caml_ml_output_int_r" "reentrant"

external marshal_to_channel : out_channel -> 'a -> unit list -> unit
     = "caml_output_value_r" "reentrant"
let output_value chan v = marshal_to_channel chan v []

external seek_out : out_channel -> int -> unit = "caml_ml_seek_out_r" "reentrant"
external pos_out : out_channel -> int = "caml_ml_pos_out_r" "reentrant"
external out_channel_length : out_channel -> int = "caml_ml_channel_size_r" "reentrant"
external close_out_channel : out_channel -> unit = "caml_ml_close_channel_r" "reentrant"
let close_out oc = flush oc; close_out_channel oc
let close_out_noerr oc =
  (try flush oc with _ -> ());
  (try close_out_channel oc with _ -> ())
external set_binary_mode_out : out_channel -> bool -> unit
                             = "caml_ml_set_binary_mode"

(* General input functions *)

let open_in_gen mode perm name =
  open_descriptor_in(open_desc name mode perm)

let open_in name =
  open_in_gen [Open_rdonly; Open_text] 0 name

let open_in_bin name =
  open_in_gen [Open_rdonly; Open_binary] 0 name

external input_char : in_channel -> char = "caml_ml_input_char_r" "reentrant"

external unsafe_input : in_channel -> string -> int -> int -> int
                      = "caml_ml_input_r" "reentrant"

let input ic s ofs len =
  if ofs < 0 || len < 0 || ofs > string_length s - len
  then invalid_arg "input"
  else unsafe_input ic s ofs len

let rec unsafe_really_input ic s ofs len =
  if len <= 0 then () else begin
    let r = unsafe_input ic s ofs len in
    if r = 0
    then raise End_of_file
    else unsafe_really_input ic s (ofs + r) (len - r)
  end

let really_input ic s ofs len =
  if ofs < 0 || len < 0 || ofs > string_length s - len
  then invalid_arg "really_input"
  else unsafe_really_input ic s ofs len

external input_scan_line : in_channel -> int = "caml_ml_input_scan_line_r" "reentrant"

let input_line chan =
  let rec build_result buf pos = function
    [] -> buf
  | hd :: tl ->
      let len = string_length hd in
      string_blit hd 0 buf (pos - len) len;
      build_result buf (pos - len) tl in
  let rec scan accu len =
    let n = input_scan_line chan in
    if n = 0 then begin                   (* n = 0: we are at EOF *)
      match accu with
        [] -> raise End_of_file
      | _  -> build_result (string_create len) len accu
    end else if n > 0 then begin          (* n > 0: newline found in buffer *)
      let res = string_create (n - 1) in
      ignore (unsafe_input chan res 0 (n - 1));
      ignore (input_char chan);           (* skip the newline *)
      match accu with
        [] -> res
      |  _ -> let len = len + n - 1 in
              build_result (string_create len) len (res :: accu)
    end else begin                        (* n < 0: newline not found *)
      let beg = string_create (-n) in
      ignore(unsafe_input chan beg 0 (-n));
      scan (beg :: accu) (len - n)
    end
  in scan [] 0

external input_byte : in_channel -> int = "caml_ml_input_char_r" "reentrant"
external input_binary_int : in_channel -> int = "caml_ml_input_int_r" "reentrant"
external input_value : in_channel -> 'a = "caml_input_value_r" "reentrant"
external seek_in : in_channel -> int -> unit = "caml_ml_seek_in_r" "reentrant"
external pos_in : in_channel -> int = "caml_ml_pos_in_r" "reentrant"
external in_channel_length : in_channel -> int = "caml_ml_channel_size_r" "reentrant"
external close_in : in_channel -> unit = "caml_ml_close_channel_r" "reentrant"
let close_in_noerr ic = (try close_in ic with _ -> ());;
external set_binary_mode_in : in_channel -> bool -> unit
                            = "caml_ml_set_binary_mode"

(* Output functions on standard output *)

let print_char c = output_char stdout c
let print_string s = output_string stdout s
let print_int i = output_string stdout (string_of_int i)
let print_float f = output_string stdout (string_of_float f)
let print_endline s =
  output_string stdout s; output_char stdout '\n'; flush stdout
let print_newline () = output_char stdout '\n'; flush stdout

(* Output functions on standard error *)

let prerr_char c = output_char stderr c
let prerr_string s = output_string stderr s
let prerr_int i = output_string stderr (string_of_int i)
let prerr_float f = output_string stderr (string_of_float f)
let prerr_endline s =
  output_string stderr s; output_char stderr '\n'; flush stderr
let prerr_newline () = output_char stderr '\n'; flush stderr

(* Input functions on standard input *)

let read_line () = flush stdout; input_line stdin
let read_int () = int_of_string(read_line())
let read_float () = float_of_string(read_line())

(* Operations on large files *)

module LargeFile =
  struct
    external seek_out : out_channel -> int64 -> unit = "caml_ml_seek_out_64_r" "reentrant"
    external pos_out : out_channel -> int64 = "caml_ml_pos_out_64_r" "reentrant"
    external out_channel_length : out_channel -> int64
                                = "caml_ml_channel_size_64_r" "reentrant"
    external seek_in : in_channel -> int64 -> unit = "caml_ml_seek_in_64_r" "reentrant"
    external pos_in : in_channel -> int64 = "caml_ml_pos_in_64_r" "reentrant"
    external in_channel_length : in_channel -> int64 = "caml_ml_channel_size_64_r" "reentrant"
  end

(* References *)

type 'a ref = { mutable contents : 'a }
external ref : 'a -> 'a ref = "%makemutable"
external ( ! ) : 'a ref -> 'a = "%field0"
external ( := ) : 'a ref -> 'a -> unit = "%setfield0"
external incr : int ref -> unit = "%incr"
external decr : int ref -> unit = "%decr"

(* Formats *)
type ('a, 'b, 'c, 'd) format4 = ('a, 'b, 'c, 'c, 'c, 'd) format6

type ('a, 'b, 'c) format = ('a, 'b, 'c, 'c) format4

external format_of_string :
 ('a, 'b, 'c, 'd, 'e, 'f) format6 ->
 ('a, 'b, 'c, 'd, 'e, 'f) format6 = "%identity"

external format_to_string :
 ('a, 'b, 'c, 'd, 'e, 'f) format6 -> string = "%identity"
external string_to_format :
 string -> ('a, 'b, 'c, 'd, 'e, 'f) format6 = "%identity"

let (( ^^ ) :
      ('a, 'b, 'c, 'd, 'e, 'f) format6 ->
      ('f, 'b, 'c, 'e, 'g, 'h) format6 ->
      ('a, 'b, 'c, 'd, 'g, 'h) format6) =
  fun fmt1 fmt2 ->
    string_to_format (format_to_string fmt1 ^ "%," ^ format_to_string fmt2)
;;

let string_of_format fmt =
  let s = format_to_string fmt in
  let l = string_length s in
  let r = string_create l in
  string_blit s 0 r 0 l;
  r

(* Miscellaneous *)

external sys_exit : int -> 'a = "caml_sys_exit_r" "reentrant"

let exit_function = ref flush_all

let at_exit f =
  let g = !exit_function in
  exit_function := (fun () -> f(); g())

(* Unchanged code: *)
(* let do_at_exit () = (!exit_function) () *)

let do_at_exit () = prerr_string "[from do_at_exit]\n"; (!exit_function) ()

let exit retcode =
  do_at_exit ();
  sys_exit retcode

external register_named_value : string -> 'a -> unit
                              = "caml_register_named_value_r" "reentrant"

let _ = register_named_value "Pervasives.do_at_exit" do_at_exit
