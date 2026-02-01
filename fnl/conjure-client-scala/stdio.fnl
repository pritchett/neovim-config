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
(local state (client.new-state #{:repl nil}))

(fn log-append [msg]
  (fn starts-with-comment-prefix? [str]
    (string.match str (.. "^" M.comment-prefix)))

  (fn with-comment-prefix [str]
    (if (starts-with-comment-prefix? str)
        str
        (.. M.comment-prefix str)))

  (when msg
    (let [wrapped-msg (if (core.table? msg)
                          (core.map with-comment-prefix msg)
                          [(with-comment-prefix msg)])]
      (log.append wrapped-msg))))

(fn repl-send [msg cb opts]
  (log.dbg (.. "scala.stdio.repl-send: opts='" (core.str opts) "'"))
  (log.dbg (.. "scala.stdio.repl-send: msg='" (core.str msg) "'"))
  (let [repl (state :repl)]
    (if repl
        (repl.send msg cb opts)
        (log-append "REPL is not connected."))))

(fn reset []
  (repl-send ":reset\n" (fn [msgs]
                          (let [all-msgs (icollect [_ msg (ipairs msgs)]
                                           msg.out)]
                            (log-append all-msgs)))
             {:batch? true}))

(fn buildsbt-exist? [dir]
  (fs.findfile :build.sbt dir))

(fn M.on-load []
  (log.dbg :scala.stdio.on-load))

(fn with-sbt-classpath [dir cb]
  "Gets the classpath for the sbt project in *dir*"
  (fn extract [sbt-output]
    (let [regex "%[info%] %* Attributed%(([^%)]*)%)"
          sbt-output-string (accumulate [output "" _ line (ipairs sbt-output)]
                              (.. output line))
          path (accumulate [classpath "" jar (string.gmatch sbt-output-string
                                                            regex)]
                 (.. classpath jar ":"))]
      (let [classpath (string.gsub path ":$" "")]
        (cb classpath))))

  (let [stdin nil
        stdout (vim.uv.new_pipe false)
        stderr (vim.uv.new_pipe false)
        sbt-output {}
        on-error (fn [err data]
                   (assert (not err) err)
                   (if data
                       (log.dbg (.. "Error: " (vim.inspect data)))
                       (log-append data)))
        on-exit (client.schedule-wrap #(extract sbt-output))
        concat-output (fn [err data]
                        (when err
                          (log.dbg (.. "ERROR: " err)))
                        (when data
                          (log.dbg (.. "getting data: " data))
                          (table.insert sbt-output data)))
        (handle pid-or-error) (vim.uv.spawn :sbt
                                            {:stdio [stdin stdout stderr]
                                             :cwd dir
                                             :args ["show fullClasspath"]
                                             :text true}
                                            on-exit)]
    (when handle
      (log.dbg (.. "Retrieving classpath from sbt with pid " pid-or-error))
      (stderr:read_start (client.schedule-wrap on-error))
      (stdout:read_start (client.schedule-wrap concat-output)))))

(fn M.start []
  (log.dbg (.. "scala.stdio.start: prompt_pattern='" (cfg [:prompt_pattern])
               "', cmd='" (cfg [:command]) "'"))
  (log-append "Starting the REPL...")

  (fn start [args]
    (fn on-exit [code signal]
      (when (and (= :number (type code)) (> code 0))
        (log.append (.. M.comment-prefix "process exited with code "
                        (core.str code))))
      (when (and (= :number (type signal)) (> signal 0))
        (log.append (.. M.comment-prefix "process exited with signal "
                        (core.str signal))))
      (let [repl (state :repl)]
        (when repl
          (repl.destroy)
          (core.assoc (state) :repl nil))))

    (fn on-success []
      (log.dbg :scala.stdio.start.on-success))

    (fn on-error [err]
      (log.dbg (.. "scala.stdio.start.on-error: " (core.str err)))
      (log-append err))

    (fn on-stray-output [msg]
      (log.dbg (.. "scala.stdio.start on-stray-output='" msg.out "'"))
      (each [out (string.gmatch msg.out "([^\n]+)")] (log-append out)))

    (client.schedule #(core.assoc (state) :repl
                                  (do
                                    (log.dbg "Starting REPL")
                                    (stdio.start {:prompt-pattern (cfg [:prompt_pattern])
                                                  :cmd (cfg [:command])
                                                  : args
                                                  : on-success
                                                  : on-error
                                                  : on-exit
                                                  : on-stray-output})))))

  (if (state :repl)
      (log-append "REPL is already connected")
      (let [cwd (vim.fn.getcwd)]
        (if (and (cfg [:load_repl_in_sbt_context]) (buildsbt-exist? cwd))
            (do
              (log.dbg "starting repl with sbt classpath")
              (with-sbt-classpath cwd
                #(start [:--extra-jars $1])))
            (start)))))

(fn M.stop []
  (log.dbg :scala.stdio.stop)
  (let [repl (state :repl)]
    (when repl
      (log.dbg "scala.stdio.stop: Destroying repl")
      (repl.destroy)
      (core.assoc (state) :repl nil))))

(fn M.unbatch [msgs]
  (log.dbg (.. :scala.stdio.unbatch (core.str msgs))))

(fn M.on-filetype []
  (mapping.buf :ScalaStart (cfg [:mapping :start]) #(M.start)
               {:desc "Start the REPL"})
  (mapping.buf :ScalaStop (cfg [:mapping :stop]) #(M.stop)
               {:desc "Stop the REPL"})
  (mapping.buf :ScalaReset (cfg [:mapping :reset]) #(reset)
               {:desc "Reset the REPL"}))

(fn repl-send-with-log-append [code]
  (log.dbg (.. "scala.stdio.repl-send-with-log-append:" (core.str code)))
  (repl-send code (fn [msg]
                    (log.dbg "(.. scala.stdio.repl-send-with-log-append callback:"
                             (core.str msg))
                    (log-append msg.out))))

(fn M.eval-str [opts] (repl-send-with-log-append opts.code))

(fn M.eval-file [opts]
  (log.dbg (.. "scala.stdio.eval-file opts='" (core.str opts) "'"))
  (repl-send (.. ":load " opts.file-path "\n")
             (fn [msg]
               (log.dbg (.. "MSG: " (core.str msg)))
               (log-append msg.out)
               (opts.on-result msg))))

(fn M.on-exit []
  (log.dbg :scala.stdio.on-exit)
  (M.stop))

; (with-sbt-classpath :/Users/brian/Development/scala-coding-challenge/

;   (fn [classpath] (vim.print classpath)))

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

; (vim.notify :HI)
; (get-sbt-classpath :/Users/brian/Development/scala-coding-challenge/)

M
