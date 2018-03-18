export MIX_TARGET=rpi

export MIX_ENV=dev
export NERVES_SYSTEM=$(pwd)/../../buildroot/rpi_custom/
mix firmware.burn
