
let s:println = function('vcov#binarizer#print#println')

function! vcov#internal#debug#debug(...) abort
  if $VCOV_DEBUG ==# '' | return | endif
  let str = join(map(copy(a:000), 'type(v:val) == v:t_string ? v:val : string(v:val)'), ': ')
  call s:println(str)
endfunction

