
execute 'set runtimepath+=' . resolve(expand('<sfile>:p:h') . '/..')

let s:ProfileParser = vital#vcov#import('ProfileParser')
let s:Lcov = vital#vcov#import('ProfileParser.Lcov')

let s:COLOR = vcov#binarizer#print#COLOR()

let s:options = [
      \   {
      \     'name': ['merge'],
      \     'short': ['m'],
      \     'type': 'flag',
      \     'description': 'Merge lcov info into single file. When -o specified, automatically enabled.'
      \   },
      \   {
      \     'name': ['output'],
      \     'short': ['o'],
      \     'description': 'If merged, output to this file. By default, ''vimprofile.lcov.info'' is used.'
      \   },
      \ ]
let s:help_flags = ['--help', '-help', '-h', '-?', '/?']
let s:version_flags = ['--version', '-v']

let s:argparser = vcov#binarizer#argparser#new('vcov', {
      \   'description': 'Transform vim script profile into lcov info.',
      \   'usage': 'vcov [<options>] [--] [<inputs>]',
      \   'options': s:options,
      \   'help_flags': s:help_flags,
      \   'version_flags': s:version_flags,
      \   'version': '0.1.2',
      \ })

let s:print_initialize = function('vcov#binarizer#print#print_initialize')
let s:println = function('vcov#binarizer#print#println')
let s:print_finalize = function('vcov#binarizer#print#print_finalize')

let s:debug = function('vcov#internal#debug#debug')

function! s:start(values) abort
  let merge =
        \ len(filter(copy(a:values), {i, v -> get(v, 'key') ==# 'merge'}))
        \ + len(filter(copy(a:values), {i, v -> get(v, 'key') ==# 'output'})) ? 1 : 0
  let output = get(filter(copy(a:values), {i, v -> get(v, 'key') ==# 'output'}), -1, {'value': 'vimprofile.lcov.info'}).value
  let inputs = map(filter(copy(a:values), {i, v -> !has_key(v, 'key')}), 'v:val.value')

  call s:debug('is merge', merge)
  call s:debug('merged output file', output)
  call s:debug('input files', inputs)

  let merged_lcov = []
  let failed_to_read = []
  let failed_to_write = []
  for input in inputs
    try
      let merged = s:ProfileParser.merge(s:ProfileParser.parse(readfile(input)))
    catch /.*/
      call add(failed_to_read, input)
      continue
    endtry
    let lcov = s:Lcov.profile_to_lcov(merged)
    if merge
      let merged_lcov += lcov
    else
      let output_one = input . '.lcov.info'
      try
        silent! call mkdir(fnamemodify(output_one, ':p:h'), 'p')
        call writefile(lcov, output_one)
      catch /.*/
        echom v:throwpoint
        echom v:exception
        call add(failed_to_write, output_one)
      endtry
    endif
  endfor

  if merge
    try
      silent! call mkdir(fnamemodify(output, ':p:h'), 'p')
      call writefile(merged_lcov, output)
    catch /.*/
      echom v:throwpoint
      echom v:exception
      throw printf('Error: Failed to write merged file to %s .', fnamemodify(output, ':p'))
    endtry
  endif

  if len(failed_to_read)
    throw printf('Error: Failed to read %d file(s).', len(failed_to_read))
  endif

  if len(failed_to_write)
    throw printf('Error: Failed to write %d file(s).', len(failed_to_write))
  endif

  qall!
endfunction

function! s:main(argv) abort
  silent! %bwipeout!
  call s:print_initialize()
  call s:debug('raw argv', a:argv)

  try
    if s:argparser.is_help(a:argv)
      call s:argparser.show_help()
      call s:print_finalize()
      qall!
    elseif s:argparser.is_version(a:argv)
      call s:argparser.show_version()
      call s:print_finalize()
      qall!
    else
      let [values, error] = s:argparser.parse_options(a:argv)
      if !error
        " quit by itself
        call s:start(values)
      else
        call s:print_finalize()
        cquit!
      endif
    endif
  catch /^Error: /
    call s:println('vcov: ' . v:exception, s:COLOR.RED)
    call s:print_finalize()

    cquit!
  catch /.*/
    call s:println('vcov: Fatal: Unexpected error occured.', s:COLOR.RED)
    call s:println(v:exception, s:COLOR.RED)
    call s:println(v:throwpoint)
    call s:print_finalize()

    cquit!
  endtry
endfunction

let s:argv = argv()
if argc()
  exe '1,' . argc() . 'argdelete'
endif
call s:main(s:argv)

