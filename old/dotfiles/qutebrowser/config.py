#Config.py Overrides Autoconfig.yml
config.load_autoconfig()

# Configure Window Layout
c.tabs.position = "left"

# Define Keybinds
config.bind('C', 'spawn --userscript ~/.config/nixpkgs/dotfiles/qutebrowser/1pass.py fill_credentials --cache-session')
config.bind('V', 'spawn --userscript ~/.config/nixpkgs/dotfiles/qutebrowser/1pass.py fill_totp --cache-session')
