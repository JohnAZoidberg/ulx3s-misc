{
  description = "ULX3S-misc FPGA examples - build and flash ECP5 bitstreams with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      defaultSize = "12";

      fpgaPackage = size: if size == "85" then "CABGA554" else "CABGA381";

      mkBitstream = pkgs: { name, dir, makefile ? "makefile.trellis", ghdl ? false, size ? defaultSize }:
        let
          yosysGhdl = pkgs.yosys.withPlugins [ pkgs.yosys.allPlugins.ghdl ];
        in
        pkgs.stdenv.mkDerivation {
          pname = "ulx3s-${name}";
          version = "unstable";
          src = self;

          nativeBuildInputs = (if ghdl then [
            yosysGhdl
          ] else [
            pkgs.yosys
            pkgs.vhd2vl
          ]) ++ [
            pkgs.nextpnr
            pkgs.trellis
          ];

          buildPhase = ''
            cd ${dir}
            make -f ${makefile} all FPGA_SIZE=${size} FPGA_PACKAGE=${fpgaPackage size}
          '';

          installPhase = ''
            mkdir -p $out
            cp *.bit $out/
          '';
        };

      mkFlashApp = pkgs: drv: name: {
        type = "app";
        program = toString (pkgs.writeShellScript "flash-${name}" ''
          bit=$(ls ${drv}/*.bit | head -1)
          ${pkgs.fujprog}/bin/fujprog "$bit"
        '');
      };

      # All ULX3S example definitions.
      # Skipped: onchip_osc_blink_ffm, ps2/mouse_dvi ffmlfe5, sdram/memtest_mister ffmlfe5
      examples = {
        # adc
        "adc-adc_lcd_lvds" = { dir = "examples/adc/adc_lcd_lvds/proj/lattice/ulx3s"; };

        # adxl355
        adxl355 = { dir = "examples/adxl355/proj"; };
        "adxl355-big" = { dir = "examples/adxl355/projbig"; };

        # audio
        audio = { dir = "examples/audio"; };

        # collatz
        "collatz-v" = { dir = "examples/collatz/proj"; makefile = "makefilev.trellis"; };

        # db9joy
        db9joy = { dir = "examples/db9joy"; };

        # dvi
        dvi = { dir = "examples/dvi"; };
        "dvi-vhdl" = { dir = "examples/dvi"; makefile = "makefilevhdl.trellis"; ghdl = true; };

        # dvi_osd
        dvi_osd = { dir = "examples/dvi_osd"; };
        "dvi_osd-vhdl" = { dir = "examples/dvi_osd"; makefile = "makefilevhdl.trellis"; ghdl = true; };

        # ecp5pll
        ecp5pll = { dir = "examples/ecp5pll"; ghdl = true; };
        "ecp5pll-sv" = { dir = "examples/ecp5pll"; makefile = "makefilesv.trellis"; };

        # eink
        "eink-eink154" = { dir = "examples/eink/eink154/proj"; };
        "eink-epaper290" = { dir = "examples/eink/epaper290/proj"; };

        # esp32
        esp32_passthru = { dir = "examples/esp32_passthru/proj"; };
        esp32_rmii = { dir = "examples/esp32_rmii/proj"; };

        # eth
        "eth-rmii" = { dir = "examples/eth/rmii/proj"; };

        # flash
        flash_passthru = { dir = "examples/flash_passthru/proj"; };

        # fm
        "fm-vhdl" = { dir = "examples/fm"; makefile = "makefilevhdl.trellis"; ghdl = true; };

        # gray_counter
        gray_counter = { dir = "examples/gray_counter/proj"; ghdl = true; };
        "gray_counter-v" = { dir = "examples/gray_counter/proj"; makefile = "makefilev.trellis"; };

        # hex
        "hex-dvi_hex" = { dir = "examples/hex/dvi_hex/proj"; };
        "hex-lcd_lvds_hex-480x272" = { dir = "examples/hex/lcd_lvds_hex/proj"; makefile = "makefile-480x272.trellis"; };
        "hex-lcd_st7789_hex" = { dir = "examples/hex/lcd_st7789_hex/proj"; };
        "hex-oled_ssd1306_hex" = { dir = "examples/hex/oled_ssd1306_hex/proj"; };
        "hex-oled_ssd1331_hex" = { dir = "examples/hex/oled_ssd1331_hex/proj"; };
        "hex-oled_ssd1351_hex" = { dir = "examples/hex/oled_ssd1351_hex/proj"; };

        # jtag_slave
        "jtag_slave-jtagg_hex" = { dir = "examples/jtag_slave/proj/ulx3s_jtagg_hex_v"; };
        "jtag_slave-jtag_hex_passthru" = { dir = "examples/jtag_slave/proj/ulx3s_jtag_hex_passthru_v"; };
        "jtag_slave-jtag_hex" = { dir = "examples/jtag_slave/proj/ulx3s_jtag_hex_v"; };

        # jtagthru
        jtagthru = { dir = "examples/jtagthru/proj/ulx3s_jtagthru"; };

        # lcd35
        lcd35 = { dir = "examples/lcd35/proj/lattice/ulx3s"; };

        # lcd_st7789
        "lcd_st7789-st7789_240x240" = { dir = "examples/lcd_st7789/micropython/st7789_240x240/proj"; };
        "lcd_st7789-st7789_240x240_polyline" = { dir = "examples/lcd_st7789/micropython/st7789_240x240_polyline/proj"; };

        # led64x64
        led64x64 = { dir = "examples/led64x64"; };

        # lvds_passthru
        lvds_passthru = { dir = "examples/lvds_passthru"; ghdl = true; };

        # multiboot
        "multiboot-bitstream0" = { dir = "examples/multiboot/bitstream0"; };
        "multiboot-bitstream1" = { dir = "examples/multiboot/bitstream1"; };
        "multiboot-bitstream2" = { dir = "examples/multiboot/bitstream2"; };

        # oled
        "oled-checkered" = { dir = "examples/oled/proj/ulx3s_checkered_v"; };
        "oled-spi_hex" = { dir = "examples/oled/proj/ulx3s_spi_hex_v"; };
        "oled-terminal" = { dir = "examples/oled/proj/ulx3s_terminal"; };

        # onchip_osc_blink
        onchip_osc_blink = { dir = "examples/onchip_osc_blink"; };

        # ov7670_dvi
        ov7670_dvi = { dir = "examples/ov7670_dvi/proj/ulx3s_ov7670_dvi"; };

        # ps2
        "ps2-kbd" = { dir = "examples/ps2/kbd/proj/lattice/ulx3s"; };
        "ps2-mouse" = { dir = "examples/ps2/mouse/proj/lattice/ulx3s"; };
        "ps2-mouse-vhdl" = { dir = "examples/ps2/mouse/proj/lattice/ulx3s"; makefile = "makefile.vhdl.trellis"; };
        "ps2-mouse_dvi" = { dir = "examples/ps2/mouse_dvi/proj/lattice/ulx3s"; };
        "ps2-mouse_dvi_gui" = { dir = "examples/ps2/mouse_dvi_gui/proj/lattice/ulx3s"; };
        "ps2-mouse_oled" = { dir = "examples/ps2/mouse_oled/proj/lattice/ulx3s"; };
        "ps2-mouse_oled_dvi" = { dir = "examples/ps2/mouse_oled_dvi/proj/lattice/ulx3s"; };

        # rtc
        "rtc-i2c_master" = { dir = "examples/rtc/i2c_master/proj"; };
        "rtc-i2c_master-8bit" = { dir = "examples/rtc/i2c_master/proj"; makefile = "makefile8bit.trellis"; };
        "rtc-mcp7940n" = { dir = "examples/rtc/micropython-mcp7940n/proj"; };

        # sdcard
        sdcard = { dir = "examples/sdcard/micropython/proj"; };

        # sdram
        "sdram-memtest_mister-720x480" = { dir = "examples/sdram/memtest_mister/proj/ulx3s_memtest"; makefile = "makefile-720x480.trellis"; };
        "sdram-sdram_16bit" = { dir = "examples/sdram/sdram_16bit/proj/ulx3s_sdram_hex_v"; };
        "sdram-sdram_ctrl" = { dir = "examples/sdram/sdram_ctrl/proj/ulx3s_sdram_hex_v"; };
        "sdram-sdram_mistery" = { dir = "examples/sdram/sdram_mistery/proj"; };
        "sdram-sdram_pnru" = { dir = "examples/sdram/sdram_pnru/proj"; };
        "sdram-sdram_pnru_68k" = { dir = "examples/sdram/sdram_pnru_68k/proj"; };
        "sdram-sdram_pnru_68k_180deg" = { dir = "examples/sdram/sdram_pnru_68k_180deg/proj"; };

        # serdes
        serdes = { dir = "examples/serdes"; };
        serdes_dvi = { dir = "examples/serdes_dvi"; };

        # spi_display
        "spi_display-ssd1331_vga_vhdl" = { dir = "examples/spi_display/proj/ssd1331_vga_vhdl"; ghdl = true; };
        "spi_display-st7789_osd" = { dir = "examples/spi_display/proj/st7789_osd_verilog"; };
        "spi_display-st7789_vga" = { dir = "examples/spi_display/proj/st7789_vga_verilog"; };
        "spi_display-st7789_vga_vhdl" = { dir = "examples/spi_display/proj/st7789_vga_vhdl"; ghdl = true; };

        # spi_slave
        spi_slave = { dir = "examples/spi_slave/proj/ulx3s_spirw_hex_v"; };

        # usb
        "usb-ch376" = { dir = "examples/usb/ch376/proj"; };
        "usb-usbhid_host" = { dir = "examples/usb/proj/lattice/ulx3s/usbhid_host"; ghdl = true; };
        "usb-usbhid_host-v" = { dir = "examples/usb/proj/lattice/ulx3s/usbhid_host"; makefile = "makefilev.trellis"; };
        "usb-usbkbd-v" = { dir = "examples/usb/proj/lattice/ulx3s/usbkbd"; makefile = "makefilev.trellis"; };
      };

    in
    {
      packages = forAllSystems ({ pkgs }:
        let
          build = name: attrs: size:
            mkBitstream pkgs (attrs // { inherit name size; });

          defaultPkgs = builtins.mapAttrs (name: attrs:
            build name attrs defaultSize
          ) examples;

          mkSized = size: builtins.listToAttrs (
            map (name: {
              name = "${name}-${size}k";
              value = build name (examples.${name}) size;
            }) (builtins.attrNames examples)
          );
        in
        defaultPkgs
        // mkSized "25"
        // mkSized "45"
        // mkSized "85"
        // { default = defaultPkgs.onchip_osc_blink; }
      );

      apps = forAllSystems ({ pkgs }:
        let
          allPkgs = self.packages.${pkgs.system};
          appNames = builtins.filter (n: n != "default") (builtins.attrNames allPkgs);
        in
        builtins.listToAttrs (
          map (name: {
            inherit name;
            value = mkFlashApp pkgs allPkgs.${name} name;
          }) appNames
        ) // {
          default = mkFlashApp pkgs allPkgs.default "default";
        }
      );

      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            (yosys.withPlugins [ yosys.allPlugins.ghdl ])
            nextpnr
            trellis
            vhd2vl
            fujprog
            gnumake
          ];
        };
      });
    };
}
