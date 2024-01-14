\ Simple sideways scroll shooting asteriods game

needs unused
." Unused = " unused u. cr

cr ." Loading surfaces" cr

include \dev\imagedef.fth

." Loading visible light" cr

include \dev\drawbase.fth

." Unused = " unused u. cr

." Loading ship systems" cr

: t1 ship 0 0 xdraw show-ula ;
: t2 rock 0 0 xdraw magenta ink blue paper target_colour @ 0 0 xpaint show-ula ;
: t3 bullet 0 0 xdraw black ink yellow paper bright 0 0 tpaint show-ula ;

needs value
needs to


0 value px
0 value py
0 value old_px
0 value old_py

: setup_player
  0 to px
  0 to old_px
  12 to py
  12 to old_py
;

\ object attributes
\  - exists
\  - x
\  - old_x
\  - y
\  - (image?)
\  - (controller?)

: obj_exist@ ( object_addr -- exist_flag ) c@ ;
: obj_x@ ( object_addr -- x ) 1+ c@ ;
: obj_old_x@ ( object_addr -- x ) 2+ c@ ;
: obj_y@ ( object_addr -- x ) 3 + c@ ;
: obj_image@ ( object_addr -- x ) 4 + @ ;
: obj_ctrl@ ( object_addr -- x ) 6 + @ ;

: obj_exist! ( flag object_addr -- ) c! ;
: obj_x! ( x object_addr -- ) 1+ c! ;
: obj_old_x! ( x object_addr -- ) 2+ c! ;
: obj_y! ( y object_addr -- ) 3 + c! ;
: obj_image! ( image object_addr -- x ) 4 + ! ;
: obj_ctrl! ( xt object_addr -- x ) 6 + ! ;

8 constant object_size

20 constant max_bullets
20 constant max_rocks

create bullets max_bullets object_size * allot
create rocks max_rocks object_size * allot

: setup_bullet ( obj-addr -- )
      1 over obj_exist! 
      31 over obj_x!
      \ -1 over obj_old_x!
      30 over obj_old_x!
      0 over obj_y!
      bullet over obj_image!
      0 swap obj_ctrl!
;

: setup_bullets ( array-addr -- )
    bullets max_bullets 0 ?do
      \ setup all bullets to same
      dup setup_bullet
      \ this next line is for testing
      I over obj_y!
      object_size +
    loop
    drop
;

: setup_rock ( obj-addr -- )
      1       over obj_exist!
      2         over obj_x!
      \ -1       over obj_old_x!
      1         over obj_old_x!
      0          over obj_y!
      rock       over obj_image!
      0          swap obj_ctrl!
;

: setup_rocks ( array-addr -- )
    rocks max_rocks 0 ?do
      dup setup_rock
      \ this next line is for testing
      I over obj_y!
      object_size +
    loop
    drop
;

: setup_game
  setup_player
  setup_bullets
  setup_rocks
;

\ https://wiki.specnext.dev/Keyboard
: read_VCXZcapsshift_row $FEFE p@ 1 and ;
: read_GFDSA_row $FDFE p@ 1 and ;
: read_TREWQ_row $FBFE p@ 1 and ;
: read_54321_row $F7FE p@ 1 and ;

: read_67890_row $EFFE p@ 1 and ;
: read_YUIOP_row $DFFE p@ 1 and ;
: read_HJKLenter_row $BFFE p@ 1 and ;
: read_BNMsymbolspace_row $7FFE p@ 1 and ;

: edit_key read_54321_row           read_VCXZcapsshift_row or 1 and 0= ;
: break_key read_BNMsymbolspace_row read_VCXZcapsshift_row or 1 and 0= ;

variable kempston_status
: read_kempston $1F p@ kempston_status ! ;
: kempston_right kempston_status @ 1 and ;
: kempston_left kempston_status @ 2 and ;
: kempston_down kempston_status @ 4 and ; 
: kempston_up kempston_status @ 8 and ;
: kempston_fire1 kempston_status @ 16 and ;
: kempston_fire2 kempston_status @ 32 and ;
: kempston_start kempston_status @ 128 and ;


code halt
    $76 c,      \ halt
    $DD C, $E9 C, \   jpix  
    forth smudge

create space_gr 0 c, 0 c, 0 c, 0 c, 0 c, 0 c, 0 c, 0 c,


: erase_old ( object_addr -- )
  space_gr
  swap dup obj_y@
  swap obj_old_x@
  dup -1 > if
    xdraw ( gr-addr line column -- )
  else
    2drop drop
  then
;

: draw_new ( object_addr -- )
    dup obj_image@ 
    swap dup obj_y@ 
    swap obj_x@
    paintdraw ( gr-addr line column -- ) 
;

: draw_obj ( object_addr -- )
    dup obj_exist@ if
      dup erase_old
      dup draw_new
    then
    drop
;

: draw_objs ( objects_addr number -- )
    0 ?do
      dup draw_obj
      object_size +
    loop
    drop
;


: draw_player
    magenta ink black paper dim
    space_gr old_py old_px xdraw
    ship py px paintdraw
;

: draw_all
    draw_player

    red ink
    rocks max_rocks draw_objs

    cyan ink
    bullets max_bullets draw_objs
;

: process_objs
    \ write stuff here :-)
;

: process_keys
    read_kempston

    \ up?
    read_TREWQ_row 0=
    kempston_up
    or if
        py if
            py to old_py
            py 1- to py  
        then
    then
    \ down?
    read_GFDSA_row 0=
    kempston_down
    or if
        py 23 < if
            py to old_py
            py 1+ to py  
        then
    then
;


: btime ( colour -- )
\ swap border timing on and off using one of these two statements
    border
    \ drop
;


: run
    setup_game
    \ 00 layer!
    layer0
    black border
    cls_ula0
    magenta ink black paper dim

    begin
        process_keys    green btime
        process_objs    red btime
        draw_all        black btime
        halt            blue btime

        \ abort
        read_67890_row 0= break_key or
        kempston_start
        or
    until

    \ 12 layer!
    layer12
    cls
;

." Unused = " unused u. cr


