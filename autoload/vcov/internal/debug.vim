
let s:println = function('vcov#binarizer#print#println')

function! vcov#internal#debug#debug(...) abort
  if $VCOV ==# '' | return | endif
  let str = join(map(copy(a:000), 'type(v:val) == v:t_string ? v:val : string(v:val)'), ': ')
  let s:println(str)
endfunction

