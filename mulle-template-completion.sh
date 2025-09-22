#!/bin/bash

# bash completion for mulle-template

_mulle_template_complete()
{
   _get_comp_words_by_ref cur prev words cword || return

   local global_options=("-h" "--help" "-f" "--force" "-D" "--source" "--version" "--list-flags" "--clean-env")
   local commands=("generate" "list" "commands" "csed" "csed-script" "fsed" "fsed-script" "environment" "hostname" "libexec-dir" "library-path" "uname" "version" "help" "contents-sed" "filename-sed")

   if (( cword == 1 )); then
      if [[ "$cur" == -* ]]; then
         COMPREPLY=($(compgen -W "${global_options[*]}" -- "$cur"))
      else
         COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
      fi
      return
   fi

   case "${words[1]}" in
      generate)
         local generate_options=("-h" "--help" "-p" "--permissions" "--no-permissions" "--callback" "--comment-start" "--comment-middle" "--comment-end" "--comment" "--csed" "--contents-sed" "--csed-script" "--fsed" "--filename-sed" "--fsed-script" "--file" "--header-file" "--footer-file" "--append" "--prepend" "--overwrite" "--with-template-dir" "--without-template-dir" "--boring-environment" "--no-boring-environment" "--date-environment" "--no-date-environment" "-fo" "--filename-opener" "-fc" "--filename-closer" "-o" "--opener" "-c" "--closer" "--sed-separator" "--sed-prefix" "--sed-suffix" "--sed-prefix-suffix-escape" "--embedded" "--version")
         if [[ "$prev" == "--source" ]] || [[ "$prev" == "--header-file" ]] || [[ "$prev" == "--footer-file" ]] || [[ "$prev" == "--file" ]]; then
            COMPREPLY=($(compgen -f -- "$cur"))
         elif [[ "$cur" == -* ]]; then
            COMPREPLY=($(compgen -W "${generate_options[*]}" -- "$cur"))
         else
            COMPREPLY=($(compgen -f -d -- "$cur"))
         fi
         ;;
      list)
         if [[ $cword -eq 2 ]]; then
            COMPREPLY=($(compgen -f -- "$cur"))
         fi
         ;;
      csed|csed-script|contents-sed)
         local csed_options=("-h" "--help" "-fo" "--filename-opener" "-fc" "--filename-closer" "--no-date-environment" "--boring-environment" "--no-boring-environment")
         if [[ "$cur" == -* ]]; then
            COMPREPLY=($(compgen -W "${csed_options[*]}" -- "$cur"))
         fi
         ;;
      fsed|fsed-script|filename-sed)
         local fsed_options=("-h" "--help" "-o" "--opener" "-c" "--closer")
         if [[ "$cur" == -* ]]; then
            COMPREPLY=($(compgen -W "${fsed_options[*]}" -- "$cur"))
         fi
         ;;
      help)
         COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
         ;;
      commands|environment|hostname|libexec-dir|library-path|uname|version)
         # no completion
         ;;
      *)
         # treat as generate (default case)
         local generate_options=("-h" "--help" "-p" "--permissions" "--no-permissions" "--callback" "--comment-start" "--comment-middle" "--comment-end" "--comment" "--csed" "--contents-sed" "--csed-script" "--fsed" "--filename-sed" "--fsed-script" "--file" "--header-file" "--footer-file" "--append" "--prepend" "--overwrite" "--with-template-dir" "--without-template-dir" "--boring-environment" "--no-boring-environment" "--date-environment" "--no-date-environment" "-fo" "--filename-opener" "-fc" "--filename-closer" "-o" "--opener" "-c" "--closer" "--sed-separator" "--sed-prefix" "--sed-suffix" "--sed-prefix-suffix-escape" "--embedded" "--version")
         if [[ "$prev" == "--source" ]] || [[ "$prev" == "--header-file" ]] || [[ "$prev" == "--footer-file" ]] || [[ "$prev" == "--file" ]]; then
            COMPREPLY=($(compgen -f -- "$cur"))
         elif [[ "$cur" == -* ]]; then
            COMPREPLY=($(compgen -W "${generate_options[*]}" -- "$cur"))
         else
            COMPREPLY=($(compgen -f -d -- "$cur"))
         fi
         ;;
   esac
}

complete -F _mulle_template_complete mulle-template
