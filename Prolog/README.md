## Compilazione d’espressioni regolari in automi non deterministici
Rappresentare le espressioni regolari più semplici in Prolog è molto facile: senza disturbare il parser intrinseco del sistema, possiamo rappresentare le regexps così: 
- *\<re1>\<re2>…\<rek>*  diventa `seq(<re1>,<re2>,…, <rek>)` 
- *\<re1>|\<re2>|…|\<rek>* diventa `or(<re1>, <re2>, …, <rek>)` 
- *\<re>** diventa `star(<re>)` 
- *\<re>+*   diventa `plus(<re>)` 

**CARATTERISTICHE:**
L’alfabeto dei “simboli” S è costituito da termini Prolog (più precisamente, da tutto ciò che soddisfa compound/1 o atomic/1).

Sintassi:
1. `is_regexp(RE)` è vero quando RE è un’espressione regolare. Numeri e atomi (in genere anche ciò che soddisfa atomic/1), sono le espressioni regolari più semplici.
2. `nfa_regex_comp(FA_Id, RE)` è vero quando RE è compilabile in un automa, che viene inserito nella base dati del Prolog. FA_Id diventa un identificatore per l’automa (deve essere un termine Prolog senza variabili).
3. `nfa_check(FA_Id, Input)` è vero quando l’input per l’automa identificato da FA_Id viene consumato completamente e l’automa si trova in uno stato finale. Input è una lista Prolog di simboli dell’alfabeto S sopra definito.

## IMPORTANTE

Il predicato fallisce segnalando un errore quando non è rispettata la sintassi nella definizione della RE.
