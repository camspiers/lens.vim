" Copyright (c) 2020 Spiers, Cam <camspiers@gmail.com>
" Licensed under the terms of the MIT license.

""
" ██╗     ███████╗███╗   ██╗███████╗  ██╗   ██╗██╗███╗   ███╗
" ██║     ██╔════╝████╗  ██║██╔════╝  ██║   ██║██║████╗ ████║
" ██║     █████╗  ██╔██╗ ██║███████╗  ██║   ██║██║██╔████╔██║
" ██║     ██╔══╝  ██║╚██╗██║╚════██║  ╚██╗ ██╔╝██║██║╚██╔╝██║
" ███████╗███████╗██║ ╚████║███████║██╗╚████╔╝ ██║██║ ╚═╝ ██║
" ╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝ ╚═══╝  ╚═╝╚═╝     ╚═╝


if exists('g:lens#loaded')
  finish
endif

let g:lens#loaded = 1

if ! exists('g:lens#disabled')
  " Global disable
  let g:lens#disabled = 0
endif

if ! exists('g:lens#animate')
  " Enable animation when available
  let g:lens#animate = 1
endif

if ! exists("g:lens#resize_floating")
  " Enable resizing of neovim's floating windows
  let g:lens#resize_floating = 0
endif

" Use ratio to specify resize max/min
let g:lens#specify_dim_by_ratio = get(g:, 'lens#specify_dim_by_ratio', v:false)

" When resizing don't go beyond the following constraint
if g:lens#specify_dim_by_ratio
  let g:lens#height_resize_max = get(g:, 'lens#height_resize_max', 0.62)
  let g:lens#height_resize_min = get(g:, 'lens#height_resize_min', 0.16)
  let g:lens#width_resize_max  = get(g:, 'lens#width_resize_max', 0.67)
  let g:lens#width_resize_min  = get(g:, 'lens#width_resize_min', 0.17)
else
  let g:lens#height_resize_max = get(g:, 'lens#height_resize_max', 20)
  let g:lens#height_resize_min = get(g:, 'lens#height_resize_min', 5)
  let g:lens#width_resize_max  = get(g:, 'lens#width_resize_max', 80)
  let g:lens#width_resize_min  = get(g:, 'lens#width_resize_min', 20)
endif

if ! exists('g:lens#disabled_filetypes')
  " Disable for the following filetypes
  let g:lens#disabled_filetypes = []
endif

if ! exists('g:lens#disabled_buftypes')
  " Disable for the following buftypes
  let g:lens#disabled_buftypes = []
endif

if ! exists('g:lens#disabled_filenames')
  " Disable for the following filenames
  let g:lens#disabled_filenames = []
endif

if ! exists('g:lens#disable_for_diff')
  " Disable for the following filenames
  let g:lens#disable_for_diff = 0
endif


""
" Toggles the plugin on and off
function! lens#toggle() abort
  let g:lens#disabled = !g:lens#disabled
endfunction

""
" Returns a width or height respecting the passed configuration
function! lens#get_size(current, target, resize_min, resize_max, resize_reference) abort
  if a:current > a:target
    return a:current
  endif

  let l:resize_min = a:resize_min
  let l:resize_max = a:resize_max
  if g:lens#specify_dim_by_ratio
      let l:resize_min = float2nr(l:resize_min * a:resize_reference)
      let l:resize_max = float2nr(l:resize_max * a:resize_reference)
  endif

  return max([
    \ a:current,
    \ min([
      \ max([a:target, l:resize_min]),
      \ l:resize_max,
    \ ])
  \ ])
endfunction

""
" Gets the rows of the current window
function! lens#get_rows() abort
  return line('$')
endfunction

""
" Gets the target height
function! lens#get_target_height() abort
  return lens#get_rows() + (&laststatus != 0 ? 1 : 0)
endfunction

""
" Gets the cols of the current window
function! lens#get_cols() abort
  return max(map(getline(line("w0"),line("w$")), {k,v->len(v)}))
endfunction

""
" Gets the target width
function! lens#get_target_width() abort
  return lens#get_cols() + (wincol() - virtcol('.'))
endfunction

""
" Resizes the window to respect minimal lens configuration
function! lens#run() abort
  let width = lens#get_size(
    \ winwidth(0),
    \ lens#get_target_width(),
    \ g:lens#width_resize_min,
    \ g:lens#width_resize_max,
    \ &columns
  \)

  let height = lens#get_size(
    \ winheight(0),
    \ lens#get_target_height(),
    \ g:lens#height_resize_min,
    \ g:lens#height_resize_max,
    \ &lines
  \)

  if g:lens#animate && exists('g:animate#loaded') && g:animate#loaded
    if ! animate#window_is_animating(winnr())
      call animate#window_absolute(width, height)
    endif
  else
    execute 'vertical resize ' . width
    execute 'resize ' . height
  endif
endfunction

function! lens#win_enter(_) abort
  " Don't resize if the window is floating
  if exists('*nvim_win_get_config')
    if ! g:lens#resize_floating && nvim_win_get_config(0)['relative'] != ''
      return
    endif
  endif

  if g:lens#disabled
    return
  endif

  if index(g:lens#disabled_filetypes, &filetype) != -1
    return
  endif

  if index(g:lens#disabled_buftypes, &buftype) != -1
      return
  endif

  if len(g:lens#disabled_filenames) > 0
      let l:filename = expand('%:p')
      for l:pattern in g:lens#disabled_filenames
          if match(l:filename, l:pattern) > -1
              return
          endif
      endfor
  endif

  if g:lens#disable_for_diff == 1
    if &diff == 1
      return
    endif
  endif

  call lens#run()
endfunction

""
" Run resizing on window enter
augroup lens
    if(has('timers'))
      autocmd! WinEnter * call timer_start(100, 'lens#win_enter')
    else
      autocmd! WinEnter * call lens#win_enter(-1)
    endif
augroup END

" vim:fdm=marker
