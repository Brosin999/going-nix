{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  programs.helix = {
    enable = true;
    package = pkgs.helix;

    settings = {
      editor = {
        line-number = "relative";
        mouse = false;
        cursorline = true;
        auto-pairs = true;
        indent-guides.render = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };

      keys.normal = {
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
      };
    };

    languages = {
      language-server.nixd = {
        command = "nixd";
      };
      language-server.rust-analyzer = {
        command = "rust-analyzer";
        config.rust-analyzer.cargo.allFeatures = true;
      };
      language-server.pyright = {
        command = "pyright";
      };

      language = [
        {
          name = "nix";
          language-servers = [ "nixd" ];
          formatter = { command = "nixfmt"; args = [ "--width=100" ]; };
        }
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "python";
          language-servers = [ "pyright" ];
          formatter = { command = "ruff"; args = [ "format" "-" ]; };
        }
      ];
    };
  };
}