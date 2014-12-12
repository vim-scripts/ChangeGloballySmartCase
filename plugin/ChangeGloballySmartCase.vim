" ChangeGloballySmartCase.vim: Change {motion} text and repeat as SmartCase substitution.
"
" DEPENDENCIES:
"   - ChangeGlobally.vim autoload script
"   - ingo/smartcase.vim autoload script
"   - SmartCase.vim plugin (SmartCase() function)
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.30.007	20-Jun-2014	Factor out SmartCase search pattern conversion
"				to ingo#smartcase#FromPattern().
"   1.30.006	16-Jun-2014	ENH: Implement global delete as a specialization
"				of an empty change.
"				Add a:isDelete flag to
"				ChangeGlobally#SetParameters().
"				Define duplicate delete mappings, with a default
"				mapping to gX instead of gC.
"				FIX: Substitution to make all non-alphabetic
"				delimiter characters and whitespace optional
"				didn't correctly deal with newline \n and the
"				escaped \/ and \\. Tweak the regexp to deal with
"				those.
"				Avoid invoking SmartCase() on empty string. In
"				the debugger, I've seen it turn it into a
"				newline.
"   1.20.005	14-Jun-2013	Minor: Make substitute() robust against
"				'ignorecase'.
"   1.20.004	19-Apr-2013	Adapt to ChangeGlobally.vim version 1.20:
"				Stop duplicating s:count into l:replace and
"				instead access directly from
"				ChangeGlobally#CountedReplace(); i.e. drop the
"				argument of
"				ChangeGloballySmartCase#CountedReplace(), too.
"   1.20.003	18-Apr-2013	Use optional visualrepeat#reapply#VisualMode()
"				for normal mode repeat of a visual mapping.
"				When supplying a [count] on such repeat of a
"				previous linewise selection, now [count] number
"				of lines instead of [count] times the original
"				selection is used.
"   1.00.002	26-Sep-2012	Also allow delimiters between CamelCase
"				fragments in a:search.
"	001	25-Sep-2012	file creation from plugin/ChangeGlobally.vim

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ChangeGloballySmartCase') || (v:version < 700)
    finish
endif
let g:loaded_ChangeGloballySmartCase = 1
let s:save_cpo = &cpo
set cpo&vim

"- functions -------------------------------------------------------------------

function! ChangeGloballySmartCase#CountedReplace()
    let l:newText = ChangeGlobally#CountedReplace()
    return (l:newText ==# submatch(0) ?
    \   l:newText :
    \   (empty(l:newText) ?
    \       '' :
    \       SmartCase(l:newText)
    \   )
    \)
endfunction
function! ChangeGloballySmartCase#Hook( search, replace, ... )
    " Use a case-insensitive match (replace \V\C with \V\c, as the hook doesn't
    " allow to append the /i flag to the :substitute command).
    let l:search = a:search[4:]

    " The substitution separator is /; therefore, the escaped form (\/) must be
    " converted, too.
    return [
    \   '\V' . ingo#smartcase#FromPattern(l:search, '/'),
    \   substitute(a:replace, '\CChangeGlobally#CountedReplace', 'ChangeGloballySmartCase#CountedReplace', '')
    \]
endfunction


"- mappings --------------------------------------------------------------------

nnoremap <silent> <expr> <SID>(ChangeGloballySmartCaseOperator) ChangeGlobally#OperatorExpression()
nnoremap <silent> <script> <Plug>(ChangeGloballySmartCaseOperator) :<C-u>call ChangeGlobally#SetParameters(0, v:count, 0, "\<lt>Plug>(ChangeGloballySmartCaseRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)", function('ChangeGloballySmartCase#Hook'))<CR><SID>(ChangeGloballySmartCaseOperator)
if ! hasmapto('<Plug>(ChangeGloballySmartCaseOperator)', 'n')
    nmap gC <Plug>(ChangeGloballySmartCaseOperator)
endif
nnoremap <silent> <Plug>(ChangeGloballySmartCaseLine)
\ :<C-u>call setline('.', getline('.'))<Bar>
\call ChangeGlobally#SetParameters(0, 0, 0, "\<lt>Plug>(ChangeGloballySmartCaseRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)", function('ChangeGloballySmartCase#Hook'))<Bar>
\execute 'normal! V' . v:count1 . "_\<lt>Esc>"<Bar>
\call ChangeGlobally#Operator('V')<CR>
if ! hasmapto('<Plug>(ChangeGloballySmartCaseLine)', 'n')
    nmap gCC <Plug>(ChangeGloballySmartCaseLine)
endif

vnoremap <silent> <Plug>(ChangeGloballySmartCaseVisual)
\ :<C-u>call setline('.', getline('.'))<Bar>
\call ChangeGlobally#SetParameters(0, v:count, 1, "\<lt>Plug>(ChangeGloballySmartCaseRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)", function('ChangeGloballySmartCase#Hook'))<Bar>
\call ChangeGlobally#Operator(visualmode())<CR>
if ! hasmapto('<Plug>(ChangeGloballySmartCaseVisual)', 'x')
    xmap gC <Plug>(ChangeGloballySmartCaseVisual)
endif



nnoremap <silent> <script> <Plug>(DeleteGloballySmartCaseOperator) :<C-u>call ChangeGlobally#SetParameters(1, v:count, 0, "\<lt>Plug>(ChangeGloballySmartCaseRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)", function('ChangeGloballySmartCase#Hook'))<CR><SID>(ChangeGloballySmartCaseOperator)
if ! hasmapto('<Plug>(DeleteGloballySmartCaseOperator)', 'n')
    nmap gX <Plug>(DeleteGloballySmartCaseOperator)
endif
nnoremap <silent> <Plug>(DeleteGloballySmartCaseLine)
\ :<C-u>call setline('.', getline('.'))<Bar>
\call ChangeGlobally#SetParameters(1, 0, 0, "\<lt>Plug>(ChangeGloballySmartCaseRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)", function('ChangeGloballySmartCase#Hook'))<Bar>
\execute 'normal! V' . v:count1 . "_\<lt>Esc>"<Bar>
\call ChangeGlobally#Operator('V')<CR>
if ! hasmapto('<Plug>(DeleteGloballySmartCaseLine)', 'n')
    nmap gXX <Plug>(DeleteGloballySmartCaseLine)
endif

vnoremap <silent> <Plug>(DeleteGloballySmartCaseVisual)
\ :<C-u>call setline('.', getline('.'))<Bar>
\call ChangeGlobally#SetParameters(1, v:count, 1, "\<lt>Plug>(ChangeGloballySmartCaseRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)", function('ChangeGloballySmartCase#Hook'))<Bar>
\call ChangeGlobally#Operator(visualmode())<CR>
if ! hasmapto('<Plug>(DeleteGloballySmartCaseVisual)', 'x')
    xmap gX <Plug>(DeleteGloballySmartCaseVisual)
endif



nnoremap <silent> <Plug>(ChangeGloballySmartCaseRepeat)
\ :<C-u>call setline('.', getline('.'))<Bar>
\call ChangeGlobally#Repeat(0, "\<lt>Plug>(ChangeGloballySmartCaseRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)")<CR>

vnoremap <silent> <Plug>(ChangeGloballySmartCaseVisualRepeat)
\ :<C-u>call setline('.', getline('.'))<Bar>
\call ChangeGlobally#Repeat(1, "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)")<CR>

" A normal-mode repeat of the visual mapping is triggered by repeat.vim. It
" establishes a new selection at the cursor position, of the same mode and size
" as the last selection.
" Note: The cursor is placed back at the beginning of the selection (via "o"),
" so in case the repeat substitutions fails, the cursor will stay at the current
" position instead of moving to the end of the selection.
"   If [count] is given, that number of lines is used / the original size is
"   multiplied accordingly. This has the side effect that a repeat with [count]
"   will persist the expanded size, which is different from what the normal-mode
"   repeat does (it keeps the scope of the original command).
nnoremap <silent> <Plug>(ChangeGloballySmartCaseVisualRepeat)
\ :<C-u>call setline('.', getline('.'))<Bar>
\execute 'normal!' ChangeGlobally#VisualMode()<Bar>
\call ChangeGlobally#Repeat(1, "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)", "\<lt>Plug>(ChangeGloballySmartCaseVisualRepeat)")<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
