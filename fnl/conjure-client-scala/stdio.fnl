(local {: autoload : define} (require :conjure.nfnl.module))

(local M (define :conjure.client.scala.stdio))
(local config (autoload :conjure.config))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local fs (autoload :conjure.nfnl.fs))
(local stdio (autoload :conjure.remote.stdio))
(local mapping (autoload :conjure.mapping))
; (local ts (autoload :conjure.tree-sitter))
(local log (autoload :conjure.log))
(local client (autoload :conjure.client))

(set M.buf-suffix :.scala)
(set M.comment-prefix "// ")
(set M.context-pattern "package (.*)$")

(config.merge {:client {:scala {:stdio {:command :scala-cli
                                        :prompt_pattern :scala>
                                        :load_repl_in_sbt_context true
                                        :arguments []}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge {:client {:scala {:stdio {:mapping {:start :cs
                                                    :stop :cS
                                                    :reset :cr
                                                    :interrupt :ei}}}}}))

(local cfg (config.get-in-fn [:client :scala :stdio]))
(local state (client.new-state #{:repl nil}))

(fn prep-code [code] (.. code "\n"))

(fn log-append [msg]
  (fn starts-with-comment-prefix? [str]
    (string.match str (.. "^" M.comment-prefix)))

  (fn with-comment-prefix [str]
    (if (starts-with-comment-prefix? str) str (.. M.comment-prefix str)))

  (when msg
    (let [wrapped-msg (if (core.table? msg)
                          (core.map with-comment-prefix msg)
                          [(with-comment-prefix msg)])]
      (log.append wrapped-msg))))

(fn with-repl [cb]
  (let [repl (state :repl)]
    (if repl
        (cb repl)
        (log-append "REPL is not connected."))))

(fn repl-send [msg cb opts]
  (log.dbg (.. "scala.stdio.repl-send: opts='" (core.str opts) "'"))
  (log.dbg (.. "scala.stdio.repl-send: msg='" (core.str msg) "'"))
  (with-repl (fn [repl]
               (repl.send msg cb opts))))

(fn split-on-newline [string]
  (str.split string "\n"))

(fn repl-send-with-log-append [code]
  (log.dbg (.. "scala.stdio.repl-send-with-log-append:" (core.str code)))
  (repl-send (prep-code code)
             (fn [msgs]
               (log.dbg (.. "scala.stdio.repl-send-with-log-append callback:"
                            (core.str msgs)))
               (log-append (M.format-msg msgs)))))

(fn reset []
  (repl-send-with-log-append ":reset"))

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
    (log.dbg (.. "scala.stdio.start.start: args='" (core.str args) "'"))

    (fn on-exit [code signal]
      (when (and (= :number (type code)) (> code 0))
        (log-append (.. M.comment-prefix "process exited with code "
                        (core.str code))))
      (when (and (= :number (type signal)) (> signal 0))
        (log-append (.. M.comment-prefix "process exited with signal "
                        (core.str signal))))
      (with-repl (fn [repl]
                   (repl.destroy)))
      (core.assoc (state) :repl nil))

    (fn on-success []
      (log.dbg :scala.stdio.start.on-success))

    (fn on-error [err]
      (log.dbg (.. "scala.stdio.start.on-error: " (core.str err)))
      (log-append err))

    (fn on-stray-output [msg]
      (log.dbg (.. "scala.stdio.start on-stray-output='" msg.out "'"))
      (log-append (M.format-msg msg)))

    (client.schedule #(core.assoc (state) :repl
                                  (do
                                    (log.dbg "scala.stdio.start: Starting REPL")
                                    (stdio.start {:prompt-pattern (cfg [:prompt_pattern])
                                                  :cmd (let [full-command (or args
                                                                              [])]
                                                         (table.insert full-command
                                                                       :-color)
                                                         (table.insert full-command
                                                                       :never)
                                                         (table.insert full-command
                                                                       1
                                                                       (cfg [:command]))
                                                         full-command)
                                                  : on-success
                                                  : on-error
                                                  : on-exit
                                                  : on-stray-output})))))

  (if (state :repl)
      (log-append "REPL is already connected")
      (let [cwd (vim.fn.getcwd)]
        (if (and (cfg [:load_repl_in_sbt_context]) (buildsbt-exist? cwd))
            (do
              (log.dbg "scala.stdio.start: starting repl with sbt classpath")
              (with-sbt-classpath cwd
                #(start [:--extra-jars $1])))
            (start)))))

(fn M.stop []
  (log.dbg :scala.stdio.stop)
  (log-append "Stopping the REPL...")
  (with-repl (fn [repl]
               (repl-send-with-log-append ":exit")
               (log.dbg "scala.stdio.stop: Destroying repl")
               (repl.destroy)
               (core.assoc (state) :repl nil))))

(fn M.on-filetype []
  (mapping.buf :ScalaStart (cfg [:mapping :start]) #(M.start)
               {:desc "Start the REPL"})
  (mapping.buf :ScalaStop (cfg [:mapping :stop]) #(M.stop)
               {:desc "Stop the REPL"})
  (mapping.buf :ScalaReset (cfg [:mapping :reset]) #(reset)
               {:desc "Reset the REPL"})
  (mapping.buf :ScalaInterrupt (cfg [:mapping :interrupt]) #(M.interrupt)
               {:desc "Interrupt the REPL"}))

(fn M.eval-str [opts] (repl-send-with-log-append opts.code))

(fn M.eval-file [opts]
  (log.dbg (.. "scala.stdio.eval-file opts='" (core.str opts) "'"))
  (repl-send (prep-code (.. ":load " opts.file-path))
             #(log-append (M.format-msg $))))

(fn M.on-exit []
  (log.dbg :scala.stdio.on-exit)
  (M.stop))

(fn M.format-msg [msg]
  (core.remove #(= $ " ") (-> msg
                              (core.get :out)
                              (split-on-newline))))

(fn M.form-node? [node]
  (log.dbg "--------------------")
  (log.dbg (.. "scala.stdio.form-node?: node:type = " (core.str (node:type))))
  (log.dbg (.. "scala.stdio.form-node?: node:parent = "
               (core.str (node:parent))))
  (if (= :import_declaration (node:type)) true
      (= :function_definition (node:type)) true
      (= :trait_definition (node:type)) true
      (= :object_definition (node:type)) true
      (= :val_definition (node:type)) true
      (= :call_expression (node:type)) true
      false))

(fn M.interrupt []
  (with-repl (fn [repl]
               (log-append [(.. M.comment-prefix "Sending interrupt signal.")]
                           {:break? true})
               (repl.send-signal :sigint))))

M
