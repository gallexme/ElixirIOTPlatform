export MIX_TARGET=rpi
export NERVES_SYSTEM=$(pwd)/../../buildroot/rpi_custom/
mix deps.get
mix firmware
