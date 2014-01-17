(require 'ert)

(ert-deftest emacsql-escape ()
  (should (string= (emacsql-escape "foo") "foo"))
  (should (string= (emacsql-escape 'foo) "foo"))
  (should (string= (emacsql-escape :foo) "':foo'"))
  (should (string= (emacsql-escape "a b") "'a b'"))
  (should (string= (emacsql-escape '$foo) "'$foo'"))
  (should (string= (emacsql-escape "foo$") "foo$"))
  (should (string= (emacsql-escape "they're") "'they''re'")))

(ert-deftest emacsql-escape-value ()
  (should (string= (emacsql-escape-value 'foo) "'foo'"))
  (should (string= (emacsql-escape-value "foo") "'\"foo\"'"))
  (should (string= (emacsql-escape-value :foo) "':foo'"))
  (should (string= (emacsql-escape-value [1 2 3]) "'[1 2 3]'"))
  (should (string= (emacsql-escape-value '(a b c)) "'(a b c)'"))
  (should (string= (emacsql-escape-value nil) "NULL")))

(ert-deftest emacsql-schema ()
  (should (string= (emacsql--schema-to-string [a]) "a"))
  (should (string= (emacsql--schema-to-string [a b c]) "a, b, c"))
  (should (string= (emacsql--schema-to-string [a (b)]) "a, b"))
  (should (string= (emacsql--schema-to-string [a (b float)])
                   "a, b REAL"))
  (should (string= (emacsql--schema-to-string [a (b :primary float :unique)])
                   "a, b REAL PRIMARY KEY UNIQUE"))
  (should (string= (emacsql--schema-to-string [(a integer) (b float)])
                   "a INTEGER, b REAL")))

(ert-deftest emacsql-var ()
  (should (eq (emacsql-var 'a) nil))
  (should (eq (emacsql-var 0) nil))
  (should (eq (emacsql-var "") nil))
  (should (eq (emacsql-var '$) 0))
  (should (eq (emacsql-var '$1) 0))
  (should (eq (emacsql-var '$5) 4))
  (should (eq (emacsql-var '$10) 9)))

(defun emacsql-tests-query (query args result)
  "Check that QUERY outputs RESULT for ARGS."
  (should (string= (apply #'emacsql-format (emacsql-expand query) args) result)))

(ert-deftest emacsql-expand ()
  (emacsql-tests-query [:select [$1 name] :from $2] '(id people)
                       "SELECT id, name FROM people;")
  (emacsql-tests-query [:select * :from employees] ()
                       "SELECT * FROM employees;"))