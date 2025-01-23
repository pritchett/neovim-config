function nvim-execute-lua {
  nvim --clean --headless --server $NVIM --remote-expr "execute('lua $NVIM_LUA')" 1>/dev/null
}

function nvim-send-keys {
  nvim --clean --headless --server $NVIM --remote-send $NVIM_KEYS
}

function nvim-execute {
  nvim --clean --headless --server $NVIM --remote-expr "execute('$NVIM_VIMSCRIPT')" 1>/dev/null
}

# function nvim-z-key {
#   NVIM_KEYS="z" nvim-send-keys
# }
# zle -N nvim-z-key
# bindkey -M vicmd 'z' nvim-z-key

function nvim-toggleterm {
  NVIM_VIMSCRIPT=":${NUMERIC}ToggleTerm" nvim-execute
}
zle -N nvim-toggleterm
bindkey -M vicmd ' t' nvim-toggleterm

function nvim-neogit {
  NVIM_VIMSCRIPT=":Neogit" nvim-execute
}
zle -N nvim-neogit
bindkey -M vicmd ' g' nvim-neogit

function nvim-command-palette {
  # NVIM_VIMSCRIPT="Telescope commands theme=ivy" nvim-execute
  NVIM_VIMSCRIPT="FzfLua commands" nvim-execute
}
zle -N nvim-command-palette
bindkey -M vicmd '  ' nvim-command-palette

function nvim-wincmd {
  read -k key
  NVIM_VIMSCRIPT=":${NUMERIC}wincmd $key" nvim-execute
}
zle -N nvim-wincmd
bindkey -M vicmd "^w" nvim-wincmd

function set-mode {
  NVIM_LUA="vim.b[$BUFNR].terminal_mode = \"$NVIM_MODE\"" nvim-execute-lua
  update-lualine-winbar
}

### INSERT
function nvim-set-terminal-insert-mode {
  NVIM_MODE="INSERT" set-mode
}
zle -N nvim-set-terminal-insert-mode


function nvim-set-insert-mode {
  NVIM_MODE="INSERT" set-mode
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

function nvim-normal-g-key {
  read -k key
  case $key in
    (t)
      NVIM_VIMSCRIPT=":stopinsert!" nvim-execute
      NVIM_VIMSCRIPT=":normal ${numeric}g$key" nvim-execute
      NVIM_VIMSCRIPT=":if bufnr() == $BUFNR | execute(\"lua vim.schedule(vim.cmd.startinsert)\") | endif" nvim-execute
      ;;
    (T)
      NVIM_VIMSCRIPT=":stopinsert!" nvim-execute
      NVIM_VIMSCRIPT=":normal ${numeric}g$key" nvim-execute
      NVIM_VIMSCRIPT=":if bufnr() == $BUFNR | execute(\"lua vim.schedule(vim.cmd.startinsert)\") | endif" nvim-execute
      ;;
  esac
}
zle -N nvim-normal-g-key
bindkey -M vicmd 'g' nvim-normal-g-key

function update-lualine-winbar {
  NVIM_LUA="require(\"lualine\").refresh( { place = { \"winbar\" } } )" nvim-execute-lua
}
#### VISUAL
function nvim-set-terminal-visual-mode {
  NVIM_MODE="VISUAL" set-mode
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
  NVIM_MODE="V-LINE" set-mode
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
  NVIM_MODE="O-PENDING" set-mode
}
zle -N nvim-set-terminal-o-pending-mode

function nvim-set-o-pending-mode {
  case $KEYS in
    (c)
        if [[ $REGION_ACTIVE -eq 0 ]]
        then
          zle nvim-set-terminal-o-pending-mode
          zle vi-change
          zle nvim-set-terminal-insert-mode
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
          zle nvim-set-terminal-normal-mode
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
  NVIM_MODE="NORMAL" set-mode
}
zle -N nvim_set_buffer_terminal_mode_normal

function nvim-set-terminal-normal-mode {
  zle nvim_set_buffer_terminal_mode_normal
  zle vi-cmd-mode
}
zle -N nvim-set-terminal-normal-mode
bindkey -M viins '^[' nvim-set-terminal-normal-mode
bindkey -M viopp '^[' nvim-set-terminal-normal-mode

bindkey -M vicmd " x" execute-named-cmd

bindkey -M vicmd -r ":"

function nvim-cmd-mode {
  #nvr --remote-send "<C-\><C-n>:"
  NVIM_KEYS="<C-\><C-n>:" nvim-send-keys
}
zle -N nvim-cmd-mode
bindkey -M vicmd ":" nvim-cmd-mode

export BUFNR=`nvim --clean --headless --server $NVIM --remote-expr "bufnr()"`
NVIM_MODE='INSERT' set-mode

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

# :set backspace=start
bindkey -M viins '^?' backward-delete-char

# Has to be at the bottom of the file for some reason
function alt-k {
  NVIM_VIMSCRIPT=":${NUMERIC}wincmd k" nvim-execute
}
zle -N alt-k
bindkey -M vicmd "^[k" alt-k

function alt-j {
  NVIM_VIMSCRIPT=":${NUMERIC}wincmd j" nvim-execute
}
zle -N alt-j
bindkey -M vicmd "^[j" alt-j

function alt-h {
  NVIM_VIMSCRIPT=":${NUMERIC}wincmd h" nvim-execute
}
zle -N alt-h
bindkey -M vicmd "^[h" alt-h

function alt-l {
  NVIM_VIMSCRIPT=":${NUMERIC}wincmd l" nvim-execute
}
zle -N alt-l
bindkey -M vicmd "^[l" alt-l

function projects {
  NVIM_VIMSCRIPT=":Projects" nvim-execute
}
zle -N projects
bindkey -M vicmd " p" projects

bindkey -M viins "^p" up-line-or-history
bindkey -M viins "^n" down-line-or-history

function vi-paste {
  LBUFFER=`pbpaste`
}
zle -N vi-paste
bindkey -M viins '^v' vi-paste

function command-history {
  HLIST=`history 0 | sort -r | sed -r "s/'/''/g" | sed -r 's/\[\[/\\\\[\\\\[/g' | sed -r 's/\]\]/\\\\]\\\\]/g' | sed -r 's/^(.*)$/[[\n\1]],/'`
  NVIM_LUA='vim.ui.select({'$HLIST'}, { prompt = "Choose From History", kind = "history" },
  function(choice, idx)
    if not choice or choice == "" then
      return
    else
      vim.schedule(function()
        choice = string.gsub(choice, "^%s+%d+%s+", "")
        vim.api.nvim_chan_send(vim.bo['$BUFNR'].channel, vim.keycode("<C-c>") .. choice)
      end)
    end
  end)'
  echo $HLIST
  nvim-execute-lua
}
zle -N command-history
bindkey -M vicmd "?" command-history
