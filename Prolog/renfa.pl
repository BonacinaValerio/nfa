%%% operatori
singlearg(star).
singlearg(plus).

morearg(or).
morearg(seq).

%%% verifica della correttezza di una RE
is_regexp(RE) :-
	nonvar(RE),
	atomic(RE),
	!.
is_regexp(RE) :-
	nonvar(RE),
	compound(RE),
	RE =.. [OP | T],
	singlearg(OP),
	length(T, 1),
	!,
	is_regexp_list(T).
is_regexp(RE) :-
	nonvar(RE),
	compound(RE),
	RE =.. [OP | T],
	morearg(OP),
	length(T, N),
	N > 0,
	!,
	is_regexp_list(T).
is_regexp(RE) :-
	RE =.. [OP | _],
	!,
	verify_op(OP),
	writef("Errore. ER non corretta"),
	fail.

is_regexp_list([H]) :-
	!,
	is_regexp(H).
is_regexp_list([H | T]) :-
	is_regexp(H),
	is_regexp_list(T).

%%% creazione dell'automa
nfa_regex_comp(FA_Id, RE) :-
	nonvar(FA_Id),
	verify_id(FA_Id),
	id_exists(FA_Id),
	nonvar(RE),
	is_regexp(RE),
	gensym(in, Init),
	gensym(fin, Final),
	assert(nfa_initial(FA_Id, Init)),
	assert(nfa_final(FA_Id, Final)),
	nfa_regex_delta(FA_Id, RE, Init, Final),
	!.

%%% settaggio dei cambi di stato delta
nfa_regex_delta(FA_Id, RE, Init, Final) :-
	atomic(RE),
	assert(nfa_delta(FA_Id, Init, RE, Final)).
%%% gestione del caso 'star'
nfa_regex_delta(FA_Id, star(RE), Init, Final) :-
	gensym(q, Init2),
	gensym(q, Final2),
	assert(nfa_delta(FA_Id, Init, epsilon, Final)),
	assert(nfa_delta(FA_Id, Init, epsilon, Init2)),
	assert(nfa_delta(FA_Id, Final2, epsilon, Final)),
	assert(nfa_delta(FA_Id, Final2, epsilon, Init2)),
	nfa_regex_delta(FA_Id, RE, Init2, Final2).
%%% gestione del caso 'plus'
nfa_regex_delta(FA_Id, plus(RE), Init, Final) :-
	gensym(q, Init2),
	gensym(q, Final2),
	assert(nfa_delta(FA_Id, Init, epsilon, Init2)),
	assert(nfa_delta(FA_Id, Final2, epsilon, Final)),
	assert(nfa_delta(FA_Id, Final2, epsilon, Init2)),
	nfa_regex_delta(FA_Id, RE, Init2, Final2).
nfa_regex_delta(FA_Id, RE, Init, Final) :-
	RE =.. [seq | T],
	!,
	nfa_regex_seq(FA_Id, T, Init, Final).
nfa_regex_delta(FA_Id, RE, Init, Final) :-
	RE =.. [or | T],
	!,
	nfa_regex_or(FA_Id, T, Init, Final).

%%% gestione del caso operatore = seq
nfa_regex_seq(FA_Id, [RE], Init, Final) :-
	!,
	nfa_regex_delta(FA_Id, RE, Init, Final).
nfa_regex_seq(FA_Id, [H | T], Init, Final) :-
	gensym(q, Final2),
	gensym(q, Init2),
	nfa_regex_delta(FA_Id, H, Init, Final2),
	assert(nfa_delta(FA_Id, Final2, epsilon, Init2)),
	nfa_regex_seq(FA_Id, T, Init2, Final).

%%% gestione del caso operatore = or
nfa_regex_or(FA_Id, [RE], Init, Final) :-
	!,
	gensym(q, Init2),
	gensym(q, Final2),
	assert(nfa_delta(FA_Id, Init, epsilon, Init2)),
	nfa_regex_delta(FA_Id, RE, Init2, Final2),
	assert(nfa_delta(FA_Id, Final2, epsilon, Final)).
nfa_regex_or(FA_Id, [H | T], Init, Final) :-
	nfa_regex_or(FA_Id, [H], Init, Final),
	nfa_regex_or(FA_Id, T, Init, Final).

%%% lettura dell'input da parte dell'automa FA_Id
nfa_check(FA_Id, List) :-
	nonvar(FA_Id),
	nonvar(List),
	id_not_exists(FA_Id),
	nfa_initial(FA_Id, State),
	nfa_comp(FA_Id, List, State),
	!.

%%% computazione dell'automa sull'input
nfa_comp(FA_Id, [], State) :-
	nfa_final(FA_Id, State),
	!.
nfa_comp(FA_Id, [], State) :-
	nfa_delta(FA_Id, State, epsilon, State2),
	nfa_comp(FA_Id, [], State2).
nfa_comp(FA_Id, [H | T], State) :-
	nfa_delta(FA_Id, State, epsilon, State2),
	nfa_comp(FA_Id, [H | T], State2).
nfa_comp(FA_Id, [H | T], State) :-
	nfa_delta(FA_Id, State, H, State2),
	nfa_comp(FA_Id, T, State2).

%%% svuota la base di conoscenza
nfa_clear(FA_Id) :-
	retract(nfa_initial(FA_Id, _)),
	retract(nfa_delta(FA_Id, _, _, _)),
	retract(nfa_final(FA_Id, _)).
nfa_clear :-
	retractall(nfa_initial(_, _)),
	retractall(nfa_delta(_, _, _, _)),
	retractall(nfa_final(_, _)).

%%% lista la base di conoscenza
nfa_list(FA_Id) :-
	listing(nfa_initial(FA_Id, _)),
	listing(nfa_delta(FA_Id, _, _, _)),
	listing(nfa_final(FA_Id, _)).
nfa_list :-
	listing(nfa_initial(_, _)),
	listing(nfa_delta(_, _, _, _)),
	listing(nfa_final(_, _)).

%%% verifica l'id dell'automa
verify_id(FA_Id) :-
	atomic(FA_Id),
	!.
verify_id(_) :-
	writef("Errore. L'id inserito non e' corretto"),
	!,
	fail.

%%% verifica l'esistenza dell'automa
id_exists(FA_Id) :-
	current_predicate(_, nfa_initial),
	call(nfa_initial(FA_Id, _)),
	writef("Errore. L'id inserito e' già in uso"),
	!,
	fail.
id_exists(_) :-
	!.

%%% verifica la non esistenza dell'automa
id_not_exists(FA_Id) :-
	call(nfa_initial(FA_Id, _)),
	!.
id_not_exists(_) :-
	writef("Errore. L'id inserito non esiste"),
	!,
	fail.

%%% verifica l'operatore della RE
verify_op(OP) :-
	morearg(OP),
	!.
verify_op(OP) :-
	singlearg(OP),
	!.
verify_op(_) :-
	writef("Errore. Operatore non corretto"),
	!,
	fail.
