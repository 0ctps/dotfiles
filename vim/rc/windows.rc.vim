
"								__					 _
"								\ \			__ _(_)_ __
"								 > >		\ V / | '  \
"								/_/			 \_/|_|_|_|_|			___
"																				 |___|

"				* author		: 0
"				* ver				: 0.04

se shellslash
 
if !has('gui_running')
	se termencoding=cp932
en

if has('gui_running')
	se rop=type:directx,gamma:1.6,contrast:0.24,level:0.75,geom:1,renmode:5,taamode:3
	se background=dark
	color hybrid
en
