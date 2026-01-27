(local {: autoload : define} (require :conjure.nfnl.module))

(local M (define :conjure.client.scala.stdio))
(local config (autoload :conjure.config))
(local core (autoload :conjure.nfnl.core))
(local fs (autoload :conjure.nfnl.fs))
(local stdio (autoload :conjure.remote.stdio))
(local mapping (autoload :conjure.mapping))
; (local ts (autoload :conjure.tree-sitter))
(local log (autoload :conjure.log))
(local client (autoload :conjure.client))

(set M.buf-suffix :.scala)
(set M.comment-prefix "// ")
(set M.context-pattern "package (.*)$")

(config.merge {:client {:scala {:stdio {:command "scala-cli repl"
                                        :prompt_pattern :scala>
                                        :load_repl_in_sbt_context true
                                        :arguments []}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge {:client {:scala {:stdio {:mapping {:start :cs
                                                    :stop :cS
                                                    :reset :cr}}}}}))

(local cfg (config.get-in-fn [:client :scala :stdio]))
(local state (client.new-state #(do
                                  {:repl nil})))

(fn M.on-load []
  (log.dbg "Loading scala"))

(fn M.start []
  (log.dbg (.. "scala.stdio.start: prompt_pattern='" (cfg [:prompt_pattern])
               "', cmd='" (cfg [:command]) "'"))
  (if (state :repl)
      (log.append ["repl already running"])
      (core.assoc (state) :repl
                  (stdio.start {:prompt-pattern (cfg [:prompt_pattern])
                                :cmd (cfg [:command])
                                :on-success (fn []
                                              (log.dbg "REPL started successfully"))
                                :on-error (fn [err]
                                            (log.dbg err)
                                            (log.append [(.. M.comment-prefix
                                                             err)]))
                                :on-exit (fn [code signal]
                                           (log.dbg :on-exit)
                                           (let [repl (state :repl)]
                                             (when repl
                                               (repl.destroy)
                                               (core.assoc (state) :repl nil))))
                                :on-stray-output (fn [msg]
                                                   (log.append [(.. M.comment-prefix
                                                                    msg)]))}))))

(fn M.stop []
  (log.dbg "REPL stop"))

; (fn M.unbatch []
;   (vim.print :unbatch))

(fn M.on-filetype []
  (mapping.buf :ScalaStart (cfg [:mapping :start]) #(M.start)
               {:desc "Start the REPL"})
  (mapping.buf :ScalaStop (cfg [:mapping :stop]) #(M.stop)
               {:desc "Stop the REPL"}))

(fn M.eval-str [opts]
  nil)

(fn M.eval-file [opts]
  nil)

(fn M.on-exit []
  nil)

(fn M.form-node? [opts] false)

(fn M.format-msg [opts] false)

(fn M.interrupt [opts] false)

; (vim.notify (vim.inspect (config.get-in [:mapping])))
; (local cfg (config.get-in-fn [:client :scala :stdio]))

; (local state (client.new-state #(do
;                                   {:repl nil})))
; (fn cmd-to-str-arr [args cb]
;   (let [stdin (vim.uv.new_pipe false)
;         stdout (vim.uv.new_pipe false)
;         stderr (vim.uv.new_pipe false)
;         output []
;         on-exit (fn [_ _] (cb output))

;         (handle pid-or-error) (vim.uv.spawn (table.merge args) on-exit)]

;     )

(fn buildsbt-exist? [dir]
  (fs.findfile :build.sbt :/Users/brian/Development/scala-coding-challenge/))

(fn get-sbt-classpath [dir]
  "Gets the classpath for the sbt project in *dir*"
  (let [stdin (vim.uv.new_pipe false)
        stdout (vim.uv.new_pipe false)
        stderr (vim.uv.new_pipe false)
        sbt-output []
        on-exit (fn [_ _]
                  (let [regex "%[info%] %* Attributed%(([^%)]*)%)"
                        sbt-output-string (accumulate [output "" _ line (ipairs sbt-output)]
                                            (.. output line))
                        path (accumulate [classpath "" jar (string.gmatch sbt-output-string
                                                                          regex)]
                               (.. classpath jar ":"))]
                    (string.gsub path ":$" "")))
        concat-output (fn [_ data]
                        (when data
                          (table.insert sbt-output data)))
        (handle pid-or-error) (vim.uv.spawn :sbt
                                            {:stdio [stdin stdout stderr]
                                             :cwd dir
                                             :args ["show fullClasspath"]
                                             :text true}
                                            on-exit)]
    (when handle
      (stdout:read_start concat-output))))

; (get-sbt-classpath :/Users/brian/Development/scala-coding-challenge/)

M
