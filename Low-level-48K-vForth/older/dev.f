cr ." Loading universe" cr

needs pwd
needs view
needs dir
needs evaluate
needs graphics
needs find

\ : setup-tools
\   s   " needs pwd" evaluate
\   s" needs view" evaluate
\   s" needs dir" evaluate
\ ;

\ cd \dev

\ : (loadgame)
\   s" include \dev\run.fth" 
\ ;

\ : loadgame
\   (loadgame) evaluate
\ ;

\ : remote_dev
\   s" emptydev" find
\ ;


\ : [IF] 
\ -FIND emptydev [IF] drop execute [THEN]
\ create dev_fn ," emptydev"
\ : remove_dev dev_fn find if execute else drop then ;


create -?execute-name ," -?EXECUTE"
create emptydev-name ," emptydev"
: loadg
  -?execute-name find if s" : -?EXECUTE -FIND if drop execute then ;" evaluate else drop then
  emptydev-name find if execute else drop then
  s" include \dev\main.fth" 
  evaluate
;

-?EXECUTE emptydev
marker emptydev


include \dev\main.fth

." Finished" cr


