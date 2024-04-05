if has('gui_running')
"								__					 _
"								\ \			__ _(_)_ __
"								 > >		\ V / | '  \
"								/_/			 \_/|_|_|_|_|			___
"																				 |___|

"				* author		: 0
"				* ver				: 3.33

fu! s:source_rc(path, ...) abort
	let use_global = get(a:000, 0, !has('vim_starting'))
	let abspath = resolve(expand('~/.vim/rc/' .a:path))
	if !use_global
		exe 'source' fnameescape(abspath)
		return
	en

	let content map(readfile(abspath),
		\ 'substitute(v:val, "^\\W*\\zsset\\ze\\W", "setglobal", "")')
	let tempfile = tempname()
	try
		cal writefile(content, tempfile)
		exe 'source' fnameescape(tempfile)
	finally
		if filereadable(tempfile)
			cal delete(tempfile)
		en
	endt
endf

let s:im_windows = has('win32') || has('win64')

fu! s:ruwindows() abort
	return s:im_windows
endf

fu! s:rumac() abort
	return !s:im_windows && !has('win32unix')
		\ && (has('mac') || has('macunix') || has('gui_macvim')
		\		|| (!executable('xdg-open') && system('uname') =~? '^darwin'))
endf

aug fau
		au!
aug END

se cmdheight=1

se guioptions-=m
se guioptions-=T
se guioptions-=r
se guioptions-=R
se guioptions-=l
se guioptions-=L
se guioptions-=b

se fileencoding=utf-8
se fileencodings=utf-8,iso-2022-jp,cp932,euc-jp

if has('mouse')
	se mouse=a
en

if has('multi_byte_ime')
	se iminsert=0 imsearch=0
en

" * >>	font -------------------------------------------/
" [[

" sample
"		Keep it simple, stupid.
"		<>?~`!@#$%^&*()_+--{}|[]\:";'
"		1234567890
"		恥の多い生涯を送ってきました。

se guifont=Migu_2M:h10:cSHIFTJIS
if exists('&ambiwidth')
		se ambiwidth=double
en

" ]]
" * << -------------------------------------------------/



if s:ruwindows()
	cal s:source_rc('windows.rc.vim')
elseif has('unix')
	cal s:source_rc('unix.rc.vim')
en

if s:rumac()
	se guifont=Migu_2M:h10:cANSI
en

" ]
en
