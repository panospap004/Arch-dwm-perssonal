function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

end

starship init fish | source
if test -f ~/.cache/ags/user/generated/terminal/sequences.txt
    cat ~/.cache/ags/user/generated/terminal/sequences.txt
end


alias pamcan=pacman

alias update="sudo pacman -Syu"

alias updatemir="sudo pacman -Syyu"

alias sr="sudo reboot now"

alias download="yay -S"

alias search="yay -Ss"

alias cl="clear"

#Clean orphaned packages
alias cleanup="sudo pacman -Rns $(pacman -Qtdq)"

## get top process eating memory
# alias psmem='ps auxf | sort -nr -k 4'
# alias psmem10='ps auxf | sort -nr -k 4 | head -10'
#
# ## get top process eating cpu ##
# alias pscpu='ps auxf | sort -nr -k 3'
# alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

# switch between shells
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

# the terminal rickroll
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

alias fishconfig="subl ~/.config/fish/config.fish"

# ls
alias ls='lsd -a'
alias lp='lsd -lh'
alias lt='lsd --tree --depth=3'
alias lpt='lsd -lh --tree --depth=3'
alias ll='ls -lah'
alias la='ls -A'
alias lm='ls -m'
alias lr='ls -R'
alias lg='ls -l --group-directories-first'

# git
alias gcl='git clone --depth 1'
alias gi='git init'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push origin master'


#################################mine#########################

#random pokemon
#
# if status --is-interactive
#     begin
#         echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
#         stdbuf -oL pokemon-colorscripts -r
#     end | fastfetch --logo-type file-raw --logo -
# end

if status --is-interactive
    echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" > /tmp/pokemon_logo
    pokemon-colorscripts -r >> /tmp/pokemon_logo
    fastfetch --logo-type file-raw --logo /tmp/pokemon_logo
    rm /tmp/pokemon_logo
end


###

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

## ALIASES ###
# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# vim and emacs
alias v='nvim'
alias vi='nvim'

# pacman and yay
alias pacsyu='sudo pacman -Syu' # update only standard pkgs
alias pacsyyu='sudo pacman -Syyu' # Refresh pkglist & update standard pkgs
alias parsua='paru -Sua --noconfirm' # update only AUR pkgs (paru)
alias parsyu='paru -Syu --noconfirm' # update standard pkgs and AUR pkgs (paru)
alias unlock='sudo rm /var/lib/pacman/db.lck' # remove pacman lock
alias cleanup='sudo pacman -Rns (pacman -Qtdq)' # remove orphaned packages (DANGEROUS!)


# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# adding flags
alias df='df -h' # human-readable sizes
alias free='free -m' # show sizes in MB

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
# alias psmem='ps auxf | sort -nr -k 4'
# alias pscpu='ps auxf | sort -nr -k 3'

alias usecat='cat'
alias cat='bat'
alias useman='man'
alias man='tldr'

alias find='fzf'
alias findin="fzf -q"
alias findexact="fzf -q -e"

alias vl="NVIM_APPNAME=LazyVim nvim"
alias vL="NVIM_APPNAME=lazynvim nvim"
alias vk="NVIM_APPNAME=kickstart nvim"
alias vc="NVIM_APPNAME=NvChad nvim"
alias vlu="/home/pappanos/.local/bin/lvim"
alias v="NVIM_APPNAME=MainNvim nvim"

alias rm="trash -v"

alias vpnC="sudo protonvpn connect"
alias vpnD="sudo protonvpn disconnect"

function vs
    set -l items MainNvim LazyVim lazynvim kickstart default NvChad
    set -l config (printf "%s\n" $items | fzf --prompt=" Neovim Config = " --height=~50% --layout=reverse --border --exit-0)
    if test -z "$config"
        echo "Nothing selected"
        return 0
    else if test "$config" = default
        set config ""
    end
    env NVIM_APPNAME=$config nvim $argv
end

# bind \ca "vs accept"
bind \ca vs

# emacs version

function emacs_default
    emacs --init-directory=$HOME/.config/emacs $argv
end

function MainEmacs
    emacsclient -c -s mainemacs -a "emacs --init-directory=$HOME/.config/MainEmacs"
end

function es
    set -l configs "Default" "Main"
    set -l config (printf "%s\n" $configs | fzf --prompt="Emacs Config > " --height=50% --layout=reverse --border --exit-0)
    if test -z "$config"
        echo "No configuration selected."
        return 0
    end
    switch $config
        case "Default"
            emacs --init-directory=$HOME/.config/emacs $argv
        case "Main"
            emacsclient -c -s mainemacs -a "emacs --init-directory=$HOME/.config/MainEmacs"
    end
end
# bind \ce "es accept"
bind \ce es
alias e='emacsclient -c -s mainemacs -a "emacs --init-directory=$HOME/.config/MainEmacs"'
alias em='emacsclient -c -s mainemacs -a "emacs --init-directory=$HOME/.config/MainEmacs"'
alias ed='emacsclient -c -s doomemacs -a "emacs"'
alias edm='emacsclient -c -s doomemacs -a "emacs"'


# java-home
set -x JAVA_HOME /usr/lib/jvm/java-23-jdk

set -x PATH $JAVA_HOME/bin $PATH
set -gx PATH /usr/bin $PATH

# cht.sh

function cht
    # If no arguments are provided, use fzf to select a language
    if test (count $argv) -eq 0
        set -l languages (curl -s https://cht.sh/:list | fzf --prompt="Select Language > ")
        if test -z "$languages"
            echo "No language selected."
            return 1
        end
        curl -s "https://cht.sh/$languages" | bat --paging=always
    else
        set -l topic $argv[1]
        set -l query (string join " " $argv[2..-1])

        if test -z "$query"
            curl -s "https://cht.sh/$topic" | bat --paging=always
        else
            curl -s "https://cht.sh/$topic~$query" | bat --paging=always
        end
    end
end

# yazi
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

# fzf hidden for yazi 
alias yazi_hidden="fd --hidden | fzf --preview 'show_file_or_dir_preview {}'"
alias yazi_directory="fd --type=d | fzf --preview 'show_file_or_dir_preview {}'"
alias yazi_directory_hidden="fd --type=d --hidden | fzf --preview 'show_file_or_dir_preview {}'"
alias yazi_zoxide="zoxide query -l | fzf --preview 'show_file_or_dir_preview {}'"

# zoxide basic setup faster cd for example if i am in a ~/idk/idk dir and i do z .config it will take me to my ~/.config dir without me doing cd ../../.config

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd
    builtin pwd -L
end

# A copy of fish's internal cd function. This makes it possible to use
# `alias cd=z` without causing an infinite loop.
if ! builtin functions --query __zoxide_cd_internal
    string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' <$__fish_data_dir/functions/cd.fish | source
end

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd
    if set -q __zoxide_loop
        builtin echo "zoxide: infinite loop detected"
        builtin echo "Avoid aliasing `cd` to `z` directly, use `zoxide init --cmd=cd fish` instead"
        return 1
    end
    __zoxide_loop=1 __zoxide_cd_internal $argv
end

# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
function __zoxide_hook --on-variable PWD
    test -z "$fish_private_mode"
    and command zoxide add -- (__zoxide_pwd)
end

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z
    set -l argc (builtin count $argv)
    if test $argc -eq 0
        __zoxide_cd $HOME
    else if test "$argv" = -
        __zoxide_cd -
    else if test $argc -eq 1 -a -d $argv[1]
        __zoxide_cd $argv[1]
    else if test $argc -eq 2 -a $argv[1] = --
        __zoxide_cd -- $argv[2]
    else
        set -l result (command zoxide query --exclude (__zoxide_pwd) -- $argv)
        and __zoxide_cd $result
    end
end

# Completions.
function __zoxide_z_complete
    set -l tokens (builtin commandline --current-process --tokenize)
    set -l curr_tokens (builtin commandline --cut-at-cursor --current-process --tokenize)

    if test (builtin count $tokens) -le 2 -a (builtin count $curr_tokens) -eq 1
        # If there are < 2 arguments, use `cd` completions.
        complete --do-complete "'' "(builtin commandline --cut-at-cursor --current-token) | string match --regex -- '.*/$'
    else if test (builtin count $tokens) -eq (builtin count $curr_tokens)
        # If the last argument is empty, use interactive selection.
        set -l query $tokens[2..-1]
        set -l result (command zoxide query --exclude (__zoxide_pwd) --interactive -- $query)
        and __zoxide_cd $result
        and builtin commandline --function cancel-commandline repaint
    end
end
complete --command __zoxide_z --no-files --arguments '(__zoxide_z_complete)'

# Jump to a directory using interactive search.
function __zoxide_zi
    set -l result (command zoxide query --interactive -- $argv)
    and __zoxide_cd $result
end

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

abbr --erase z &>/dev/null
alias z=__zoxide_z

abbr --erase zi &>/dev/null
alias zi=__zoxide_zi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually
# ~/.config/fish/config.fish):
#
#   zoxide init fish | source

eval "$(fzf --fish)"

# fzf theme
export FZF_DEFAULT_OPTS='
              --color=fg:#cdd6f4,fg+:#cdd6f4,bg:#1e1e2e,bg+:#313244
              --color=hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,marker:#7ddd8f
              --color=prompt:#c95056,spinner:#ffe1db,pointer:#c95056,header:#f38ba8
              --color=border:#3d235d,preview-bg:#1e1e2e,preview-scrollbar:#3d235d,label:#7897ec
              --color=query:#9caaf5
              --border="double" --border-label="󰈔 Find Files " --border-label-pos="2" --preview-window="border-rounded"
              --padding="0,1" --margin="1,2" --prompt="󰧂 " --marker=" "
              --pointer="" --separator="_" --scrollbar="" --info="right"
              --height=~65% --layout=default
              --preview "bat --color=always --style=header,grid --line-range :500 {}"'

export FZF_DEFAULT_COMMAND="fd --strip-cwd-prefix --exclude .git --exclude '.*'"
export FZF_CTRL_T_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --exclude '.*'"
export FZF_ALT_C_COMMAND="fd --type=d --type=f --hidden --strip-cwd-prefix --exclude .git --exclude '.*'"

#export FZF_ALT_C_OPTS="--preview 'if test -d {}; then lsd --icon always --tree --color=always {}; else bat --color=always -n --line-range :500 {}; fi'"

function show_file_or_dir_preview
    if test -d $argv[1]
        lsd --icon always --tree --depth=3 --color=always $argv[1] | head -200
    else
        bat -n --color=always --line-range :500 $argv[1]
    end
end

function _fzf_comprun
    set command $argv[1]
    set -e argv[1]

    switch $command
        case 'cd'
            fzf --preview 'lsd --icon always --tree --depth=3 --color=always {} | head -200' $argv
        case 'export' 'unset'
            fzf --preview 'eval "echo \${}"' $argv
        case 'ssh'
            fzf --preview 'dig {}' $argv
        case '*'
            fzf --preview 'show_file_or_dir_preview {}' $argv
    end
end

# Setup fzf previews
export FZF_CTRL_T_OPTS="--preview 'show_file_or_dir_preview {}'"
export FZF_ALT_C_OPTS="--border-label=' Find Directory ' --preview 'lsd --icon always --tree --depth=3 --color=always {} | head -200'"

# Unbind default keys
bind \ct   ""   # Unbind Ctrl+t (default fzf search)
bind \ec   ""  # Unbind Alt+c (default fzf cd)

function fzf-cd-print-path
    set -l dir (command find . -type d 2> /dev/null | fzf --border-label=' Find Directory ' --preview 'lsd --icon always --tree --depth=3 --color=always {} | head -200')
    if test -n "$dir"
        commandline -i "$dir"
    end
end

# toggle hidden files
set -g fzf_include_hidden false
#toggle hidden files
function toggle_fzf_hidden
    if string match -q "*--exclude '.*'" "$FZF_DEFAULT_COMMAND"
        # Include hidden files
        set -g FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
        set -g FZF_CTRL_T_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
        set -g FZF_ALT_C_COMMAND "fd --type=d --type=f --hidden --strip-cwd-prefix --exclude .git"
    else
        # Exclude hidden files
        set -g FZF_DEFAULT_COMMAND "fd --strip-cwd-prefix --exclude .git --exclude '.*'"
        set -g FZF_CTRL_T_COMMAND "fd --strip-cwd-prefix --exclude .git --exclude '.*'"
        set -g FZF_ALT_C_COMMAND "fd --type=d --type=f --strip-cwd-prefix --exclude .git --exclude '.*'"
    end
end

# keybind = ctrl+h
bind \ch toggle_fzf_hidden

# Bind alt+d will print the path to the directory like alt+f does
bind \cd fzf-cd-print-path
# Bind new keys
bind \cf   fzf-file-widget   # rebind ctrl+t to alt+f
bind \eh   fzf-history-widget   # bind ctrl+h to the history
bind \ed   fzf-cd-widget     # Bind ctl+d to fzf directory change

# fzf 
# you can install fzf-git and make keybinds for that currently dont need it i have lazygit
# zoxide (open a file imidiatly in nvim)
function search_with_zoxide
    # If no argument is passed, list all directories zoxide knows and let the user choose
    if test (count $argv) -eq 0
        set dir (zoxide query -l | fzf --border-label=' Find Directory ' --height=70% --preview 'lsd --icon always --tree --depth=3 --color=always {} | head -200')
        if test -n "$dir"
            cd $dir
        end
    else
        # Argument is provided, search zoxide for matches
        set matches (zoxide query -l | grep -i $argv[1])

        # Split the matches into separate lines to handle multiple matches correctly
        set -l match_array
        for match in $matches
            set match_array $match_array $match
        end

        if test (count $match_array) -eq 0
            echo "No matching directories found in zoxide database." >&2
            return 1
        end

        if test (count $match_array) -eq 1
            # Exactly one match, cd into it
            cd $match_array[1]
        else
            # Multiple matches, let the user choose with fzf
            set dir (printf "%s\n" $match_array | fzf --border-label=' Find Directory ' --height=70% --preview 'lsd --icon always --tree --depth=3 --color=always {} | head -200')
            if test -n "$dir"
                cd $dir
            else
                echo "No directory selected." >&2
                return 1
            end
        end
    end

    # After selecting or changing directory, allow searching files in the new location
    set file (fd --type f -I -H -E .git -E .git-crypt -E .cache -E .backup | fzf --border-label=' Open File in Nvim ' --height=70% --preview 'bat -n --color=always --line-range :500 {}')
    if test -n "$file"
        v $file
    end
end

# Create the nzo keybind for opening files
alias zs="search_with_zoxide"
# bind \cz "zs"
bind \cz zs

# fzf completion
function fzf_complete
    set -l token (commandline -ct)
    if test -n "$token"
        set -l completions (commandline -ct | fzf)
        if test -n "$completions"
            commandline -rt "$token" "$completions"
        end
    else
        set -l completions (ls | fzf)
        if test -n "$completions"
            commandline -it "$completions"
        end
    end
end
alias fzfc="fzf_complete"

# bind \ec "fzfc"
bind \ec fzfc

# atuin setup
atuin init fish | source
bind up _atuin_search

# bat theme
bat cache --build > /dev/null 2>&1
export BAT_THEME="Catppuccin Mocha"
