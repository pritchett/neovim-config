
function nvim-toggleterm {
  (nvr -c ":${NUMERIC}ToggleTerm" &)
}
zle -N nvim-toggleterm
bindkey -M vicmd ' t' nvim-toggleterm

function nvim-wincmd {
  read -k key
  nvr -c ":${NUMERIC}wincmd $key"
}
zle -N nvim-wincmd
bindkey -M vicmd "^w" nvim-wincmd

### INSERT
function nvim-set-terminal-insert-mode {
(nvr -c "lua vim.b[$BUFNR].terminal_mode = 'INSERT'" & nvr -c "lua require('lualine').refresh( { place = { 'winbar' }})" &)
}
zle -N nvim-set-terminal-insert-mode 

function nvim-set-insert-mode {
  zle nvim-set-terminal-insert-mode
  case $KEYS in
    (a)
        zle vi-add-next
        ;;
    (A)
        zle vi-add-eol
        ;;
    (i)
        zle vi-insert
        ;;
    (C)
        zle vi-change-eol
        ;;
    (I)
        zle vi-insert-bol
        ;;
    (O)
        zle vi-open-line-above
        ;;
    (o)
        zle vi-open-line-below
        ;;
    (s)
        zle vi-substitute
        ;;
    (S)
        zle vi-change-whole-line
        ;;
  esac
  
}
zle -N nvim-set-insert-mode
bindkey -M vicmd 'a' nvim-set-insert-mode
bindkey -M vicmd 'A' nvim-set-insert-mode
bindkey -M vicmd 'i' nvim-set-insert-mode
bindkey -M vicmd 'C' nvim-set-insert-mode
bindkey -M vicmd 'I' nvim-set-insert-mode
bindkey -M vicmd 'O' nvim-set-insert-mode
bindkey -M vicmd 'o' nvim-set-insert-mode
bindkey -M vicmd 'S' nvim-set-insert-mode
bindkey -M vicmd 's' nvim-set-insert-mode

#### VISUAL
function nvim-set-terminal-visual-mode {
(nvr -c "lua vim.b[$BUFNR].terminal_mode = 'VISUAL'" & nvr -c "lua require('lualine').refresh( { place = { 'winbar' }})" &)
}
zle -N nvim-set-terminal-visual-mode

function nvim-set-visual-mode {
  zle nvim-set-terminal-visual-mode
  zle visual-mode
}
zle -N nvim-set-visual-mode
bindkey -M vicmd 'v' nvim-set-visual-mode

function nvim-deactivate-region {
  zle nvim_set_buffer_terminal_mode_normal
  zle deactivate-region
}
zle -N nvim-deactivate-region
bindkey -M visual '^[' nvim-deactivate-region

#### V-LINE (VISUAL-LINE)
function nvim-set-terminal-v-line-mode {
(nvr -c "lua vim.b[$BUFNR].terminal_mode = 'V-LINE'" & nvr -c "lua require('lualine').refresh( { place = { 'winbar' }})" &)
}
zle -N nvim-set-terminal-v-line-mode

function nvim-set-v-line-mode {
  zle nvim-set-terminal-v-line-mode
  zle visual-line-mode
}
zle -N nvim-set-v-line-mode
bindkey -M vicmd 'V' nvim-set-v-line-mode

#### O-PENDING
function nvim-set-terminal-o-pending-mode {
(nvr -c "lua vim.b[$BUFNR].terminal_mode = 'O-PENDING'" & nvr -c "lua require('lualine').refresh( { place = { 'winbar' }})" &)
}
zle -N nvim-set-terminal-o-pending-mode

function nvim-set-o-pending-mode {
  case $KEYS in
    (c)
        if [[ $REGION_ACTIVE -eq 0 ]]
        then
          zle nvim-set-terminal-o-pending-mode
          zle vi-change
        else
          zle nvim-set-terminal-insert-mode
          zle vi-change
        fi
        ;;
    (d)
        if [[ $REGION_ACTIVE -eq 0 ]]
        then
          zle nvim-set-terminal-o-pending-mode
          zle vi-delete
        else
          zle nvim-set-terminal-insert-mode
          zle vi-delete
        fi
        ;;
    esac
}
zle -N nvim-set-o-pending-mode
bindkey -M vicmd 'c' nvim-set-o-pending-mode
bindkey -M vicmd 'd' nvim-set-o-pending-mode

### NORMAL

function nvim_set_buffer_terminal_mode_normal {
  (nvr -c "lua vim.b[$BUFNR].terminal_mode = 'NORMAL'" & nvr -c "lua require('lualine').refresh( { place = { 'winbar' }})" &)
}
zle -N nvim_set_buffer_terminal_mode_normal

function nvim-set-terminal-normal-mode {
  zle nvim_set_buffer_terminal_mode_normal
  zle vi-cmd-mode
}
zle -N nvim-set-terminal-normal-mode
bindkey -M viins '^[' nvim-set-terminal-normal-mode
bindkey -M viopp '^[' nvim-set-terminal-normal-mode

function nvim-edit-with-oil {
  case $KEYS in
    (\ o)
        nvr -c "e $PWD"
        ;;
    (\ e)
        nvr -c "wincmd k | belowright split | e $PWD"
        ;;
    esac
}
zle -N nvim-edit-with-oil 
bindkey -M vicmd ' o' nvim-edit-with-oil
bindkey -M vicmd ' e' nvim-edit-with-oil

bindkey -M vicmd " x" execute-named-cmd

bindkey -M vicmd -r ":"

function nvim-cmd-mode {
  nvr --remote-send "<C-\><C-n>:"
}
zle -N nvim-cmd-mode
bindkey -M vicmd ":" nvim-cmd-mode

export BUFNR=`nvr --remote-expr "bufnr()"`
# nvr -c "lua vim.b[$BUFNR].terminal_mode = 'INSERT'"

bindkey -rpM vicmd "^["
bindkey -rpM viins "^["
bindkey -M visual -r "^[OA"
bindkey -M visual -r "^[OB"
bindkey -M visual -r "^[[A"
bindkey -M visual -r "^[[B"
bindkey -M viopp -r "^[OA"
bindkey -M viopp -r "^[OB"
bindkey -M viopp -r "^[[A"
bindkey -M viopp -r "^[[B"
