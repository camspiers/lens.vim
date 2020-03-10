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

if ! exists('g:lens#height_resize_max')
  " When resizing don't go beyond the following height
  let g:lens#height_resize_max = 20
endif

if ! exists('g:lens#height_resize_min')
  " When resizing don't go below the following height
  let g:lens#height_resize_min = 5
endif

if ! exists('g:lens#width_resize_max')
  " When resizing don't go beyond the following width
  let g:lens#width_resize_max = 80
endif

if ! exists('g:lens#width_resize_min')
  " When resizing don't go below the following width
  let g:lens#width_resize_min = 20
endif

if ! exists('g:lens#disabled_filetypes')
  " Disable for the following filetypes
  let g:lens#disabled_filetypes = []
endif

if ! exists('g:lens#disabled_buftypes')
  " Disable for the following buftypes
  let g:lens#disabled_buftypes = []
endif

""
" Toggles the plugin on and off
function! lens#toggle() abort
  let g:lens#disabled = !g:lens#disabled
endfunction

""
" Returns a width or height respecting the passed configuration
function! lens#get_size(current, target, resize_min, resize_max) abort
  if a:current > a:target
    return a:current
  endif
  return max([
    \ a:current,
    \ min([
      \ max([a:target, a:resize_min]),
      \ a:resize_max,
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
  return max(map(getline(1,'$'), {k,v->len(v)}))
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
    \ g:lens#width_resize_max
  \)

  let height = lens#get_size(
    \ winheight(0),
    \ lens#get_target_height(),
    \ g:lens#height_resize_min,
    \ g:lens#height_resize_max
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

function! lens#win_enter() abort
  " Don't resize if the window is floating
  if exists('*nvim_win_get_config')
    if ! g:lens#resize_floating && nvim_win_get_config(0)['relative'] != ''
      return
    endif
  endif

  if g:lens#disabled || g:lens#enter_disabled
    return
  endif

  if index(g:lens#disabled_filetypes, &filetype) != -1
    return
  endif

  if index(g:lens#disabled_buftypes, &buftype) != -1
      return
  endif

  call lens#run()
endfunction

""
" By default set up running resize on window enter except for new windows
augroup lens
  let g:lens#enter_disabled = 0
  autocmd! WinNew * let g:lens#enter_disabled = 1
  autocmd! WinEnter * call lens#win_enter()
  autocmd! WinNew * let g:lens#enter_disabled = 0
augroup END

" vim:fdm=marker
