;;; verifica della correttezza di una RE 
(defun is-regexp (re)
  (cond ((atom re) t)
        ((and (singlearg (first re))
              (= (length (rest re)) 1))
         (is-regexp-list (rest re)))
	((and (morearg (first re))
              (> (length (rest re)) 0))
         (is-regexp-list (rest re)))
        (t (prin1 "Errore. ER non corretta")
           (terpri)
           (verify-op (first re)))))

(defun is-regexp-list (re)
  (cond ((= (length re) 1) (is-regexp (first re)))
        ((and (is-regexp (first re))
              (is-regexp-list (rest re))) t)
        (t nil)))

;;; controllo operatori
(defun singlearg (op)
  (let ((operator '(star 
                    plus)))
    (cond ((member op operator) t)
          (t nil))))

(defun morearg (op)
  (let ((operator '(seq 
                    or)))
    (cond ((member op operator) t)
          (t nil))))

;;; verifica l'operatore della RE
(defun verify-op (op)
  (cond ((morearg op) nil)
        ((singlearg op) nil)
        (t (prin1 "Operatore non corretto")
           (terpri)
           nil)))

;;; creazione dell'automa
(defun nfa-regex-comp (re)
  (cond ((is-regexp re) (flatten (cons '(nfa-initial in)
                                       (cons '(nfa-final fin)
                                             (nfa-regex-delta re 'in 'fin)))))
         (t nil)))

;;; settaggio dei cambi di stato delta
(defun nfa-regex-delta (re init final)
  (let ((init2 (gensym "q"))
        (final2 (gensym "q")))
    (cond ((atom re) (cons (list 'nfa-regex-delta init re final)
                           nil))
          ((equalp (first re)  ; gestione del caso 'star'
                   'star) (cons (list 'nfa-regex-delta 
                                      init 'epsilon final)
                           (cons (list 'nfa-regex-delta init 
                                       'epsilon init2)
                            (cons (list 'nfa-regex-delta final2 
                                        'epsilon final)
                             (cons (list 'nfa-regex-delta final2 
                                         'epsilon init2)
                              (nfa-regex-delta (second re) init2 final2))))))
          ((equalp (first re)  ; gestione del caso 'plus'
                   'plus) (cons (list 'nfa-regex-delta init 
                                      'epsilon init2)
                                (cons (list 'nfa-regex-delta final2 
                                            'epsilon final)
                                      (cons (list 'nfa-regex-delta final2
                                                  'epsilon init2)
                                            (nfa-regex-delta (second re)
                                                             init2 final2)))))
          ((equalp (first re) 'seq) (nfa-regex-seq (rest re) init final))
          ((equalp (first re) 'or) (nfa-regex-or (rest re) init final)))))

;;; gestione del caso operatore = seq
(defun nfa-regex-seq (re init final)
  (let ((init2 (gensym "q"))
        (final2 (gensym "q")))
    (cond ((= (length re) 1) (nfa-regex-delta (first re) init final))
          (t (cons (list 'nfa-regex-delta final2 'epsilon init2)
                   (cons (nfa-regex-delta (first re) init final2)
                         (nfa-regex-seq (rest re) init2 final)))))))

;;; gestione del caso operatore = or
(defun nfa-regex-or (re init final)
  (let ((init2 (gensym "q"))
        (final2 (gensym "q")))
    (cond ((= (length re) 1) (cons (list 'nfa-regex-delta init
                                         'epsilon init2)
                                   (cons (list 'nfa-regex-delta final2 
                                               'epsilon final)
                                         (nfa-regex-delta (first re) 
                                                          init2 final2))))
          (t (cons (list 'nfa-regex-delta init 'epsilon init2)
                   (cons (list 'nfa-regex-delta final2 'epsilon final)
                         (cons (nfa-regex-delta (first re) init2 final2) 
                               (nfa-regex-or (rest re) init final))))))))

;;; rimozione delle parentesi nidificate in una lista
(defun flatten (l)
  (cond ((null l) nil)
        ((is-step (first l)) (cons (first l) 
                                   (flatten (rest l))))
        (t (append (flatten (first l)) 
                   (flatten (rest l))))))

;;; verifica che un'arco sia valida
(defun is-step (l)
  (cond ((equal (first l)
                (find (first l) 
                      '(NFA-FINAL
                        NFA-INITIAL
                        NFA-REGEX-DELTA))) t)
        (t nil)))

;;; verifica che un'arco sia quello specificato da parametro 
(defun is-state (l s)
  (cond ((atom l) nil)
        ((equal (first l)
                s) t)
        (t nil)))

;;; lettura dell'input da parte dell'automa fa
(defun nfa-check (fa input)
  (cond ((verify-fa fa) (nfa-comp input (get-state fa 'NFA-INITIAL) fa))
        (t (prin1 "Errore. automa non corretto")
           nil)))

;;; computazione dell'automa sull'input
(defun nfa-comp (input state fa)
  (cond ((null input) (cond ((equalp (get-state fa 'NFA-FINAL) state) t)
                            ((nfa-state state 
                                        (get-trans state 'epsilon fa) 
                                        input fa) t)
                            (t nil)))
        (t (cond ((nfa-state state 
                             (get-trans state 'epsilon fa) 
                             input fa) t)
                 ((nfa-state state 
                             (get-trans state (first input) fa)
                             (rest input) fa) t)
                 (t nil)))))

;;; ritorna il tipo di arco analizzato
(defun get-state (fa s)
  (cond ((null fa) nil)
        ((is-state (first fa) s) (second (first fa)))
        (t (get-state (rest fa) s))))

;;; ritorna una lista di tutti gli archi validi con partenza 'state' e simbolo 
;;; di input 'sym'
(defun get-trans (state sym fa)
  (cond ((null fa) nil)
        ((and (is-state (first fa) 'NFA-REGEX-DELTA)
              (equal (string (second (first fa))) (string state))
              (equal (third (first fa)) sym)) (cons (first fa)
                                                    (get-trans state sym 
                                                               (rest fa))))
        (t (get-trans state sym (rest fa)))))

;;; gestione ricorsiva di tutti i rami percorribili dall'automa
(defun nfa-state (state trans input fa)
  (cond ((null trans) nil)
        (t (or (nfa-comp input (fourth (first trans)) fa)
               (nfa-state state (rest trans) input fa)))))

;;; verifica che l'automa 'fa' sia valido
(defun verify-fa (fa)
  (cond ((atom fa) nil)
        ((and (= 1 (count-initial fa))
              (= 1 (count-final fa))
              (null (remove-state fa))) t)
        (t nil)))

;;; conteggio degli stati iniziali presenti in 'fa'
(defun count-initial (fa)
  (cond ((null fa) 0)
        ((atom fa) 0)
        ((and (is-state (first fa) 'NFA-INITIAL) 
              (= 2 (length (first fa)))) (+ 1 (count-initial (rest fa))))
        (t (count-initial (rest fa)))))

;;; conteggio degli stati finali presenti in 'fa'
(defun count-final (fa)
  (cond ((null fa) 0)
        ((atom fa) 0)
        ((and (is-state (first fa) 'NFA-FINAL) 
              (= 2 (length (first fa)))) (+ 1 (count-final (rest fa))))
        (t (count-final (rest fa)))))

;;; rimuovi tutti gli stati validi da 'fa'
(defun remove-state (fa)
  (cond ((null fa) nil)
        ((atom fa) fa)
        ((and (is-state (first fa) 'NFA-REGEX-DELTA)
              (= 4 (length (first fa)))) (remove-state (rest fa)))
        ((and (is-state (first fa) 'NFA-INITIAL) 
              (= 2 (length (first fa)))) (remove-state (rest fa)))
        ((and (is-state (first fa) 'NFA-FINAL) 
              (= 2 (length (first fa)))) (remove-state (rest fa)))
        (t (cons (first fa) (remove-state (rest fa))))))