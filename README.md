# ULX3S miscellaneous examples (advanced)

This is collection of miscellaneous examples for ULX3S.
Most examples are advanced and demonstrate various capabilites
of ULX3S board. Developed and tested on linux using commandline.

A novel structure of makefiles and scripts is used to ease and
the building and upload of the examples. All examples should
share same build scripts. Build scripts allow building of
the same example with diamond and trellins, to verify that
both produce mostly the same result or for a bug report if different :).

Opensource tools "prjtrellis", "nextpnr", "yosys" and "vhd2vl"
can be by default extracted to "/mt/scratch/tmp/openfpga/" and compiled.
Makefiles will use above path. This path can be changed at editing
"scripts/trellis_path.mk".

Installation of opensource tools using "make install" is not required.

## Building with Nix

All examples can be built and flashed using [Nix](https://nixos.org/) with no
manual tool installation. The `flake.nix` provides all ~70 ULX3S examples as
packages and apps.

### Quick start

```bash
# Build the simplest example (12k bitstream)
nix build .#onchip_osc_blink

# Flash it to a connected ULX3S board
nix run .#onchip_osc_blink

# Build for a different FPGA size
nix build .#onchip_osc_blink-85k

# Flash the 85k variant
nix run .#onchip_osc_blink-85k
```

### Available examples

List all available packages:

```bash
nix flake show
```

Each example is available as `nix build .#<name>` (12k default) and
`nix build .#<name>-25k`, `.#<name>-45k`, `.#<name>-85k` for other FPGA sizes.
Use `nix run .#<name>` to build and flash in one step.

A few examples:

| Package | Description |
|---|---|
| `onchip_osc_blink` | On-chip oscillator blink (simplest) |
| `audio` | Audio output (I2S, SPDIF) |
| `dvi` | DVI video output (Verilog) |
| `dvi-vhdl` | DVI video output (VHDL/GHDL) |
| `ecp5pll` | ECP5 PLL example |
| `sdram-sdram_ctrl` | SDRAM controller |
| `ps2-mouse_dvi` | PS/2 mouse with DVI output |

### Development shell

Enter a shell with all FPGA tools available:

```bash
nix develop
```

This provides yosys (with GHDL plugin), nextpnr, trellis, vhd2vl, fujprog, and
GNU Make for interactive development.
