" ___vital___
" NOTE: lines between '" ___vital___' is generated by :Vitalize.
" Do not modify the code nor insert new lines before '" ___vital___'
function! s:_SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
endfunction
execute join(['function! vital#_vcov#ProfileParser#Lcov#import() abort', printf("return map({'profile_to_lcov': '', '_vital_loaded': ''}, \"vital#_vcov#function('<SNR>%s_' . v:key)\")", s:_SID()), 'endfunction'], "\n")
delfunction s:_SID
" ___vital___
" Transform to lcov(1) format
" Spec: geninfo(1) / FILES
" Ref: http://ltp.sourceforge.net/coverage/lcov/geninfo.1.php
"
" Author: Luma
" License: Unlicense

" XXX : Extensiablity
"   - Add ignore lines
"   - Add ignore commands
"   - Add ignore patterns
"   - ignore vs through

let s:_possible_comment_pat = '\%(".*\)\?'
let s:_continue_pat = '^\s*\\'

function! s:_vital_loaded(V) abort
  let s:_endif_pat = s:_make_ex_pat('en', 'dif')
  let s:_endfunction_pat = s:_make_ex_pat('endf', 'unction')
  let s:_endfor_pat = s:_make_ex_pat('endfo', 'r')
  let s:_endwhile_pat = s:_make_ex_pat('endw', 'hile')
endfunction

" type MergedProfileJSON is generated by ProfileParser.parse() and .merge()

" @param {MergedProfileJSON} profile
function! s:profile_to_lcov(profile) abort
  let res = []
  for section in a:profile
    if section.type ==# 'script'
      let res += s:_to_lcov_one(section)
    endif
  endfor
  return res
endfunction

function! s:_to_lcov_one(section) abort
  let res = []
  call add(res, 'TN:')
  call add(res, printf('SF:%s', a:section.path))

  let line_found = 0
  let line_hit = 0
  let branch_found = 0
  let branch_hit = 0

  let idx = 0
  let branch_idx = 0

  let collected = ''
  while idx < len(a:section.lines)
    let line = a:section.lines[idx]
    let hits = v:null
    let next = get(get(a:section.lines, idx + 1, {}), 'content', v:null)
    if next isnot v:null && next =~# s:_continue_pat
      let collected .= line.content
    else
      let is_inst = s:_is_instrumental(
            \   collected . substitute(line.content, s:_continue_pat, '', '')
            \ )
      let collected .= ''
      if is_inst
        let hits = get(line, 'count', 0)
      endif
    endif
    if hits isnot v:null
      let line_found += 1
      let line_hit += hits != 0
      call add(res, printf('DA:%d,%d', idx + 1, hits))
    endif
    if has_key(line, 'branches')
      let branch_cond_idx = 0
      for branch in line.branches
        call add(res, printf('BRDA:%d,%d,%d,%d', idx + 1, branch_idx, branch_cond_idx, branch.hit))
        let branch_cond_idx += 1
        let branch_found += 1
        let branch_hit += branch.hit != 0
      endfor
      let branch_idx += 1
    endif
    let idx += 1
  endwhile
  if branch_found
    call add(res, printf('BRH:%d', branch_hit))
    call add(res, printf('BRF:%d', branch_found))
  endif

  call add(res, printf('LH:%d', line_hit))
  call add(res, printf('LF:%d', line_found))
  call add(res, 'end_of_record')
  return res
endfunction

function! s:_is_instrumental(content) abort

  if a:content =~# '^#!'
    return 0
  elseif a:content =~# '^\s*' . s:_possible_comment_pat . '$'
    return 0
  elseif a:content =~# '^\s*' . '\%('
        \ . s:_endif_pat . '\|'
        \ . s:_endfunction_pat . '\|'
        \ . s:_endfor_pat . '\|'
        \ . s:_endwhile_pat
        \ . '\)\>\s*' . s:_possible_comment_pat . '$'
    return 0
  endif
  return 1
endfunction

function! s:_make_ex_pat(pre, suf) abort
  let pats = [a:pre]
  for idx in range(strlen(a:suf))
    call add(pats, a:pre . a:suf[: idx])
  endfor
  return join(pats, '\|')
endfunction

