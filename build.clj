(ns build
  (:require [babashka.process :refer [process]]
            [clojure.edn :as edn]
            [clojure.string :as str]))

(defn aliases [deps-edn-file]
  (let [deps-edn (edn/read-string (slurp deps-edn-file))
        aliases (get-in deps-edn [:aliases :nextjournal/clerk :nextjournal.clerk/aliases])]
    (str/join (concat aliases [:nextjournal/clerk]))))

@(process ["clojure"
           "-J-Dclojure.main.report=stdout"
           "-Srepro"
           (str "-X" (aliases "deps.edn"))
           ":browse?" (pr-str false)
           ":dashboard" (pr-str true)]
          {:inherit true})
