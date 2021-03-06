
$VCOV_VIM = @($env:VCOV_VIM, "vim")[[string]::IsNullOrEmpty($env:VCOV_VIM)]
$VCOV_HOME = @($env:VCOV_HOME, (Resolve-Path "$PSScriptRoot/..").path)[[string]::IsNullOrEmpty($env:VCOV_HOME)]

$SCRIPT_NAME = "$VCOV_HOME/macros/vcov-start.vim"
$VERSION = (& $VCOV_VIM --version)[0]

if ( $VERSION -cmatch "^VIM" ) {
  $IS_VIM = 1
} elseif ( $VERSION -cmatch "^NVIM" ) {
  $IS_NVIM = 1
}

if ( $IS_VIM ) {
  & $VCOV_VIM -n -N -e -s -i NONE -u $SCRIPT_NAME "--" @Args
} elseif ( $IS_NVIM ) {
  & $VCOV_VIM -n -N -e -s --headless -i NONE -u $SCRIPT_NAME "--" @Args
} else {
  Write-Error "vcov: Error: Vim or neovim executable not found"
  Write-Error "vcov: Info: Set `$env:VCOV_VIM to your vim path."
  exit 1
}

