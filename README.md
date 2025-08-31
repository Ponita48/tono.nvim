# TONO (JSON to Native Object)

Convert your JSON to your Language Native Object.

This plugin uses [Jinja2](https://jinja.palletsprojects.com/en/stable/) as a templating library, which means you can create your own template that fits your workflow.

## Installation

In order to use this plugin, put this into your package manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "Ponita48/tono.nvim",
  config = function()
    require("tono.generator").setup()
  end
}
```

## Usage

To use this plugin, use the command below inside your neovim.

```lua
:TonoFiles
```

## Contributing

Contributions are welcome and greatly appreciated!  
Whether it's fixing a bug, improving documentation, suggesting a feature, or submitting a pull request, your help makes this project better for everyone.

### How to Contribute

1. **Create** a new branch.
2. **Make** your changes inside your branch.
3. **Push** to your branch.
4. **Open** a pull request with a detailed description of your changes.


### Reporting issues

If you find a bug or have a feature request, please open an issue and include:

- A clear title and description
- Steps to reproduce (if applicable)
- Expected vs. actual behavior
- Screenshots or logs, if helpful

✨ Thank you for contributing and helping improve this project!

