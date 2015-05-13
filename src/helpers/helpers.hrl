%%%-------------------------------------------------------------------
%%% @author Alexey Shilenkov
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Mar 2015 2:59 AM
%%%-------------------------------------------------------------------
-author("Alexey Shilenkov").


%%helpers converters
-define(toList(Term), any_to_list(Term)).
-define(toBinary(Term),any_to_binary(Term)).
-define(toInt(Term), any_to_integer(Term)).
-define(delLast(Term), deleteLast(Term)).
-define(APND(Term), lists:append(Term)).

-define(D(Fmt, Args), lager:info(Fmt, Args)).
-define(I(Fmt, Args), lager:info(Fmt, Args)).
-define(E(Fmt, Args), lager:info(Fmt, Args)).

any_to_list(Atom) when is_atom(Atom) ->
  atom_to_list(Atom);
any_to_list(Bitstring) when is_bitstring(Bitstring) ->
  bitstring_to_list(Bitstring);
any_to_list(Integer) when is_integer(Integer) ->
  integer_to_list(Integer);
any_to_list(String) when is_list(String) ->
  String;
any_to_list(Binary) when is_binary(Binary) ->
  binary_to_list(Binary);
any_to_list(Var)->Var.



-spec(any_to_binary/1 ::
    (atom() | integer() | string() | binary()) -> binary()).

any_to_binary(Atom) when is_atom(Atom) ->
  any_to_binary(atom_to_list(Atom));
any_to_binary(Integer) when is_integer(Integer) ->
  any_to_binary(integer_to_list(Integer));
any_to_binary(String) when is_list(String) ->
  list_to_binary(String);
any_to_binary(Binary) when is_binary(Binary) ->
  Binary;
any_to_binary(Var)->Var.

any_to_integer(Atom) when is_atom(Atom) ->
  any_to_integer(any_to_list(Atom));
any_to_integer(Integer) when is_integer(Integer) ->
  Integer;
any_to_integer(String) when is_list(String) ->
  list_to_integer(String);
any_to_integer(Binary) when is_binary(Binary) ->
  erlang:binary_to_integer(Binary);
any_to_integer(Bitstring) when is_bitstring(Bitstring)->
  any_to_integer(erlang:bitstr_to_list(Bitstring));
any_to_integer(Var)->Var.

tupleToStringList(Tuple, Separator) ->
  [erlang:integer_to_list(Y) || Y <- lists:append([tuple_to_list(X) || X <- Tuple])].

deleteLast(List) ->
  [_ | T] = lists:reverse(List),
  lists:reverse(T).


