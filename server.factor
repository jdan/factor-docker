! Copyright (C) 2020 Jordan Scales.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http.server io
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
  [ id>> ] [ complete>> [ "checked" ] [ "" ] if ] [ text>> ] tri
  "<div>
    <label>
      <input data-id='%s' type='checkbox' %s> %s
    </label>
  </div>
  " sprintf ;

: tasks>html ( seq -- html ) [ task>html ] map " " join ;

: layout ( html -- html )
  "<!doctype html>
  <html>
  <head>
    <title>Factor + SQLite + Docker</title>
    <style>
      main {
        width: 30em;
        margin: 100px auto 0;
      }
    </style>
  </head>
  <body>
    <main>
      %s
    </main>
    <script>
      document.querySelectorAll('input[data-id][type=checkbox]').forEach((el) => {
        el.addEventListener('click', async (e) => {
          await fetch(`/tasks/${e.target.getAttribute('data-id')}`, {
            method: 'POST',
            body: JSON.stringify({
              complete: e.target.checked
            })
          })
        })
      })
    </script>
  </body>
  </html>
  " sprintf ;

: with-example-db ( quot -- )
  '[ "example.db" <sqlite-db> _ with-db ] call ; inline

! http://re-factor.blogspot.com/2010/08/hello-web.html
TUPLE: hello < dispatcher ;

! TODO - POST /tasks/:id/complete

: <hello-action> ( -- action )
  <page-action>
    [ [ T{ task } select-tuples ] with-example-db tasks>html layout
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