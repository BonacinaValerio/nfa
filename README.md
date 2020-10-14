## Introduzione
Le espressioni regolari – *regular expressions*, o, abbreviando *regexps* – sono tra gli strumenti più utilizzati in Informatica.  Un’espressione regolare rappresenta in maniera finita un linguaggio (regolare), ossia un insieme potenzialmente infinito di sequenze di “simboli”, o stringhe, dove i “simboli” sono tratti da un alfabeto che indicheremo con Σ. 
Le regexp più semplici sono costituite da tutti i “simboli” Σ, da *sequenze* di “simboli” e/o regexps, *alternative* tra “simboli” e/o regexps, e la ripetizione di “simboli” e/o regexps (quest’ultima è anche detta “chiusura” di Kleene).  Se *\<re>, \<re1>, \<re2>* … sono regexp, in Perl (e prima di Perl in ‘ed’ UNIX) allora *\<re1>\<re2>, \<re1>|\<re2> e \<re>** sono anche regexps. le espressioni sono:
- *\<re1>\<re2>…\<rek>*	(sequenza) 
- *\<re1>|\<re2>*	(alternativa, almeno una delle due) 
- *\<re>**  (chiusura di Kleene, ripetizione 0 o più volte)

Ad esempio, l’espressione regolare *x*, dove *x* è un “simbolo”, rappresenta l’insieme {*x*} contenente il “simbolo” *x*, o meglio: la sequenza di “simboli” di lunghezza 1 composta dal solo “simbolo” *x*.
L’espressione regolare *pq*, dove sia *p* che *q* sono “simboli”, rappresenta l’insieme {*pq*} contenente solo la sequenza di simboli, di lunghezza 2, *pq* (prima p, dopo q)
L’espressione regolare *a**, dove *a* è un “simbolo”, rappresenta l’insieme infinito contenente tutte le sequenze ottenute ripetendo il simbolo *a* un numero arbitrario di volte {*ε, a, aa, aaa, …*}, dove *ε* viene usato per rappresentare la “sequenza di simboli con lunghezza zero”.
L’espressione regolare *a(bc)\*d*, dove *a*, *b*, *c*, *d* sono “simboli”, rappresenta l’insieme {*ad, abcd, abcbcd, abcbcbcd…*} di tutte le sequenze che iniziano con *a*, terminano con *d*, e contengono tra questi due simboli un numero arbitrario di ripetizioni della sottosequenza *bc*. Infine, l’espressione regolare  *¬xyz*, dove *x*, *y*, *z* sono “simboli”, rappresenta l’insieme infinito contenente tutte le sequenze di simboli tratti dall’alfabeto (compresa ε), ad esclusione della sola stringa *xyz*. 
Altre regexps utili sono:
- *[\<re1>, \<re2>, …\<rek>]* (una sola delle *\<rei>*) 
- *\<re>+*	(ripetizione, 1 o più volte)  

Notate che queste regexps possono essere definite utilizzando opportune combinazioni degli operatori di sequenza, alternativa, chiusura di Kleene e negazione.
Com’è noto, a ogni regexp corrisponde un automa a stati finiti (non-deterministico o NFA) in grado di determinare se una sequenza di “simboli” appartiene o no all’insieme definito dall’espressione regolare, in un tempo asintoticamente lineare rispetto alla lunghezza della stringa. 
