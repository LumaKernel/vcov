
let s:COLOR = {}
let s:COLOR.RESET = "\e[m"
let s:COLOR.DEFAULT_FOREGROUND = "\e[39m"
let s:COLOR.BLACK = "\e[30m"
let s:COLOR.RED = "\e[31m"
let s:COLOR.GREEN = "\e[32m"
let s:COLOR.YELLOW = "\e[33m"
let s:COLOR.BLUE = "\e[34m"
let s:COLOR.MAGENTA = "\e[35m"
let s:COLOR.CYAN = "\e[36m"
let s:COLOR.LIGHT_GRAY = "\e[37m"
let s:COLOR.DARK_GRAY = "\e[90m"
let s:COLOR.LIGHT_RED = "\e[91m"
let s:COLOR.LIGHT_GREEN = "\e[92m"
let s:COLOR.LIGHT_YELLO = "\e[93m"
let s:COLOR.LIGHT_BLUE = "\e[94m"
let s:COLOR.LIGHT_MAGENTA = "\e[95m"
let s:COLOR.LIGHT_CYAN = "\e[96m"
let s:COLOR.WHITE = "\e[98m"

function! vcov#binarizer#print#COLOR() abort
  return s:COLOR
endfunction

function! vcov#binarizer#print#print_initialize() abort
  new
endfunction

function! vcov#binarizer#print#println(line, ...) abort
  let color = a:0 ? a:1 : ''
  " if has('*echoraw')
  "   call echoraw(s:COLOR.RESET . color . a:line . s:COLOR.RESET)
  " else
  " endif

  0 put=a:line
  1 print
endfunction

function! vcov#binarizer#print#print_finalize() abort
endfunction

