
```
██╗     ███████╗███╗   ██╗███████╗  ██╗   ██╗██╗███╗   ███╗
██║     ██╔════╝████╗  ██║██╔════╝  ██║   ██║██║████╗ ████║
██║     █████╗  ██╔██╗ ██║███████╗  ██║   ██║██║██╔████╔██║
██║     ██╔══╝  ██║╚██╗██║╚════██║  ╚██╗ ██╔╝██║██║╚██╔╝██║
███████╗███████╗██║ ╚████║███████║██╗╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝ ╚═══╝  ╚═╝╚═╝     ╚═╝
```

# Lens.vim

A Vim Automatic Window Resizing Plugin

`Lens.vim` automatically resizes windows when their content exceeds their window dimensions,
but does so respecting some minimum and maximum resize bounds ensuring automatically resized
windows neither become too large (in cases of large content) or too small (in cases of small content).

## Demo

![Lens](https://user-images.githubusercontent.com/51294/75085928-222ab880-5593-11ea-881c-32f32db27fa5.gif)

## Animation

`Lens.vim` by default integrates with the [camspiers/animate.vim](https://github.com/camspiers/animate.vim) plugin for window animation.

## Installation

To install `Lens.vim`, use your plugin manager of choice, for example

### With Animation

```
Plug 'camspiers/animate.vim'
Plug 'camspiers/lens.vim'
```

### Without Animation

```
Plug 'camspiers/lens.vim'
```

## Usage

Out of the box `Lens.vim` it set up to resize windows when they are entered, and as such the minimal usecase is covered. However this can be disabled and resizing can be preformed manually using `lens#run()`.

## Options

`Lens.vim` is set up with some sensible defaults, but if needed the following can be configured:

### Disabled

The plugin can be disabled completely with:

```
let g:lens#disabled = 1
```

### Disabled Filetypes

The plugin can be disabled for specific filetypes:

```
let g:lens#disabled_filetypes = ['nerdtree', 'fzf']
```

### Animate

Animation is enabled by default, but can be disabled with:

```
let g:lens#animate = 0
```

### Resize Max Height

When resizing don't go beyond the following height

```
let g:lens#height_resize_max = 20
```

### Resize Min Height

When resizing don't go below the following height

```
let g:lens#height_resize_min = 5
```

### Resize Max Width

When resizing don't go beyond the following width

```
let g:lens#width_resize_max = 80
```

### Resize Min Width

When resizing don't go below the following width

```
let g:lens#width_resize_min = 20
```

## API

`Lens.vim` provides the following functions:

### Run

Resizes the window to respect minimal lens configuration

```
function! lens#run() abort
```

### Toggle

Toggles the plugin on and off

```
function! lens#toggle() abort
```

### Get Size

When current is smaller than target, returns target if target is within
bounds otherwise returns a value closest to target within bounds.

```
function! lens#get_size(current, target, resize_min, resize_max) abort
```

### Get Rows

Gets the rows of the current window

```
function! lens#get_rows() abort
```

### Get Cols

Gets the cols of the current window

```
function! lens#get_cols() abort
```

