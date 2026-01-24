(local config (require :nfnl.config))
(local default (config.default))
(local fnamemodify vim.fn.fnamemodify)

(fn compute-path [fnl-path]
  (let [rel-fnl-file (fnamemodify fnl-path ":.")
        rel-fnl-path (fnamemodify rel-fnl-file ":h")]
    (if (= :fnl/after/ftplugin rel-fnl-path)
        (.. (fnamemodify fnl-path ":h:h:h:h")
            (default.fnl-path->lua-path (fnamemodify fnl-path ":.:s?^fnl/?/?")))
        (default.fnl-path->lua-path fnl-path))))

{:fnl-path->lua-path compute-path}
