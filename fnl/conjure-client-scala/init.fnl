; (local {: autoload} (require :conjure.nfnl.module))
; (local config (autoload :conjure.config))
; (local core (autoload :conjure.nfnl.core))
;
; (fn setup []
;   (let [filetypes (. vim.g "conjure#filetypes")
;         new-filetypes (vim.list_extend filetypes [:scala])]
;     (tset vim.g "conjure#filetypes" new-filetypes))
;   (tset vim.g "conjure#filetype#scala" :conjure-client-scala.stdio))
;
; {: setup}
