USING: kernel db.tuples db.types ;

IN: mydb

TUPLE: student id first last ;

student "STUDENTS"
{
  { "id" "ID" +db-assigned-id+ }
  { "first" "FIRST" VARCHAR }
  { "last" "LAST" VARCHAR }
} define-persistent

USING: db db.sqlite fry ;
: with-example-db ( quot -- )
  '[ "example.db" <sqlite-db> _ with-db ] call ; inline

! : insert-one ( -- )
!   ! insert a single record
!   [
!     student recreate-table
!     student get insert-tuple
!   ] with-example-db ;

! [ T{ student { first "Jordan" } { last "Scales" } } insert-tuple ] with-example-db
! [ T{ student { last "Foran" } } select-tuples . ] with-example-db
