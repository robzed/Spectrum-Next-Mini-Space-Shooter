
\
\ drawing primitives
\

." Unused = " unused u. cr

\ needs graphics \ required for layer!
needs layer0
needs layer12

." Unused = " unused u. cr

." loading base code of the universe" cr
needs assembler

." Unused = " unused u. cr

\ swap to standard spectrum screen and back after a key
\ : show-ula 00 layer! key drop 12 layer! ;

\ This version doesn't switch the IDE mode
: show-ula layer0 key drop layer12 ;


\ calculate standard spectrum screen rows
16384 constant screenaddr
: ,8 ( base step --  ) 8 0 do 2dup I * + [compile] , loop 2drop ; 
create line_table
\ first 8 rows
screenaddr 32 ,8
\ second 8 rows
screenaddr 2048 + 32 ,8
\ third 8 rows
screenaddr 4096 + 32 ,8
\ attribute tables
\ first 8 rows
\ screenaddr 32 ,8
\ second 8 rows
\ screenaddr 32 8 * + 32 ,8
\ third 8 rows
\ screenaddr 32 16 * + 32 ,8


\ convert a line to pixel address
: line>addr ( line -- pix-addr ) 2* line_table + @ ;

\ convert a line to a attribute address
: line>attr ( line -- attr-addr ) 5 lshift $5800 + ;
\ : line>attr2 ( line -- attr-addr ) 2* line_table + 48 + @ ;

\ : laddr>attr ( pix-addr -- attr-addr ) dup $FF and $5800 | ;

: attr-at ( line column -- attr_addr ) swap line>attr + ;
: pix-at ( line column -- pix-addr ) swap line>addr + ;
: at ( line column -- attr-addr pix-addr ) 2dup attr-at -rot pix-at ;

: xdraw-forth ( gr-addr line column -- ) pix-at swap 8 0 do 2dup c@ swap c! 1+ swap 256 + swap loop 2drop ;

code pix-at-asm ( line column -- pix-addr )
  exx
  pop hl|   \ remove line and column
  ld  a'| h| \ ld a, h
  ldn h'| 0 n,
  ccf
  adchl  hl|
  addhl,  line_table NN,   \ z80n instruction
  ld     b'| (hl)|
  incx   hl|
  ld     c'| (hl)|
  addbc,a
  push bc|
  exx
  NEXT
c;

." tests" hex
0 0 pix-at-asm u.
1 0 pix-at-asm u.
2 0 pix-at-asm u.
0 1 pix-at-asm u.
0 8 pix-at-asm u.
0 23 pix-at-asm u.
23 0 pix-at-asm u.
decimal

\ code xdraw-asm ( gr-addr line column -- )
\   exx
\   pop hl|   \ remove line and column
\   ld a'| h| \ ld a, h
\   ld h'| 0 n,
\   ccf
\   adchl  hl|
\   adchl  line_table NN,
\   ld     b'| (hl)|
\   incx   hl|
\  ld     c'| (hl)|
\  addbc,a
\  pop hl|   \ graphic address
\  exx
\  NEXT
\ c;


: xdraw xdraw-forth ;



variable target_colour
: ink ( ink -- ) target_colour @ $f8 and + target_colour ! ;
: paper ( paper -- ) 3 lshift target_colour c@ $C7 and + target_colour c! ;

: bright target_colour @ $40 or target_colour c! ;

: dim target_colour @ [ $FF $40 - ] literal and target_colour c! ;

: xpaint ( colour line column -- ) attr-at c! ;

0 constant black
1 constant blue
2 constant red
3 constant magenta
4 constant green
5 constant cyan
6 constant yellow
7 constant white

\ Only works in ULA Layer 0 mode?
\ We could use .border built into vForth as well :-)
: border ( colour -- ) 7 and 254 p! ; 

: tpaint ( line column -- ) attr-at target_colour @ swap c! ;

: paintdraw ( gr-addr line column -- ) 2dup tpaint xdraw ;

32 192 * 32 24 * + constant scr+attr_len

\ cls is built into vForth, is this our version
: cls_ula0
    0 screenaddr c!
    screenaddr screenaddr 1+ scr+attr_len 1- cmove \ cmove uses ldir instruction, so use that
;


