! http://re-factor.blogspot.com/2010/08/hello-web.html
USING: accessors furnace.actions http.server
       http.server.dispatchers http.server.responses io.servers kernel
       namespaces ;

IN: webapps.hello

TUPLE: hello < dispatcher ;

: <hello-action> ( -- action )
  <page-action>
    [ "Hello, world!" "text/plain" <content> ] >>display ;

: <hello> ( -- dispatcher )
  hello new-dispatcher
    <hello-action> "" add-responder ;

: run-hello ( -- )
  <hello> main-responder set-global
  8080 httpd wait-for-server ;

MAIN: run-hello