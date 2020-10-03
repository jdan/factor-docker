! Copyright (C) 2020 Jordan Scales.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http.server
       http.server.dispatchers http.server.responses io.servers kernel
       sequences namespaces db db.tuples db.types db.sqlite fry formatting ;

IN: webapps.hello

TUPLE: task id text complete ;

task "TASKS"
{
  { "id" "ID" +db-assigned-id+ }
  { "text" "TEXT" VARCHAR }
  { "complete" "COMPLETE" BOOLEAN }
} define-persistent

: task>html ( task -- html )
  [ complete>> [ "checked" ] [ "" ] if ] [ text>> ] bi
  "<div>
    <input type='checkbox' %s> %s
  </div>
  " sprintf ;

: tasks>html ( seq -- html ) [ task>html ] map " " join ;

: with-example-db ( quot -- )
  '[ "example.db" <sqlite-db> _ with-db ] call ; inline

! http://re-factor.blogspot.com/2010/08/hello-web.html
TUPLE: hello < dispatcher ;

! TODO - POST /tasks/:id/complete

: <hello-action> ( -- action )
  <page-action>
    [ [ T{ task } select-tuples ] with-example-db tasks>html
      "text/html"
      <content>
    ] >>display ;

: <hello> ( -- dispatcher )
  hello new-dispatcher
    <hello-action> "" add-responder ;

: run-hello ( -- )
  [ task recreate-table
    T{ task { text "Clone the docker image" } { complete t } } insert-tuple
    T{ task { text "Run the image in a container" } { complete t } } insert-tuple
    T{ task { text "Get creative" } } insert-tuple
    T{ task { text "Follow <a href='https://twitter.com/jdan'>jdan</a> on twitter" } } insert-tuple
  ] with-example-db

  <hello> main-responder set-global
  8080 httpd wait-for-server ;

MAIN: run-hello