# vcov

Vim Script coverage tool.


## Dependencies

- Vim or neovim


## Installation

Clone and pass the vcov/bin path to PATH environment.


## Usage

1. Take a profile by yourself.

```vim
" vimscript
profile start vim.profile
profile! file autoload/**/*.vim

" ...
```

2. Transform vim profile into lcov info file by vcov.

```sh
$ vcov vim.profile
$ # or you can specify output file
$ vcov vim.profile -o lcov.info
```

3. Send it by coverage tools or genhtml to see the result locally.

```sh
$ genhtml lcov.info
$ # open index.html in your favorite browser
```

## Examples

### Migration from covimerage to vcov

- [LumaKernel/vital-Luv](https://github.com/LumaKernel/vital-Luv/pull/11/commits/e366035b3ea8e929bc09d5c78dd0644c95fa01c8#diff-a6604e4f5e99849aa2479a650e4f96f8)



## VS https://github.com/Vimjas/covimerage

- Work with the line hits.
- Based on `lcov(1)`, so you can use `genhtml(1)` to check the result.

