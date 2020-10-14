## Compilazione d’espressioni regolari in automi non deterministici
La rappresentazione in Lisp è del tutto analoga a quella in Prolog. Le regexps si rappresentano con delle liste così formate: 
- *\<re1>\<re2>…\<rek>*  diventa `(seq <re1> <re2> … <rek>)` 
- *\<re1>|\<re2>|…|\<rek>* diventa `(or <re1> <re2> … <rek>)` 
- *\<re>** diventa `(star <re>)` 
- *\<re>+*   diventa `(plus <re>)` 

**CARATTERISTICHE:**
L’alfabeto dei “simboli” S è costituito S-exps Lisp. 

Sintassi:
1. `(is-regexp RE)` ritorna vero quando RE è un’espressione regolare.
2. `(nfa-regex-comp RE)` ritorna l’automa ottenuto dalla compilazione di RE, se è un’espressione regolare, altrimenti ritorna NIL.
3. `(nfa-check FA Input)` ritorna vero quando l’input per l’automa FA (ritornato da una precedente chiamata a nfa-regex-comp) viene consumato completamente e l’automa si trova in uno stato finale. Input è una lista Lisp di simboli dell’alfabeto S sopra definito. Se FA non ha la corretta struttura di un automa come ritornato da nfa-regex-comp, la funzione dovrà segnalare un errore.

## IMPORTANTE

1) La funzione nfa-regex-comp fallisce segnalando un errore quando non è rispettata la sintassi nella definizione della RE.
1) La funzione nfa-check fallisce segnalando un errore quando non è rispettata la sintassi e la struttura nella definizione dell'automa 'FA'. Quest'ultimo viene ritornato nella forma corretta dalla funzione nfa-regex-comp.
