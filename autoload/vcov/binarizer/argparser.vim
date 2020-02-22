
let s:COLOR = vcov#binarizer#print#COLOR()
let s:println = function('vcov#binarizer#print#println')
let s:print_finalize = function('vcov#binarizer#print#print_finalize')

let s:debug = function('vcov#internal#debug#debug')

let s:argparser = {}
function! vcov#binarizer#argparser#new(name, option) abort
  let self = deepcopy(s:argparser)
  let self.name = a:name
  let self.description = a:option.description
  let self.usage = a:option.usage
  let self.options = a:option.options
  let self.help_flags = get(a:option, 'help_flags', [])
  let self.version_flags = get(a:option, 'version_flags', [])
  let self.version = a:option.version
  call self.init()
  return self
endfunction

let s:argparser.short_keys = {}
let s:argparser.option_names = {}
let s:argparser.is_flag = {}

function! s:argparser.init() abort
  for option in self.options
    if has_key(option, 'key')
      let key = option.key
    else
      let key = option.name[0]
    endif
    for short_key in get(option, 'short', [])
      let self.short_keys[short_key] = key
    endfor
    for name in get(option, 'name', [])
      let self.option_names[name] = key
    endfor
    if get(option, 'type') =~# 'flag'
      let self.is_flag[key] = 1
    endif
  endfor
endfunction

function! s:argparser.add_value(key, value) abort
  call add(self.values, { 'key': a:key, 'value': a:value })
endfunction

function! s:argparser.check_no_key(key) abort
  if a:key isnot 0
    call s:println(self.name . ': Error: Found the flag at the illegal position.', s:COLOR.RED)
    return 1
  endif
  return 0
endfunction

function! s:argparser.parse_options(argv) abort
  let self.values = []

  let argv = a:argv
  let key = 0
  let value = 0
  let raw = 0
  let error = 0
  for v in argv
    if raw || v !~# '^-' || key isnot 0
      if key is 0
        call add(self.values, { 'value': v })
      else
        call self.add_value(key, v)
        let key = 0
      endif
    elseif v ==# '--'
      let raw = 1
    elseif v =~# '^-\w'
      let error += self.check_no_key(key)
      let skey = substitute(v, '^-', '', '')
      if has_key(self.short_keys, skey)
        let key = self.short_keys[skey]
      else
        call s:println(self.name . ': Error: Unknown option name ' . v, s:COLOR.RED)
        let error += 1
      endif
    elseif v =~# '^--\w\+'
      let error += self.check_no_key(key)
      let tail = substitute(v, '^--', '', '')
      let parts = split(tail, '=', 1)
      let value = 0
      if len(parts) == 1
        let name = tail
      else
        let name = parts[0]
        let value = join(parts[1:], '=')
      endif

      if has_key(self.option_names, name)
        let key = self.option_names[name]
      else
        call s:println(self.name . ': Error: Unknown option name ' . v, s:COLOR.RED)
        let error += 1
      endif

    endif

    if key isnot 0
      if get(self.is_flag, key)
        call self.add_value(key, v:true)
        let key = 0
      elseif value isnot 0
        call self.add_value(key, value)
        let key = 0
      endif
    endif
  endfor

  if key isnot 0
    call s:println(self.name . ': Error: Ending with the flag without the value.', s:COLOR.RED)
    let error += 1
  endif

  return [self.values, error]
endfunction

function! s:argparser.is_help(argv) abort
  if len(a:argv) == 0 | return 1 | endif
  for v in a:argv
    if v == '--'
      return 0
    endif
    if index(self.help_flags, v) != -1
      return 1
    endif
  endfor
  return 0
endfunction

function! s:argparser.is_version(argv) abort
  for v in a:argv
    if v == '--'
      return 0
    endif
    if index(self.version_flags, v) != -1
      return 1
    endif
  endfor
  return 0
endfunction

function! s:argparser.show_help() abort
  call s:println(self.name . ': ' . self.description)
  call s:println('Usage: ' . self.usage)
  call s:println('')
  call s:println('Options:')
  let lines = []
  for option in self.options
    let value_name = get(option, 'value-name', 'value')
    let type = get(option, 'type', '')
    if type ==# 'flag'
      let flags = join(
            \ map(copy(get(option, 'short', [])), '"-" . v:val')
            \ + map(copy(get(option, 'name', [])), '"--" . v:val')
            \ , ', ')
    else
      let flags = join(
            \ map(copy(get(option, 'short', [])), '"-" . v:val . " <" . value_name . ">"')
            \ + map(copy(get(option, 'name', [])), '"--" . v:val . "=<" . value_name . ">"')
            \ , ', ')
    endif
    call add(lines, [flags])
    if has_key(option, 'description')
      call add(lines[-1], option.description)
    endif
  endfor
  call add(lines, ['--', 'After this, args are not treated as flags but values.'])
  if len(self.version_flags)
    call add(lines, [join(self.version_flags, ', '), 'Show version and exit.'])
  endif
  if len(self.help_flags)
    call add(lines, [join(self.help_flags, ', '), 'Show this help and exit.'])
  endif
  let len = max(map(copy(lines), 'strlen(v:val[0])')) + 4
  for idx in range(len(lines))
    let line = lines[idx][0]
    if len(lines[idx]) > 1
      let line .= repeat(' ', len - strlen(line)) . lines[idx][1]
    endif
    call s:println('  ' . line)
  endfor
endfunction

function! s:argparser.show_version() abort
  call s:println(self.version)
endfunction

