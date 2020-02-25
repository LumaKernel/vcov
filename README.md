# vcov - Vim Script coverage tool

[![Powered by vital.vim](https://img.shields.io/badge/powered%20by-vital.vim-80273f.svg?style=flat-square)](https://github.com/vim-jp/vital.vim)


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
$ vcov vim.profile  # -> vim.profile.lcov.info
$ # or you can specify output file
$ vcov vim.profile -o lcov.info
```

3. Send it by coverage tools or genhtml to see the result locally.

```sh
$ genhtml lcov.info
$ # open index.html in your favorite browser
```

### Mereg multiple profiles

Accepts multiple profiles.

```sh
$ vcov vim1.profile vim2.profile vim3.profile -o merged.info
```

### For more information

```
$ vcov --help
```

## Configuration

Set below environment variables to change the behavior.

- `VCOV_VIM` : Vim/neovim executable path.  ( default: `vim` )
- `VCOV_HOME` : The directory of this repository.

## Examples

Recommended you use as newer version of vim as possible.
Older versions of vim is not supported to produce the proper profile data.
(Checked: Vim 8.2 or above, neovim v0.4.3 or above)

Also please use newer version of vcov.

### vcov with vim-themis on Linux and Windows

- [LumaKernel/vital-Luv](https://github.com/LumaKernel/vital-Luv/blob/master/.github/workflows/Windows-Vim-neovim.yml)


### GitHub Actions with [coverallsapp/github-action](https://github.com/coverallsapp/github-action)

#### on Linux

```yaml

# Take profile to vim.profile

  - name: Install vcov
    run: git clone --depth 1 --branch v0.2.0 --single-branch https://github.com/LumaKernel/vcov $HOME/vcov


  - name: Make coverage report
    run: |
      export PATH=$HOME/vcov/bin:$PATH
      vcov --version
      vcov vim.profile -o lcov.info

  - name: Coveralls
    uses: coverallsapp/github-action@master
    with:
      path-to-lcov: ./lcov.info
      github-token: ${{ secrets.GITHUB_TOKEN }}
```


#### on Windows


```yaml

# Take profile to vim.profile

  - name: Install vcov
    run: git clone --depth 1 --branch v0.2.0 --single-branch https://github.com/LumaKernel/vcov $env:USERPROFILE/vcov


  - name: Make coverage report
    run: |
      $env:PATH = "$env:USERPROFILE/vcov/bin;$env:PATH"
      vcov --version
      vcov vim.profile -o lcov.info

  - name: Coveralls
    uses: coverallsapp/github-action@master
    with:
      path-to-lcov: ./lcov.info
      github-token: ${{ secrets.GITHUB_TOKEN }}
```


## Contributing

Any of patches, issues, and wiki pages are welcome !

## VS [Vimjas/covimerage](https://github.com/Vimjas/covimerage)

- Work with the number of line hits.
- Based on `lcov(1)`, so you can use `genhtml(1)` to check the result.

## Thanks

- [Vimjas/covimerage](https://github.com/Vimjas/covimerage)
  - Inspired by.
- [thinca/vim-themis](https://github.com/thinca/vim-themis)
  - The binary system is inspired by this.


## Licenese

[Unlicense](https://unlicense.org)
