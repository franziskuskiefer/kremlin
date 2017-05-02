(** Some of these will be filled by [Driver]. In particular, the following are
 * automatically added:
 * $krml_home/kremlib/kremlib.c is added to c_files
 * $krml_home/kremlib is added to includes
 *)
let no_prefix: string list ref = ref [ "C" ]
let add_include: string list ref = ref [ "\"kremlib.h\"" ]
let warn_error = ref "+1-2+3..8"
let tmpdir = ref "."
let includes: string list ref = ref [ "FSTAR_LIB/hyperstack" ]
let verbose = ref false
let exe_name = ref ""
let cc = ref "gcc"
let m32 = ref false
let fsopts: string list ref = ref []
let ccopts: string list ref = ref []
let ldopts: string list ref = ref []
let bundle: Bundle.t list ref = ref [ [ ], [ Bundle.Prefix [ "FStar" ] ] ]
let debug_modules: string list ref = ref []
let debug s = List.exists ((=) s) !debug_modules
let struct_passing = ref true
let anonymous_unions = ref true
let uint128 = ref true
let parentheses = ref false
let unroll_loops = ref (-1)

(* A set of extra command-line arguments one gets for free depending on the
 * value of -cc *)
let default_options () =
  (* Note: the 14.04 versions of Ubuntu rely on the presence of _BSD_SOURCE to
   * enable the macros in endian.h; future versions use _DEFAULT_SOURCE which is
   * enabled by default, it seems, but there are talks of issuing a warning if
   * _BSD_SOURCE is defined and not the newer _DEFAULT_SOURCE... *)
  let gcc_like_options = [|
    "-ccopts";
    "-Wall,-Werror,-Wno-unused-variable," ^
    "-g,-O3,-fwrapv,-D_BSD_SOURCE,-D_DEFAULT_SOURCE,-Wno-unused-but-set-variable" ^
    (if Sys.os_type = "Win32" then ",-D__USE_MINGW_ANSI_STDIO" else "") ^
    (if !parentheses then "" else ",-Wno-parentheses")
  |] in
  let gcc_options = Array.append gcc_like_options [| "-ccopt"; "-std=c11" |] in
  [
    "gcc", gcc_options;
    "clang", gcc_options;
    "g++", gcc_like_options;
    "compcert", [|
      "-warn-error"; "@6@8";
      "-fnostruct-passing"; "-fnoanonymous-unions"; "-fnouint128";
      "-ccopts"; "-g,-O3,-D_BSD_SOURCE,-D_DEFAULT_SOURCE";
    |];
    "msvc", [|
      "-warn-error"; "@8"; "-fnouint128"
    |];
    "", [| |]
  ]


(** These are modules that we want to see (because they have meaningful
 * function signatures); but do not want to compile (because they have no
 * meaning, contain only models, etc.). So instead of --no-extract'ing them, we
 * drop them at C-generation time. *)
let drop: Bundle.pat list ref =
  ref Bundle.([
    Module [ "C" ];
    Module [ "C"; "Loops" ];
    Module [ "TestLib" ];
    Module [ "FStar"; "BaseTypes"; ];
    Module [ "FStar"; "Char"; ];
    Module [ "FStar"; "Float"; ];
    Module [ "FStar"; "Heap"; ];
    Module [ "FStar"; "IO"; ];
    Module [ "FStar"; "Matrix2"; ];
    Module [ "FStar"; "Option"; ];
    Module [ "FStar"; "Squash"; ];
    Module [ "FStar"; "String"; ];
    Module [ "FStar"; "Universe"; ];
    Module [ "FStar"; "Int"; "Cast" ];
    Module [ "FStar"; "Monotonic"; "RRef" ];
    Module [ "FStar"; "Int8" ];
    Module [ "FStar"; "UInt8" ];
    Module [ "FStar"; "Int16" ];
    Module [ "FStar"; "UInt16" ];
    Module [ "FStar"; "Int31" ];
    Module [ "FStar"; "UInt31" ];
    Module [ "FStar"; "Int32" ];
    Module [ "FStar"; "UInt32" ];
    Module [ "FStar"; "Int63" ];
    Module [ "FStar"; "UInt63" ];
    Module [ "FStar"; "Int64" ];
    Module [ "FStar"; "UInt64" ];
    Module [ "FStar"; "Int128" ];
    Module [ "FStar"; "UInt128" ];
  ])
