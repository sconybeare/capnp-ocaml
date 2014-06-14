(******************************************************************************
 * capnp-ocaml
 *
 * Copyright (c) 2013-2014, Paul Pelzl
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************)

(* Inspired by encoding-test.c++, as found in the capnproto source. *)

module SM = Capnp.Message.Make(Capnp.StringStorage)
module T  = Test.Make(SM)

open OUnit2


let assert_float_equal f1 f2 eps =
  let f1_abs = abs_float f1 in
  let f2_abs = abs_float f2 in
  let largest = max f1_abs f2_abs in
  let delta = abs_float (f1 -. f2) in
  assert_bool "floating point equality" (delta <= largest *. 3.0 *. eps)

let assert_float32_equal f1 f2 = assert_float_equal f1 f2 1.192092896e-07
let assert_float64_equal f1 f2 = assert_float_equal f1 f2 epsilon_float


let init_test_message (s : T.Builder.TestAllTypes.t) : unit =
  let open T.Builder.TestAllTypes in
  void_field_set s;
  bool_field_set s true;
  int8_field_set_exn s (-123);
  int16_field_set_exn s (-12345);
  int32_field_set s (-12345678l);
  int64_field_set s (-123456789012345L);
  u_int8_field_set_exn s 234;
  u_int16_field_set_exn s 45678;
  u_int32_field_set s (Uint32.of_int 3456789012);
  u_int64_field_set s (Uint64.of_string "12345678901234567890");
  float32_field_set s 1234.5;
  float64_field_set s (-123e45);
  text_field_set s "foo";
  data_field_set s "bar";
  let () =
    let sub = struct_field_init s in
    void_field_set sub;
    bool_field_set sub true;
    int8_field_set_exn sub (-12);
    int16_field_set_exn sub 3456;
    int32_field_set sub (-78901234l);
    int64_field_set sub 56789012345678L;
    u_int8_field_set_exn sub 90;
    u_int16_field_set_exn sub 1234;
    u_int32_field_set sub (Uint32.of_int 56789012);
    u_int64_field_set sub (Uint64.of_string "345678901234567890");
    float32_field_set sub (-1.25e-10);
    float64_field_set sub 345.0;
    text_field_set sub "baz";
    data_field_set sub "qux";
    let () =
      let sub_sub = struct_field_init sub in
      text_field_set sub_sub "nested";
      text_field_set (struct_field_init sub_sub) "really nested"
    in
    let () = enum_field_set sub T.Builder.TestEnum.Baz in

    let _ = void_list_set_list sub [ (); (); () ] in
    let _ = bool_list_set_array sub [| false; true; false; true; true |] in
    let _ = int8_list_set_list sub [ 12; -34; -0x80; 0x7f ] in
    let _ = int16_list_set_list sub [ 1234; -5678; -0x8000; 0x7fff ] in
    let _ = int32_list_set_list sub [ 12345678l; -90123456l; -0x80000000l; 0x7fffffffl ] in
    let _ = int64_list_set_list sub
        [ 123456789012345L; -678901234567890L; -0x8000000000000000L; 0x7fffffffffffffffL ]
    in
    let _ = u_int8_list_set_list sub [ 12; 34; 0; 0xff ] in
    let _ = u_int16_list_set_list sub [ 1234; 5678; 0; 0xffff ] in
    let _ = u_int32_list_set_list sub [
        Uint32.of_int 12345678; Uint32.of_int 90123456;
        Uint32.of_int 0; Uint32.of_string "0xffffffff";
      ]
    in
    let _ = u_int64_list_set_list sub [
        Uint64.of_string "123456789012345"; Uint64.of_string "678901234567890";
        Uint64.zero; Uint64.of_string "0xffffffffffffffff";
      ]
    in
    let _ = float32_list_set_list sub [ 0.0; 1234567.0; 1e37; -1e37; 1e-37; -1e-37 ] in
    let _ = float64_list_set_list sub
        [ 0.0; 123456789012345.0; 1e306; -1e306; 1e-306; -1e-306 ]
    in
    let _ = text_list_set_list sub [ "quux"; "corge"; "grault" ] in
    let _ = data_list_set_list sub [ "garply"; "waldo"; "fred" ] in
    let () =
      let list_builder = struct_list_init sub 3 in
      text_field_set (Capnp.Array.get list_builder 0) "x structlist 1";
      text_field_set (Capnp.Array.get list_builder 1) "x structlist 2";
      text_field_set (Capnp.Array.get list_builder 2) "x structlist 3"
    in
    let _ = enum_list_set_list sub
        [ T.Builder.TestEnum.Qux; T.Builder.TestEnum.Bar; T.Builder.TestEnum.Grault ]
    in
    ()
  in
  let () = enum_field_set s T.Builder.TestEnum.Corge in

  let _ = void_list_init s 6 in
  let _ = bool_list_set_list s [ true; false; false; true ] in
  let _ = int8_list_set_array s [| 111; -111 |] in
  let _ = int16_list_set_list s [ 11111; -11111 ] in
  let _ = int32_list_set_list s [ 111111111l; -111111111l ] in
  let _ = int64_list_set_list s [ 1111111111111111111L; -1111111111111111111L ] in
  let _ = u_int8_list_set_list s [ 111; 222 ] in
  let _ = u_int16_list_set_list s [ 33333; 44444 ] in
  let _ = u_int32_list_set_list s [ Uint32.of_int 3333333333 ] in
  let _ = u_int64_list_set_list s [ Uint64.of_string "11111111111111111111" ] in
  let _ = float32_list_set_list s [ 5555.5; infinity; neg_infinity; nan ] in
  let _ = float64_list_set_list s [ 7777.75; infinity; neg_infinity; nan ] in
  let _ = text_list_set_list s [ "plugh"; "xyzzy"; "thud" ] in
  let _ = data_list_set_list s [ "oops"; "exhausted"; "rfc3092" ] in
  let () =
    let list_builder = struct_list_init s 3 in
    text_field_set (Capnp.Array.get list_builder 0) "structlist 1";
    text_field_set (Capnp.Array.get list_builder 1) "structlist 2";
    text_field_set (Capnp.Array.get list_builder 2) "structlist 3"
  in
  let _ = enum_list_set_list s [ T.Builder.TestEnum.Foo; T.Builder.TestEnum.Garply ] in
  ()


(* Provide a signature for the TestAllTypes module which we can implement
   using either a Reader or a Builder. *)
module type TEST_ALL_TYPES = sig
  type t
  type array_t
  type 'a message_t
  type access
  type message_access
  type inner_struct_t

  val void_field_get : t -> unit
  val bool_field_get : t -> bool
  val int8_field_get : t -> int
  val int16_field_get : t -> int
  val int32_field_get : t -> int32
  val int32_field_get_int_exn : t -> int
  val int64_field_get : t -> int64
  val int64_field_get_int_exn : t -> int
  val u_int8_field_get : t -> int
  val u_int16_field_get : t -> int
  val u_int32_field_get : t -> Uint32.t
  val u_int32_field_get_int_exn : t -> int
  val u_int64_field_get : t -> Uint64.t
  val u_int64_field_get_int_exn : t -> int
  val float32_field_get : t -> float
  val float64_field_get : t -> float
  val has_text_field : t -> bool
  val text_field_get : t -> string
  val has_data_field : t -> bool
  val data_field_get : t -> string
  val has_struct_field : t -> bool
  val struct_field_get : t -> inner_struct_t
  val enum_field_get : t -> T.Reader.TestEnum.t
  val interface_field_get : t -> unit
  val has_void_list : t -> bool
  val void_list_get : t -> (access, unit, array_t) Capnp.Array.t
  val void_list_get_list : t -> unit list
  val void_list_get_array : t -> unit array
  val has_bool_list : t -> bool
  val bool_list_get : t -> (access, bool, array_t) Capnp.Array.t
  val bool_list_get_list : t -> bool list
  val bool_list_get_array : t -> bool array
  val has_int8_list : t -> bool
  val int8_list_get : t -> (access, int, array_t) Capnp.Array.t
  val int8_list_get_list : t -> int list
  val int8_list_get_array : t -> int array
  val has_int16_list : t -> bool
  val int16_list_get : t -> (access, int, array_t) Capnp.Array.t
  val int16_list_get_list : t -> int list
  val int16_list_get_array : t -> int array
  val has_int32_list : t -> bool
  val int32_list_get : t -> (access, int32, array_t) Capnp.Array.t
  val int32_list_get_list : t -> int32 list
  val int32_list_get_array : t -> int32 array
  val has_int64_list : t -> bool
  val int64_list_get : t -> (access, int64, array_t) Capnp.Array.t
  val int64_list_get_list : t -> int64 list
  val int64_list_get_array : t -> int64 array
  val has_u_int8_list : t -> bool
  val u_int8_list_get : t -> (access, int, array_t) Capnp.Array.t
  val u_int8_list_get_list : t -> int list
  val u_int8_list_get_array : t -> int array
  val has_u_int16_list : t -> bool
  val u_int16_list_get : t -> (access, int, array_t) Capnp.Array.t
  val u_int16_list_get_list : t -> int list
  val u_int16_list_get_array : t -> int array
  val has_u_int32_list : t -> bool
  val u_int32_list_get : t -> (access, Uint32.t, array_t) Capnp.Array.t
  val u_int32_list_get_list : t -> Uint32.t list
  val u_int32_list_get_array : t -> Uint32.t array
  val has_u_int64_list : t -> bool
  val u_int64_list_get : t -> (access, Uint64.t, array_t) Capnp.Array.t
  val u_int64_list_get_list : t -> Uint64.t list
  val u_int64_list_get_array : t -> Uint64.t array
  val has_float32_list : t -> bool
  val float32_list_get : t -> (access, float, array_t) Capnp.Array.t
  val float32_list_get_list : t -> float list
  val float32_list_get_array : t -> float array
  val has_float64_list : t -> bool
  val float64_list_get : t -> (access, float, array_t) Capnp.Array.t
  val float64_list_get_list : t -> float list
  val float64_list_get_array : t -> float array
  val has_text_list : t -> bool
  val text_list_get : t -> (access, string, array_t) Capnp.Array.t
  val text_list_get_list : t -> string list
  val text_list_get_array : t -> string array
  val has_data_list : t -> bool
  val data_list_get : t -> (access, string, array_t) Capnp.Array.t
  val data_list_get_list : t -> string list
  val data_list_get_array : t -> string array
  val has_struct_list : t -> bool
  val struct_list_get : t -> (access, inner_struct_t, array_t) Capnp.Array.t
  val struct_list_get_list : t -> inner_struct_t list
  val struct_list_get_array : t -> inner_struct_t array
  val has_enum_list : t -> bool
  val enum_list_get : t -> (access, T.Reader.TestEnum.t, array_t) Capnp.Array.t
  val enum_list_get_list : t -> T.Reader.TestEnum.t list
  val enum_list_get_array : t -> T.Reader.TestEnum.t array
  val has_interface_list : t -> bool
  val interface_list_get : t -> (access, unit, array_t) Capnp.Array.t
  val interface_list_get_list : t -> unit list
  val interface_list_get_array : t -> unit array
  val of_message : message_access message_t -> t
end


(* Using a two-argument functor here because the Outer module may be either
   TestAllTypes or TestDefaults (i.e. completely different structs defined in the
   schema which happen to share the same structure), but the Inner module (obtained
   via [struct_field_get] or [struct_list_get] is always a variant of TestAllTypes
   due to the way the schema was defined. *)

module Check_test_message
    (Outer : TEST_ALL_TYPES)
    (Inner : TEST_ALL_TYPES
     with type t = Outer.inner_struct_t
      and type inner_struct_t = Outer.inner_struct_t)
= struct

  let f (s : Outer.t) : unit =
    let open Outer in
    assert_equal () (void_field_get s);
    assert_equal true (bool_field_get s);
    assert_equal (-123) (int8_field_get s);
    assert_equal (-12345) (int16_field_get s);
    assert_equal (-12345678l) (int32_field_get s);
    assert_equal (-123456789012345L) (int64_field_get s);
    assert_equal 234 (u_int8_field_get s);
    assert_equal 45678 (u_int16_field_get s);
    assert_equal (Uint32.of_string "3456789012") (u_int32_field_get s);
    assert_equal (Uint64.of_string "12345678901234567890") (u_int64_field_get s);
    assert_float32_equal 1234.5 (float32_field_get s);
    assert_float64_equal (-123e45) (float64_field_get s);
    assert_equal "foo" (text_field_get s);
    assert_equal "bar" (data_field_get s);
    let () =
      let sub = struct_field_get s in
      let open Inner in
      assert_equal () (void_field_get sub);
      assert_equal true (bool_field_get sub);
      assert_equal (-12) (int8_field_get sub);
      assert_equal 3456 (int16_field_get sub);
      assert_equal (-78901234l) (int32_field_get sub);
      assert_equal 56789012345678L (int64_field_get sub);
      assert_equal 90 (u_int8_field_get sub);
      assert_equal 1234 (u_int16_field_get sub);
      assert_equal (Uint32.of_int 56789012) (u_int32_field_get sub);
      assert_equal (Uint64.of_string "345678901234567890") (u_int64_field_get sub);
      assert_float32_equal (-1.25e-10) (float32_field_get sub);
      assert_float64_equal 345.0 (float64_field_get sub);
      assert_equal "baz" (text_field_get sub);
      assert_equal "qux" (data_field_get sub);
      let () =
        let sub_sub = struct_field_get sub in
        assert_equal "nested" (text_field_get sub_sub);
        assert_equal "really nested" (text_field_get (struct_field_get sub_sub))
      in
      assert_equal T.Reader.TestEnum.Baz (enum_field_get sub);
      assert_equal [ (); (); () ] (void_list_get_list sub);
      assert_equal [ false; true; false; true; true ] (bool_list_get_list sub);
      assert_equal [ 12; -34; -0x80; 0x7f ] (int8_list_get_list sub);
      assert_equal [ 1234; -5678; -0x8000; 0x7fff ] (int16_list_get_list sub);
      assert_equal
        [12345678l; -90123456l; -0x80000000l; 0x7fffffffl]
        (int32_list_get_list sub);
      assert_equal
        [ 123456789012345L; -678901234567890L; -0x8000000000000000L; 0x7fffffffffffffffL ]
        (int64_list_get_list sub);
      assert_equal [12; 34; 0; 0xff] (u_int8_list_get_list sub);
      assert_equal [ 1234; 5678; 0; 0xffff ] (u_int16_list_get_list sub);
      assert_equal
        [ Uint32.of_string "12345678"; Uint32.of_string "90123456";
          Uint32.zero; Uint32.of_string "0xffffffff" ]
        (u_int32_list_get_list sub);
      assert_equal
        [ Uint64.of_string "123456789012345"; Uint64.of_string "678901234567890";
          Uint64.zero; Uint64.of_string "0xffffffffffffffff" ]
        (u_int64_list_get_list sub);
      assert_equal [ "quux"; "corge"; "grault" ] (text_list_get_list sub);
      assert_equal [ "garply"; "waldo"; "fred" ] (data_list_get_list sub);
      let () =
        let list_reader = struct_list_get sub in
        assert_equal 3 (Capnp.Array.length list_reader);
        assert_equal "x structlist 1" (text_field_get (Capnp.Array.get list_reader 0));
        assert_equal "x structlist 2" (text_field_get (Capnp.Array.get list_reader 1));
        assert_equal "x structlist 3" (text_field_get (Capnp.Array.get list_reader 2))
      in
      assert_equal
        [ T.Reader.TestEnum.Qux; T.Reader.TestEnum.Bar;
          T.Reader.TestEnum.Grault ]
        (enum_list_get_list sub)
    in
    assert_equal 6 (Capnp.Array.length (void_list_get s));
    assert_equal [ true; false; false; true ] (bool_list_get_list s);
    assert_equal [ 111; -111 ] (int8_list_get_list s);
    assert_equal [ 11111; -11111 ] (int16_list_get_list s);
    assert_equal [ 111111111l; -111111111l ] (int32_list_get_list s);
    assert_equal [ 1111111111111111111L; -1111111111111111111L ] (int64_list_get_list s);
    assert_equal [ 111; 222 ] (u_int8_list_get_list s);
    assert_equal [ 33333; 44444 ] (u_int16_list_get_list s);
    assert_equal [ Uint32.of_string "3333333333" ] (u_int32_list_get_list s);
    assert_equal [ Uint64.of_string "11111111111111111111" ] (u_int64_list_get_list s);
    let () =
      let list_reader = float32_list_get s in
      assert_equal 4 (Capnp.Array.length list_reader);
      assert_float32_equal 5555.5 (Capnp.Array.get list_reader 0);
      assert_equal infinity (Capnp.Array.get list_reader 1);
      assert_equal neg_infinity (Capnp.Array.get list_reader 2);
      assert_equal (Pervasives.compare nan (Capnp.Array.get list_reader 3)) 0
    in
    let () =
      let list_reader = float64_list_get s in
      assert_equal 4 (Capnp.Array.length list_reader);
      assert_float64_equal 7777.75 (Capnp.Array.get list_reader 0);
      assert_equal infinity (Capnp.Array.get list_reader 1);
      assert_equal neg_infinity (Capnp.Array.get list_reader 2);
      assert_equal (Pervasives.compare nan (Capnp.Array.get list_reader 3)) 0
    in
    assert_equal [ "plugh"; "xyzzy"; "thud" ] (text_list_get_list s);
    assert_equal [ "oops"; "exhausted"; "rfc3092" ] (data_list_get_list s);
    let () =
      let list_reader = struct_list_get s in
      let open Inner in
      assert_equal 3 (Capnp.Array.length list_reader);
      assert_equal "structlist 1" (text_field_get (Capnp.Array.get list_reader 0));
      assert_equal "structlist 2" (text_field_get (Capnp.Array.get list_reader 1));
      assert_equal "structlist 3" (text_field_get (Capnp.Array.get list_reader 2))
    in
    assert_equal [ T.Reader.TestEnum.Foo; T.Reader.TestEnum.Garply ] (enum_list_get_list s)
end

module ReaderTestAllTypes = struct
  include T.Reader.TestAllTypes
  type 'a message_t = 'a T.message_t
  type array_t = T.Reader.array_t
  type access = Test.ro
  type message_access = Test.ro
  type inner_struct_t = t
end

module Reader_check_test_message =
  Check_test_message(ReaderTestAllTypes)(ReaderTestAllTypes)

module BuilderTestAllTypes = struct
  include T.Builder.TestAllTypes
  type 'a message_t = 'a T.message_t
  type array_t = T.Builder.array_t
  type access = Test.rw
  type message_access = Test.rw
  type inner_struct_t = t
end

module Builder_check_test_message =
  Check_test_message(BuilderTestAllTypes)(BuilderTestAllTypes)

module ReaderTestDefaults = struct
  include T.Reader.TestDefaults
  type 'a message_t = 'a T.message_t
  type array_t = T.Reader.array_t
  type access = Test.ro
  type message_access = Test.ro
  type inner_struct_t = T.Reader.TestAllTypes.t
end

module Reader_check_test_defaults =
  Check_test_message(ReaderTestDefaults)(ReaderTestAllTypes)

module BuilderTestDefaults = struct
  include T.Builder.TestDefaults
  type 'a message_t = 'a T.message_t
  type array_t = T.Builder.array_t
  type access = Test.rw
  type message_access = Test.rw
  type inner_struct_t = T.Builder.TestAllTypes.t
end

module Builder_check_test_defaults =
  Check_test_message(BuilderTestDefaults)(BuilderTestAllTypes)


let test_encode_decode ctx =
  let builder = T.Builder.TestAllTypes.init_root () in
  let () = init_test_message builder in
  let () = Builder_check_test_message.f builder in
  let reader = T.Reader.TestAllTypes.of_builder builder in
  Reader_check_test_message.f reader


let test_decode_defaults ctx =
  let null_root = "\x00\x00\x00\x00\x00\x00\x00\x00" in
  let message = SM.Message.readonly (SM.Message.of_storage [ null_root ]) in
  let reader = T.Reader.TestDefaults.of_message message in
  Reader_check_test_defaults.f reader


let test_init_defaults ctx =
  let null_root = "\x00\x00\x00\x00\x00\x00\x00\x00" in
  let message = SM.Message.of_storage [ null_root ] in
  let builder = T.Builder.TestDefaults.of_message message in
  (* First pass initializes [message] with defaults *)
  let () = Builder_check_test_defaults.f builder in
  (* Second pass just reads the initialized structure *)
  let () = Builder_check_test_defaults.f builder in
  let reader = T.Reader.TestDefaults.of_builder builder in
  Reader_check_test_defaults.f reader


let test_union_encoding ctx =
  let open T.Builder.TestUnion in
  let root = init_root () in
  let union0 = union0_get root in
  assert_equal Union0.U0f0s0 (Union0.get union0);
  Union0.u0f0s1_set union0 true;
  assert_equal (Union0.U0f0s1 true) (Union0.get union0);
  Union0.u0f0s8_set_exn union0 123;
  assert_equal (Union0.U0f0s8 123) (Union0.get union0)


let init_union (setter : T.Builder.TestUnion.t -> 'a) =
  (* Use the given setter to initialize the given union field and then
     return both the location of the data that was written as well as
     the values of the four union discriminants. *)
  let builder = T.Builder.TestUnion.init_root ~message_size:1024 () in
  let _ = setter builder in
  let message = SM.Message.readonly (T.Builder.TestUnion.to_message builder) in
  let segment = SM.Message.get_segment message 0 in

  (* Find the offset of the first set bit after the union discriminants. *)
  let bit_offset =
    let starting_byte = 16 in
    let rec loop byte_ofs bit_ofs =
      if byte_ofs = SM.Segment.length segment then
        None
      else if bit_ofs = 8 then
        loop (byte_ofs + 1) 0
      else
        let byte_val = SM.Segment.get_uint8 segment byte_ofs in
        if ((1 lsl bit_ofs) land byte_val) <> 0 then
          Some ((8 * (byte_ofs - starting_byte)) + bit_ofs)
        else
          loop byte_ofs (bit_ofs + 1)
    in
    loop starting_byte 0
  in
  ([ SM.Segment.get_uint16 segment 8;
     SM.Segment.get_uint16 segment 10;
     SM.Segment.get_uint16 segment 12;
     SM.Segment.get_uint16 segment 14; ],
   bit_offset)


let test_union_layout ctx =
  let open T.Builder.TestUnion in
  assert_equal ([ 0; 0; 0; 0 ], None)
    (init_union (fun b -> Union0.u0f0s0_set (union0_get b)));
  assert_equal ([ 1; 0; 0; 0 ], Some 0)
    (init_union (fun b -> Union0.u0f0s1_set (union0_get b) true));
  assert_equal ([ 2; 0; 0; 0 ], Some 0)
    (init_union (fun b -> Union0.u0f0s8_set_exn (union0_get b) 1));
  assert_equal ([ 3; 0; 0; 0 ], Some 0)
    (init_union (fun b -> Union0.u0f0s16_set_exn (union0_get b) 1));
  assert_equal ([ 4; 0; 0; 0 ], Some 0)
    (init_union (fun b -> Union0.u0f0s32_set (union0_get b) 1l));
  assert_equal ([ 5; 0; 0; 0 ], Some 0)
    (init_union (fun b -> Union0.u0f0s64_set (union0_get b) 1L));
  assert_equal ([ 6; 0; 0; 0 ], Some 448)
    (init_union (fun b -> Union0.u0f0sp_set (union0_get b) "1"));

  assert_equal ([ 7; 0; 0; 0], None)
    (init_union (fun b -> Union0.u0f1s0_set (union0_get b)));
  assert_equal ([ 8; 0; 0; 0], Some 0)
    (init_union (fun b -> Union0.u0f1s1_set (union0_get b) true));
  assert_equal ([ 9; 0; 0; 0], Some 0)
    (init_union (fun b -> Union0.u0f1s8_set_exn (union0_get b) 1));
  assert_equal ([ 10; 0; 0; 0 ], Some 0)
    (init_union (fun b -> Union0.u0f1s16_set_exn (union0_get b) 1));
  assert_equal ([ 11; 0; 0; 0 ], Some 0)
    (init_union (fun b -> Union0.u0f1s32_set (union0_get b) 1l));
  assert_equal ([ 12; 0; 0; 0 ], Some 0)
    (init_union (fun b -> Union0.u0f1s64_set (union0_get b) 1L));
  assert_equal ([ 13; 0; 0; 0 ], Some 448)
    (init_union (fun b -> Union0.u0f1sp_set (union0_get b) "1"));

  assert_equal ([ 0; 0; 0; 0 ], None)
    (init_union (fun b -> Union1.u1f0s0_set (union1_get b)));
  assert_equal ([ 0; 1; 0; 0 ], Some 65)
    (init_union (fun b -> Union1.u1f0s1_set (union1_get b) true));
  assert_equal ([ 0; 2; 0; 0 ], Some 65)
    (init_union (fun b -> Union1.u1f1s1_set (union1_get b) true));
  assert_equal ([ 0; 3; 0; 0 ], Some 72)
    (init_union (fun b -> Union1.u1f0s8_set_exn (union1_get b) 1));
  assert_equal ([ 0; 4; 0; 0 ], Some 72)
    (init_union (fun b -> Union1.u1f1s8_set_exn (union1_get b) 1));
  assert_equal ([ 0; 5; 0; 0 ], Some 80)
    (init_union (fun b -> Union1.u1f0s16_set_exn (union1_get b) 1));
  assert_equal ([ 0; 6; 0; 0 ], Some 80)
    (init_union (fun b -> Union1.u1f1s16_set_exn (union1_get b) 1));
  assert_equal ([ 0; 7; 0; 0 ], Some 96)
    (init_union (fun b -> Union1.u1f0s32_set (union1_get b) 1l));
  assert_equal ([ 0; 8; 0; 0 ], Some 96)
    (init_union (fun b -> Union1.u1f1s32_set (union1_get b) 1l));
  assert_equal ([ 0; 9; 0; 0 ], Some 128)
    (init_union (fun b -> Union1.u1f0s64_set (union1_get b) 1L));
  assert_equal ([ 0; 10; 0; 0 ], Some 128)
    (init_union (fun b -> Union1.u1f1s64_set (union1_get b) 1L));
  assert_equal ([ 0; 11; 0; 0 ], Some 512)
    (init_union (fun b -> Union1.u1f0sp_set (union1_get b) "1"));
  assert_equal ([ 0; 12; 0; 0 ], Some 512)
    (init_union (fun b -> Union1.u1f1sp_set (union1_get b) "1"));

  assert_equal ([ 0; 13; 0; 0 ], None)
    (init_union (fun b -> Union1.u1f2s0_set (union1_get b)));
  assert_equal ([ 0; 14; 0; 0 ], Some 65)
    (init_union (fun b -> Union1.u1f2s1_set (union1_get b) true));
  assert_equal ([ 0; 15; 0; 0 ], Some 72)
    (init_union (fun b -> Union1.u1f2s8_set_exn (union1_get b) 1));
  assert_equal ([ 0; 16; 0; 0 ], Some 80)
    (init_union (fun b -> Union1.u1f2s16_set_exn (union1_get b) 1));
  assert_equal ([ 0; 17; 0; 0 ], Some 96)
    (init_union (fun b -> Union1.u1f2s32_set (union1_get b) 1l));
  assert_equal ([ 0; 18; 0; 0 ], Some 128)
    (init_union (fun b -> Union1.u1f2s64_set (union1_get b) 1L));
  assert_equal ([ 0; 19; 0; 0 ], Some 512)
    (init_union (fun b -> Union1.u1f2sp_set (union1_get b) "1"));

  assert_equal ([ 0; 0; 0; 0 ], Some 192)
    (init_union (fun b -> Union2.u2f0s1_set (union2_get b) true));
  assert_equal ([ 0; 0; 0; 0 ], Some 193)
    (init_union (fun b -> Union3.u3f0s1_set (union3_get b) true));
  assert_equal ([ 0; 0; 1; 0 ], Some 200)
    (init_union (fun b -> Union2.u2f0s8_set_exn (union2_get b) 1));
  assert_equal ([ 0; 0; 0; 1 ], Some 208)
    (init_union (fun b -> Union3.u3f0s8_set_exn (union3_get b) 1));
  assert_equal ([ 0; 0; 2; 0 ], Some 224)
    (init_union (fun b -> Union2.u2f0s16_set_exn (union2_get b) 1));
  assert_equal ([ 0; 0; 0; 2 ], Some 240)
    (init_union (fun b -> Union3.u3f0s16_set_exn (union3_get b) 1));
  assert_equal ([ 0; 0; 3; 0 ], Some 256)
    (init_union (fun b -> Union2.u2f0s32_set (union2_get b) 1l));
  assert_equal ([ 0; 0; 0; 3 ], Some 288)
    (init_union (fun b -> Union3.u3f0s32_set (union3_get b) 1l));
  assert_equal ([ 0; 0; 4; 0 ], Some 320)
    (init_union (fun b -> Union2.u2f0s64_set (union2_get b) 1L));
  assert_equal ([ 0; 0; 0; 4 ], Some 384)
    (init_union (fun b -> Union3.u3f0s64_set (union3_get b) 1L))


let test_unnamed_union_encoding ctx =
  let module R = T.Reader.TestUnnamedUnion in
  let module B = T.Builder.TestUnnamedUnion in
  let root = B.init_root () in
  assert_equal (B.Foo 0) (B.get root);

  B.bar_set_int_exn root 321;
  assert_equal (B.Bar (Uint32.of_int 321)) (B.get root);
  assert_equal (R.Bar (Uint32.of_int 321)) (R.get (R.of_builder root));

  B.foo_set_exn root 123;
  assert_equal (B.Foo 123) (B.get root);
  assert_equal (R.Foo 123) (R.get (B.to_reader root))


let test_groups ctx =
  let open T.Builder.TestGroups in
  let root = init_root () in
  let () =
    let groups = groups_get root in
    let foo = Groups.foo_init groups in
    Groups.Foo.corge_set foo 12345678l;
    Groups.Foo.grault_set foo 123456789012345L;
    Groups.Foo.garply_set foo "foobar";

    assert_equal 12345678l (Groups.Foo.corge_get foo);
    assert_equal 123456789012345L (Groups.Foo.grault_get foo);
    assert_equal "foobar" (Groups.Foo.garply_get foo)
  in
  let () =
    let groups = groups_get root in
    let bar = Groups.bar_init groups in
    Groups.Bar.corge_set bar 23456789l;
    Groups.Bar.grault_set bar "bazbaz";
    Groups.Bar.garply_set bar 234567890123456L;

    assert_equal 23456789l (Groups.Bar.corge_get bar);
    assert_equal "bazbaz" (Groups.Bar.grault_get bar);
    assert_equal 234567890123456L (Groups.Bar.garply_get bar)
  in
  let () =
    let groups = groups_get root in
    let baz = Groups.baz_init groups in
    Groups.Baz.corge_set baz 34567890l;
    Groups.Baz.grault_set baz "bazqux";
    Groups.Baz.garply_set baz "quxquux";

    assert_equal 34567890l (Groups.Baz.corge_get baz);
    assert_equal "bazqux" (Groups.Baz.grault_get baz);
    assert_equal "quxquux" (Groups.Baz.garply_get baz)
  in
  ()


let test_interleaved_groups ctx =
  let module B = T.Builder.TestInterleavedGroups in
  let module R = T.Reader.TestInterleavedGroups in
  let root = B.init_root () in

  (* Init both groups to different values. *)
  let () =
    let group = B.group1_get root in
    B.Group1.foo_set_int_exn group 12345678;
    B.Group1.bar_set group (Uint64.of_string "123456789012345");
    let corge = B.Group1.corge_init group in
    B.Group1.Corge.grault_set corge (Uint64.of_string "987654321098765");
    B.Group1.Corge.garply_set_exn corge 12345;
    B.Group1.Corge.plugh_set corge "plugh";
    B.Group1.Corge.xyzzy_set corge "xyzzy";
    B.Group1.waldo_set group "waldo"
  in
  let () =
    let group = B.group2_get root in
    B.Group2.foo_set_int_exn group 23456789;
    B.Group2.bar_set group (Uint64.of_string "234567890123456");
    let corge = B.Group2.corge_init group in
    B.Group2.Corge.grault_set corge (Uint64.of_string "876543210987654");
    B.Group2.Corge.garply_set_exn corge 23456;
    B.Group2.Corge.plugh_set corge "hgulp";
    B.Group2.Corge.xyzzy_set corge "yzzyx";
    B.Group2.waldo_set group "odlaw"
  in

  (* Verify that group 1 is still set correctly. *)
  let () =
    let group = R.group1_get (R.of_builder root) in
    assert_equal 12345678 (R.Group1.foo_get_int_exn group);
    assert_equal (Uint64.of_string "123456789012345") (R.Group1.bar_get group);
    match R.Group1.get group with
    | R.Group1.Corge corge ->
        assert_equal (Uint64.of_string "987654321098765") (R.Group1.Corge.grault_get corge);
        assert_equal 12345 (R.Group1.Corge.garply_get corge);
        assert_equal "plugh" (R.Group1.Corge.plugh_get corge);
        assert_equal "xyzzy" (R.Group1.Corge.xyzzy_get corge);
        let _ = R.Group1.has_waldo group in
        assert_equal "waldo" (R.Group1.waldo_get group)
    | _ ->
        assert_failure "Corge unexpectedly unset"
  in

  (* Zero out group 1 and verify that it is zero'd *)
  let () =
    let group = R.Group1.of_builder (B.group1_init root) in
    assert_equal Uint32.zero (R.Group1.foo_get group);
    assert_equal Uint64.zero (R.Group1.bar_get group);
    let () =
      match R.Group1.get group with
      | R.Group1.Qux x ->
          assert_equal 0 x
      | _ ->
          assert_failure "Qux unexpectedly unset"
    in
    assert_equal false (R.Group1.has_waldo group)
  in

  (* Group 2 should not have been touched *)
  let () =
    let group = R.group2_get (R.of_builder root) in
    assert_equal 23456789 (R.Group2.foo_get_int_exn group);
    assert_equal (Uint64.of_string "234567890123456") (R.Group2.bar_get group);
    match R.Group2.get group with
    | R.Group2.Corge corge ->
        assert_equal (Uint64.of_string "876543210987654") (R.Group2.Corge.grault_get corge);
        assert_equal 23456 (R.Group2.Corge.garply_get corge);
        assert_equal "hgulp" (R.Group2.Corge.plugh_get corge);
        assert_equal "yzzyx" (R.Group2.Corge.xyzzy_get corge);
        assert_equal "odlaw" (R.Group2.waldo_get group)
    | _ ->
        assert_failure "Corge unexpectedly unset"
  in
  ()


let test_union_defaults ctx =
  let module B = T.Builder.TestUnionDefaults in
  let module R = T.Reader.TestUnionDefaults in
  let reader = R.of_builder (B.init_root ()) in
  (* Note: the following code is pretty clumsy.  Seems like a getter for a named union
     field could just bypass the intermediate type? *)
  let () =
    let field = R.s16s8s64s8_set_get reader in
    let module TU = T.Reader.TestUnion in
    begin match TU.Union0.get (TU.union0_get field) with
    | TU.Union0.U0f0s16 321 ->
        ()
    | _ ->
        assert_failure "bad union0 default"
    end;
    begin match TU.Union1.get (TU.union1_get field) with
    | TU.Union1.U1f0s8 123 ->
        ()
    | _ ->
        assert_failure "bad union1 default"
    end;
    begin match TU.Union2.get (TU.union2_get field) with
    | TU.Union2.U2f0s64 12345678901234567L ->
        ()
    | _ ->
        assert_failure "bad union2 default"
    end;
    begin match TU.Union3.get (TU.union3_get field) with
    | TU.Union3.U3f0s8 55 ->
        ()
    | _ ->
        assert_failure "bad union3 default"
    end
  in
  let () =
    let field = R.s0sps1s32_set_get reader in
    let module TU = T.Reader.TestUnion in
    begin match TU.Union0.get (TU.union0_get field) with
    | TU.Union0.U0f1s0 ->
        ()
    | _ ->
        assert_failure "bad union0 default"
    end;
    begin match TU.Union1.get (TU.union1_get field) with
    | TU.Union1.U1f0sp s when s = "foo" ->
        ()
    | _ ->
        assert_failure "bad union1 default"
    end;
    begin match TU.Union2.get (TU.union2_get field) with
    | TU.Union2.U2f0s1 true ->
        ()
    | _ ->
        assert_failure "bad union2 default"
    end;
    begin match TU.Union3.get (TU.union3_get field) with
    | TU.Union3.U3f0s32 12345678l ->
        ()
    | _ -> assert_failure "bad union3 default"
    end
  in
  let () =
    let field = R.unnamed1_get reader in
    begin match T.Reader.TestUnnamedUnion.get field with
    | T.Reader.TestUnnamedUnion.Foo 123 ->
        ()
    | _ -> assert_failure "bad unnamed1 default"
    end;
    assert_equal false (T.Reader.TestUnnamedUnion.has_before field);
    assert_equal false (T.Reader.TestUnnamedUnion.has_after field);
  in
  let () =
    let field = R.unnamed2_get reader in
    begin match T.Reader.TestUnnamedUnion.get field with
    | T.Reader.TestUnnamedUnion.Bar x when x = (Uint32.of_int 321) ->
        ()
    | _ -> assert_failure "bad unnamed2 default"
    end;
    assert_equal "foo" (T.Reader.TestUnnamedUnion.before_get field);
    assert_equal "bar" (T.Reader.TestUnnamedUnion.after_get field)
  in
  ()


module type TEST_LISTS = sig
  type t
  type array_t
  type 'a message_t
  type access
  type message_access
  type test_all_types_t

  module Struct8 : sig
    type t
    val f_get : t -> int
    val of_message : message_access message_t -> t
  end
  module Struct16c : sig
    type t
    val f_get : t -> int
    val has_pad : t -> bool
    val pad_get : t -> string
    val of_message : message_access message_t -> t
  end
  module Struct64 : sig
    type t
    val f_get : t -> Uint64.t
    val f_get_int_exn : t -> int
    val of_message : message_access message_t -> t
  end
  module Struct8c : sig
    type t
    val f_get : t -> int
    val has_pad : t -> bool
    val pad_get : t -> string
    val of_message : message_access message_t -> t
  end
  module StructP : sig
    type t
    val has_f : t -> bool
    val f_get : t -> string
    val of_message : message_access message_t -> t
  end
  module Struct32c : sig
    type t
    val f_get : t -> Uint32.t
    val f_get_int_exn : t -> int
    val has_pad : t -> bool
    val pad_get : t -> string
    val of_message : message_access message_t -> t
  end
  module Struct0c : sig
    type t
    val f_get : t -> unit
    val has_pad : t -> bool
    val pad_get : t -> string
    val of_message : message_access message_t -> t
  end
  module Struct32 : sig
    type t
    val f_get : t -> Uint32.t
    val f_get_int_exn : t -> int
    val of_message : message_access message_t -> t
  end
  module StructPc : sig
    type t
    val has_f : t -> bool
    val f_get : t -> string
    val pad_get : t -> Uint64.t
    val pad_get_int_exn : t -> int
    val of_message : message_access message_t -> t
  end
  module Struct0 : sig
    type t
    val f_get : t -> unit
    val of_message : message_access message_t -> t
  end
  module Struct64c : sig
    type t
    val f_get : t -> Uint64.t
    val f_get_int_exn : t -> int
    val has_pad : t -> bool
    val pad_get : t -> string
    val of_message : message_access message_t -> t
  end
  module Struct16 : sig
    type t
    val f_get : t -> int
    val of_message : message_access message_t -> t
  end
  module Struct1c : sig
    type t
    val f_get : t -> bool
    val has_pad : t -> bool
    val pad_get : t -> string
    val of_message : message_access message_t -> t
  end
  module Struct1 : sig
    type t
    val f_get : t -> bool
    val of_message : message_access message_t -> t
  end
  val has_list0 : t -> bool
  val list0_get : t -> (access, Struct0.t, array_t) Capnp.Array.t
  val list0_get_list : t -> Struct0.t list
  val list0_get_array : t -> Struct0.t array
  val has_list1 : t -> bool
  val list1_get : t -> (access, Struct1.t, array_t) Capnp.Array.t
  val list1_get_list : t -> Struct1.t list
  val list1_get_array : t -> Struct1.t array
  val has_list8 : t -> bool
  val list8_get : t -> (access, Struct8.t, array_t) Capnp.Array.t
  val list8_get_list : t -> Struct8.t list
  val list8_get_array : t -> Struct8.t array
  val has_list16 : t -> bool
  val list16_get : t -> (access, Struct16.t, array_t) Capnp.Array.t
  val list16_get_list : t -> Struct16.t list
  val list16_get_array : t -> Struct16.t array
  val has_list32 : t -> bool
  val list32_get : t -> (access, Struct32.t, array_t) Capnp.Array.t
  val list32_get_list : t -> Struct32.t list
  val list32_get_array : t -> Struct32.t array
  val has_list64 : t -> bool
  val list64_get : t -> (access, Struct64.t, array_t) Capnp.Array.t
  val list64_get_list : t -> Struct64.t list
  val list64_get_array : t -> Struct64.t array
  val has_list_p : t -> bool
  val list_p_get : t -> (access, StructP.t, array_t) Capnp.Array.t
  val list_p_get_list : t -> StructP.t list
  val list_p_get_array : t -> StructP.t array
  val has_int32_list_list : t -> bool
  val int32_list_list_get : t -> (access, (access, int32, array_t) Capnp.Array.t, array_t) Capnp.Array.t
  val int32_list_list_get_list : t -> (access, int32, array_t) Capnp.Array.t list
  val int32_list_list_get_array : t -> (access, int32, array_t) Capnp.Array.t array
  val has_text_list_list : t -> bool
  val text_list_list_get : t -> (access, (access, string, array_t) Capnp.Array.t, array_t) Capnp.Array.t
  val text_list_list_get_list : t -> (access, string, array_t) Capnp.Array.t list
  val text_list_list_get_array : t -> (access, string, array_t) Capnp.Array.t array
  val has_struct_list_list : t -> bool
  val struct_list_list_get : t -> (access, (access, test_all_types_t, array_t) Capnp.Array.t, array_t) Capnp.Array.t
  val struct_list_list_get_list : t -> (access, test_all_types_t, array_t) Capnp.Array.t list
  val struct_list_list_get_array : t -> (access, test_all_types_t, array_t) Capnp.Array.t array
  val of_message : message_access message_t -> t
end



let init_list_defaults (lists : T.Builder.TestLists.t) =
  let open T.Builder.TestLists in

  (* FIXME: skipping list0 and list1... at present we don't support encoding
     lists of single field structs of Void or Bool as List<Void>/List<Bool>. *)

  (*
  let list0  = list0_init lists 2 in
  let list1  = list1_init lists 4 in
  *)
  let list8  = list8_init lists 2 in
  let list16 = list16_init lists 2 in
  let list32 = list32_init lists 2 in
  let list64 = list64_init lists 2 in
  let listp  = list_p_init lists 2 in

  (*
  Struct0.f_set (Capnp.Array.get list0 0);
  Struct0.f_set (Capnp.Array.get list0 1);
  Struct1.f_set (Capnp.Array.get list1 0) true;
  Struct1.f_set (Capnp.Array.get list1 1) false;
  Struct1.f_set (Capnp.Array.get list1 2) true;
  Struct1.f_set (Capnp.Array.get list1 3) true;
  *)
  Struct8.f_set_exn (Capnp.Array.get list8 0) 123;
  Struct8.f_set_exn (Capnp.Array.get list8 1) 45;
  Struct16.f_set_exn (Capnp.Array.get list16 0) 12345;
  Struct16.f_set_exn (Capnp.Array.get list16 1) 6789;
  Struct32.f_set (Capnp.Array.get list32 0) (Uint32.of_int 123456789);
  Struct32.f_set (Capnp.Array.get list32 1) (Uint32.of_int 234567890);
  Struct64.f_set (Capnp.Array.get list64 0) (Uint64.of_string "1234567890123456");
  Struct64.f_set (Capnp.Array.get list64 1) (Uint64.of_string "2345678901234567");
  StructP.f_set (Capnp.Array.get listp 0) "foo";
  StructP.f_set (Capnp.Array.get listp 1) "bar";

  let () =
    let a = int32_list_list_init lists 3 in
    Capnp.Array.set_list (Capnp.Array.get a 0) [ 1l; 2l; 3l ];
    Capnp.Array.set_list (Capnp.Array.get a 1) [ 4l; 5l ];
    Capnp.Array.set_list (Capnp.Array.get a 2) [ 12341234l ]
  in
  let () =
    let a = text_list_list_init lists 3 in
    Capnp.Array.set_array (Capnp.Array.get a 0) [| "foo"; "bar" |];
    Capnp.Array.set_array (Capnp.Array.get a 1) [| "baz" |];
    Capnp.Array.set_array (Capnp.Array.get a 2) [| "qux"; "corge" |]
  in
  let () =
    let a = struct_list_list_init lists 2 in
    let () =
      let a0 = Capnp.Array.get a 0 in
      Capnp.Array.init a0 2;
      T.Builder.TestAllTypes.int32_field_set (Capnp.Array.get a0 0) 123l;
      T.Builder.TestAllTypes.int32_field_set (Capnp.Array.get a0 1) 456l
    in
    let () =
      let a1 = Capnp.Array.get a 1 in
      Capnp.Array.init a1 1;
      T.Builder.TestAllTypes.int32_field_set (Capnp.Array.get a1 0) 789l
    in
    ()
  in
  ()


module Check_test_list
    (TL : TEST_LISTS)
    (TAT : TEST_ALL_TYPES with type t = TL.test_all_types_t)
= struct
  let f (lists : TL.t) =

    (* FIXME: skipping list0 and list1... at present we don't support encoding
       lists of single field structs of Void or Bool as List<Void>/List<Bool>. *)

    (*
    assert_equal 2 (Capnp.Array.length (TL.list0_get lists));
    assert_equal 4 (Capnp.Array.length (TL.list1_get lists));
    *)
    assert_equal 2 (Capnp.Array.length (TL.list8_get lists));
    assert_equal 2 (Capnp.Array.length (TL.list16_get lists));
    assert_equal 2 (Capnp.Array.length (TL.list32_get lists));
    assert_equal 2 (Capnp.Array.length (TL.list64_get lists));
    assert_equal 2 (Capnp.Array.length (TL.list_p_get lists));

    (*
    assert_equal () (TL.Struct0.f_get (Capnp.Array.get (TL.list0_get lists) 0));
    assert_equal () (TL.Struct0.f_get (Capnp.Array.get (TL.list0_get lists) 1));
    assert_equal true  (TL.Struct1.f_get (Capnp.Array.get (TL.list1_get lists) 0));
    assert_equal false (TL.Struct1.f_get (Capnp.Array.get (TL.list1_get lists) 1));
    assert_equal true  (TL.Struct1.f_get (Capnp.Array.get (TL.list1_get lists) 2));
    assert_equal true  (TL.Struct1.f_get (Capnp.Array.get (TL.list1_get lists) 3));
    *)
    assert_equal 123 (TL.Struct8.f_get (Capnp.Array.get (TL.list8_get lists) 0));
    assert_equal 45  (TL.Struct8.f_get (Capnp.Array.get (TL.list8_get lists) 1));
    assert_equal 12345 (TL.Struct16.f_get (Capnp.Array.get (TL.list16_get lists) 0));
    assert_equal 6789  (TL.Struct16.f_get (Capnp.Array.get (TL.list16_get lists) 1));
    assert_equal (Uint32.of_int 123456789)
      (TL.Struct32.f_get (Capnp.Array.get (TL.list32_get lists) 0));
    assert_equal (Uint32.of_int 234567890)
      (TL.Struct32.f_get (Capnp.Array.get (TL.list32_get lists) 1));
    assert_equal (Uint64.of_string "1234567890123456")
      (TL.Struct64.f_get (Capnp.Array.get (TL.list64_get lists) 0));
    assert_equal (Uint64.of_string "2345678901234567")
      (TL.Struct64.f_get (Capnp.Array.get (TL.list64_get lists) 1));
    assert_equal "foo" (TL.StructP.f_get (Capnp.Array.get (TL.list_p_get lists) 0));
    assert_equal "bar" (TL.StructP.f_get (Capnp.Array.get (TL.list_p_get lists) 1));

    let () =
      let a = TL.int32_list_list_get lists in
      assert_equal 3 (Capnp.Array.length a);
      assert_equal (Capnp.Array.to_list (Capnp.Array.get a 0)) [ 1l; 2l; 3l ];
      assert_equal (Capnp.Array.to_list (Capnp.Array.get a 1)) [ 4l; 5l ];
      assert_equal (Capnp.Array.to_list (Capnp.Array.get a 2)) [ 12341234l ]
    in
    let () =
      let a = TL.text_list_list_get lists in
      assert_equal 3 (Capnp.Array.length a);
      assert_equal (Capnp.Array.to_list (Capnp.Array.get a 0)) [ "foo"; "bar" ];
      assert_equal (Capnp.Array.to_list (Capnp.Array.get a 1)) [ "baz" ];
      assert_equal (Capnp.Array.to_list (Capnp.Array.get a 2)) [ "qux"; "corge" ]
    in
    let () =
      let a = TL.struct_list_list_get lists in
      assert_equal 2 (Capnp.Array.length a);
      let e0 = Capnp.Array.get a 0 in
      assert_equal 2 (Capnp.Array.length e0);
      assert_equal 123l (TAT.int32_field_get (Capnp.Array.get e0 0));
      assert_equal 456l (TAT.int32_field_get (Capnp.Array.get e0 1));
      let e1 = Capnp.Array.get a 1 in
      assert_equal 1 (Capnp.Array.length e1);
      assert_equal 789l (TAT.int32_field_get (Capnp.Array.get e1 0))
    in
    ()
end


module ReaderTestLists = struct
  include T.Reader.TestLists
  type array_t = T.Reader.array_t
  type 'a message_t = 'a T.message_t
  type access = Test.ro
  type message_access = Test.ro
  type test_all_types_t = T.Reader.TestAllTypes.t
end

module BuilderTestLists = struct
  include T.Builder.TestLists
  type array_t = T.Builder.array_t
  type 'a message_t = 'a T.message_t
  type access = Test.rw
  type message_access = Test.rw
  type test_all_types_t = T.Builder.TestAllTypes.t
end

module Reader_check_test_list =
  Check_test_list(ReaderTestLists)(ReaderTestAllTypes)

module Builder_check_test_list =
  Check_test_list(BuilderTestLists)(BuilderTestAllTypes)


let test_list_defaults ctx =
  let root = T.Builder.TestListDefaults.init_root () in
  let lists = T.Builder.TestListDefaults.lists_get root in
  Reader_check_test_list.f (T.Reader.TestLists.of_builder lists);
  Builder_check_test_list.f lists;
  Reader_check_test_list.f (T.Reader.TestLists.of_builder lists)


let test_build_list_defaults ctx =
  let root = T.Builder.TestLists.init_root () in
  let () = init_list_defaults root in
  Reader_check_test_list.f (T.Reader.TestLists.of_builder root);
  Builder_check_test_list.f root;
  Reader_check_test_list.f (T.Reader.TestLists.of_builder root)


let test_upgrade_struct_in_builder ctx =
  let old_reader, message =
    let open T.Builder.TestOldVersion in
    let root = init_root () in
    old1_set root 123L;
    old2_set root "foo";
    let sub = old3_init root in
    old1_set sub 456L;
    old2_set sub "bar";
    (to_reader root, to_message root)
  in

  let () =
    let module B = T.Builder.TestNewVersion in
    let module R = T.Reader.TestOldVersion in
    let new_version = B.of_message message in

    (* The old instance should have been zero'd. *)
    assert_equal 0L (R.old1_get old_reader);
    assert_equal "" (R.old2_get old_reader);
    assert_equal 0L (R.old1_get (R.old3_get old_reader));
    assert_equal "" (R.old2_get (R.old3_get old_reader));

    assert_equal 123L (B.old1_get new_version);
    assert_equal "foo" (B.old2_get new_version);
    assert_equal 987L (B.new1_get new_version);
    assert_equal "baz" (B.new2_get new_version);

    let sub = B.old3_get new_version in
    assert_equal 456L (B.old1_get sub);
    assert_equal "bar" (B.old2_get sub);
    assert_equal 987L (B.new1_get sub);
    assert_equal "baz" (B.new2_get sub);

    B.old1_set new_version 234L;
    B.old2_set new_version "qux";
    B.new1_set new_version 321L;
    B.new2_set new_version "quux";

    B.old1_set sub 567L;
    B.old2_set sub "corge";
    B.new1_set sub 654L;
    B.new2_set sub "grault"
  in

  let () =
    (* Go back to the old version.  It should retain the values set on
       the new version. *)
    let open T.Builder.TestOldVersion in
    let old_version = of_message message in
    assert_equal 234L (old1_get old_version);
    assert_equal "qux" (old2_get old_version);

    let sub = old3_get old_version in
    assert_equal 567L (old1_get sub);
    assert_equal "corge" (old2_get sub);

    (* Overwrite the old fields.  The new fields should remain intact. *)
    old1_set old_version 345L;
    old2_set old_version "garply";
    old1_set sub 678L;
    old2_set sub "waldo"
  in

  let () =
    (* Back to the new version again. *)
    let open T.Reader.TestNewVersion in
    let new_version = of_message message in

    assert_equal 345L (old1_get new_version);
    assert_equal "garply" (old2_get new_version);
    assert_equal 321L (new1_get new_version);
    assert_equal "quux" (new2_get new_version);

    let sub = old3_get new_version in
    assert_equal 678L (old1_get sub);
    assert_equal "waldo" (old2_get sub);
    assert_equal 654L (new1_get sub);
    assert_equal "grault" (new2_get sub)
  in
  ()



let encoding_suite =
  "all_types" >::: [
    "encode/decode" >:: test_encode_decode;
    "decode defaults" >:: test_decode_defaults;
    "init defaults" >:: test_init_defaults;
    "union encode/decode" >:: test_union_encoding;
    "union layout" >:: test_union_layout;
    "unnamed union encode/decode" >:: test_unnamed_union_encoding;
    "group encode/decode" >:: test_groups;
    "interleaved groups" >:: test_interleaved_groups;
    "union defaults" >:: test_union_defaults;
    "list defaults" >:: test_list_defaults;
    "build list defaults" >:: test_build_list_defaults;
    "upgrade struct in builder" >:: test_upgrade_struct_in_builder;
  ]

let () = run_test_tt_main encoding_suite

