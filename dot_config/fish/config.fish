# This is your fish shell configuration file! You can edit this file to customize your fish shell experience.
# IMPORTANT! The Garuda Linux defaults are set in /usr/share/garuda/garuda-fish-config/config.fish.
# IMPORTANT! Do not edit the defaults file directly, as it will be overwritten during system updates. (You can however read it to learn and get ideas!)
# Instead, you simply add your customizations to this file, and they will override the defaults.

source /usr/share/garuda/garuda-fish-config/config.fish # Do not edit this defaults file!

# -- Insert customizations below this line! --

# Override Garuda's Starship prompt with Tide
if status --is-interactive
    source ~/.config/fish/functions/fish_prompt.fish
end

abbr --add --set-cursor cf "fresh% ~/.config/fish/config.fish"
abbr --add --set-cursor cs "fresh% ~/.config/sway/config"
abbr --add --set-cursor cw "fresh% ~/.config/wezterm/wezterm.lua"
abbr --add --set-cursor cr "fresh% ~/.config/rofi/config.rasi"

abbr --add clr "clear && fastfetch"
abbr --add lg "lazygit"
abbr --add lc "chezmoi-mousse"
abbr --add cz --set-cursor "chezmoi %"
abbr --add gtree "git log --graph --oneline --all --decorate"

alias czd 'pushd /home/adam/.local/share/chezmoi && lazygit; popd'
alias rb 'systemctl -i reboot'
alias sd 'systemctl -i poweroff'
alias ff 'fastfetch --config neofetch.jsonc'
alias mx3 'ssh adam@192.168.1.250 -t "fish"'
alias up 'upd && rustup update && cargo install-update -a'
# alias nano 'fresh'
# alias micro 'fresh'
# # Make 'you should use this' fish plugin ignore the above alias
# set -x YSU__IGNORED_GLOBAL_ALIASES nano
# set -x YSU__IGNORED_GLOBAL_ALIASES micro


# Add to PATH
if test -d ~/.cargo/bin
    if not contains -- ~/.cargo/bin $PATH
        set -p PATH ~/.cargo/bin
    end
end

function bak --argument filename
    cp $filename $filename.bak
end


# Don't overwrite scratchpad terminal title
if set -q SCRATCH_TITLE
    function fish_title
        echo $SCRATCH_TITLE
    end
end



# Keep this at the bottom of the file.
# This shows the "neofetch"/fastfetch output when you open a new terminal.
# If you don't want to see it, simply comment out the line below.
__garuda_fastfetch
