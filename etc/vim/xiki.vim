function! XikiLaunch()
  let line = line(".")

  if indent(l:line) < indent(l:line+1)
    call s:Collapse(l:line)
  else
    ruby << EOF
    xiki_dir = ENV['XIKI_DIR']
    ['ol', 'vim/line', 'vim/tree'].each {|o| require "#{xiki_dir}/lib/xiki/#{o}"}
    #line = Line.value
    line = VIM::evaluate("s:ClimbTree(line('.'))")
    #indent = line[/^ +/]
    command = "xiki #{line}"
    result = `#{command}`
    Tree << result
EOF
  end
endfunction

function! s:Collapse(from)
  let targetindent = indent(a:from)
  let delete_to = 0
  for line in range(a:from+1, line("$"))
    if indent(line) > targetindent
      let l:delete_to = line
    else
      " no more children
      break
    end
  endfor

  if delete_to > a:from
    let stored_pos = getpos(".")
    exe a:from+1 . "," . l:delete_to . "delete _"
    call setpos(".", stored_pos)
  end
endfunction

function! s:ClimbTree(line)
  let breadtrace = ""
  let lastindent = indent(a:line) + 2
  for line in range(a:line, 1, -1)
    let currentindent = indent(line)
    if lastindent > currentindent
      let breadtrace = s:CleanLine(line) . "/" . breadtrace
      let lastindent = indent(line)
    end
    if currentindent == 0
      break
    endif
  endfor

  let breadtrace = substitute(breadtrace, "\/\/", "\/", "")
  let breadtrace = substitute(breadtrace, "\/$", "", "")
  return breadtrace
endfunction

function! s:StripEnd(str)
  return substitute(a:str, " *$", "", "")
endfunction

" TODO: This should probably look more like Line.without_label
" need a way to call that method
function! s:CleanLine(lnum)
  return s:StripEnd(substitute(getline(a:lnum), "\\v^( +)(\\+ )", "", ""))
endfunction

nmap <silent> <2-LeftMouse> :call XikiLaunch()<CR>
imap <silent> <2-LeftMouse> <C-c>:call XikiLaunch()<CR>i
imap <silent> <C-CR> <C-c>:call XikiLaunch()<CR>i
nmap <silent> <C-CR> :call XikiLaunch()<CR>
