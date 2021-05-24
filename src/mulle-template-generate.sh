#! /usr/bin/env bash
#
#   Copyright (c) 2018 Nat! - Mulle kybernetiK
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#
#   Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
#   Neither the name of Mulle kybernetiK nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#   POSSIBILITY OF SUCH DAMAGE.
#
MULLE_TEMPLATE_GENEREATE_SH="included"

#
# TEMPLATE
#

template_generate_csed_usage()
{
   [ "$#" -ne 0 ] && log_error "$*"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} csed [options]

   Emit sed statement for content expansion. All the following options
   can also be given to the \`generate\` command.

Options:
   -fo <string>           : specify key opener string for filenames ("")
   -fc <string>           : specify key closer string for filenames ("")
   --no-date-environment  : don't create substitutions for TIME, YEAR etc.
   --boring-environment   : don't filter out environment keys considered boring

EOF
   exit 1
}


template_generate_fsed_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} csed [options]

   Emit sed statement for filename expansion. All the following options
   can also be given to the \`generate\` command.

Options:
   -o <string>            : specify key opener string (\"<|\")
   -c <string>            : specify key closer string (\"|>\")
EOF
   exit 1
}


template_print_write_usage()
{
   local show_all="${1:-NO}"

   SHOWN_OPTIONS="\
   -p                     : copy permissions
   --header-file <header> : specify file to replace <|HEADER|> with
   --footer-file <footer> : specify file to replace <|FOOTER|> with"

   HIDDEN_OPTIONS="\
   --file <file>          : only act on this file, if copying directories
   -o <string>            : specify key opener string (\"<|\")
   -c <string>            : specify key closer string (\"|>\")
   -fo <string>           : specify key opener string for filenames ("")
   -fc <string>           : specify key closer string for filenames ("")
   -csed <seds>           : sed expressions to use on template contents
   -fsed <seds>           : sed expressions to use on template filenames
   --no-date-environment  : don't create substitutions for TIME, YEAR etc.
   --boring-environment   : don't filter out environment keys considered boring"

   (
      printf "%s\n" "${SHOWN_OPTIONS}"

      if [ "${show_all}" != 'NO' ]
      then
         printf "%s\n" "${HIDDEN_OPTIONS}"
      fi
   ) | LC_ALL=C sort
}


template_generate_write_usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} generate [options] <file|dir> [output]

   Copy a template \`dir\` or a template \`file\` to \`output\`, which can also
   be a file or a directory. Keys in the template are expanded while copying.
   You can use '-' for output, to print without generating files.

Options:
EOF
   template_print_write_usage "${MULLE_FLAG_LOG_VERBOSE}" >&2

   cat <<EOF >&2
      (use ${MULLE_USAGE_NAME} -v generate help to show more options)
EOF

   exit 1
}


r_append_sed_default_var_expansion()
{
   local cmdline="$1"
   local o="$2"
   local c="$3"
   local key="$4"
   local value="$5"

   [ -z "${c}" ] && internal_fail "can't have no closer"

   r_escaped_sed_replacement "${value}"

   # \(<|[^:|]*\)\(:-[^|]\)\{0,1\}|>
   # MEMO: the \{0,1\} makes the preceeding capture optional

   r_concat "${cmdline}" "-e 's/${o}${key}\\(:-[^${c:0:1}]*\\)\\{0,1\\}${c}/${RVAL}/g'"
}



r_append_sed_var_expansion()
{
   local cmdline="$1"
   local o="$2"
   local c="$3"
   local key="$4"
   local value="$5"

   r_escaped_sed_replacement "${value}"

   r_concat "${cmdline}" "-e 's/${o}${key}${c}/${RVAL}/g'"
}


# expand key:-default to default
r_append_sed_default_expansion()
{
   local cmdline="$1"
   local o="$2"
   local c="$3"

   r_concat "${cmdline}" "-e 's/${o}[^${c:0:1}]*:-\\([^${c:0:1}]*\\)${c}/\1/g'"
}


r_generated_seds()
{
   local o="$1"
   local c="$2"

   local nowdate
   local nowtime
   local nowyear

   nowdate="`date "+%d.%m.%Y"`"
   nowtime="`date "+%H:%M:%S"`"
   nowyear="`date "+%Y"`"

   r_append_sed_var_expansion ""        "${o}" "${c}" 'DATE' "${nowdate}"
   r_append_sed_var_expansion "${RVAL}" "${o}" "${c}" 'TIME' "${nowtime}"
   r_append_sed_var_expansion "${RVAL}" "${o}" "${c}" 'YEAR' "${nowyear}"
}

#
# We want the keys sorted so longest keys come first for matches. This
# is only important for filename expansion, where we don't have <||> guards.
# With filenames ONE_NAME should be matched after ONE_NAME_NO_EXT
#
get_environment_keys()
{
   env \
      | sed -e 's/^\([^=]*\)=.*/\1/' \
      | LC_ALL=C sort
}


print_csv_pascal_strings()
{
   (
      IFS=$'\n'; set -f
      while read -r line
      do
         printf "%d;%s\\n" "${#line}" "${line}"
      done
   )
}


print_csv_pascal_keys_sorted_by_reverse_length()
{
   sort -t';' -k 1,1gr -k 2,2 | sed 's/^[^;]*;//'
}


get_variable_keys()
{
   get_environment_keys \
      | print_csv_pascal_strings \
      | print_csv_pascal_keys_sorted_by_reverse_length
}


template_is_filekey()
{
   case "$1" in
      MULLE*_LIBEXEC_DIR)
         return 1
      ;;

      *DIRECTORY*|*FILENAME*|*EXTENSION*|*_NAME|*_IDENTIFIER|*_FILE|*_DIR|*_EXT)
         return 0
      ;;
   esac

   return 1
}


template_is_interesting_key()
{
   case "$1" in
      # bash keys
      SHLVL|_|PWD)
         return 1
      ;;

      # unix keys, usually boring
      *_HOME|*_PATH|PATH|*_COLORS|SSH*|LC_*|XDG_*|TERM|DISPLAY|OLDPWD|GPG_*|GTK_*|GJS_*|*SESSION*|LESS*)
         return 1
      ;;

      # mulle-env stuff
      KITCHEN_DIR|ADDICTION_DIR|DEPENDENCY_DIR|MULLE_OLDPATH|MULLE_USER_PWD)
         return 1
      ;;

      # mulle-sde stuff
      MULLE_SDE_*|MULLE_FETCH_*|MULLE_SOURCETREE_*|MULLE*_LIBEXEC_DIR)
         return 1
      ;;

      # some linux specific
      GNOME_*|DBUS_*|GTX_*)
         return 1
      ;;
   esac

   return 0
}


#
# make <||> substitutions for all environment variables
#
r_shell_var_sed()
{
   local o="$1"
   local c="$2"
   local pattern_function="$3"
   local mode="$4"

   log_entry "r_shell_var_sed" "$@"

   local cmdline

   local variablekeys
   local key
   local value
   local cmdline
   local replacement

   variablekeys="`get_variable_keys`"

   IFS=$'\n'; set -f
   for key in ${variablekeys}
   do
      IFS=${DEFAULT_IFS}; set +f

      if [ ! -z "${pattern_function}" ] && ! ${pattern_function} "${key}"
      then
         continue
      fi

      #
      # if undefined skip, otherwise we like to use empty strings
      #
      if [ -z ${key+x} ]
      then
         continue
      fi

      if [ "${4}" = "default" ]
      then
         r_append_sed_default_var_expansion "${cmdline}" "${o}" "${c}" "${key}" "${!key}"
      else
         r_append_sed_var_expansion "${cmdline}" "${o}" "${c}" "${key}" "${!key}"
      fi

      cmdline="${RVAL}"
   done
   IFS=${DEFAULT_IFS}; set +f

   RVAL="${cmdline}"
}


r_template_filename_replacement_seds()
{
   log_entry "r_template_filename_replacement_seds" "$@"

   local opener="$1"
   local closer="$2"

   r_escaped_sed_pattern "${opener}"
   opener="${RVAL}"
   r_escaped_sed_pattern "${closer}"
   closer="${RVAL}"

   r_shell_var_sed "${opener}" \
                   "${closer}" \
                   template_is_filekey

   log_debug "${RVAL}"
}


r_template_contents_replacement_seds()
{
   log_entry "r_template_contents_replacement_seds" "$@"

   local opener="$1"
   local closer="$2"
   local filter="$3"
   local dateenv="$4"

   r_escaped_sed_pattern "${opener}"
   opener="${RVAL}"
   r_escaped_sed_pattern "${closer}"
   closer="${RVAL}"

   local cmdline
   local filter

   r_shell_var_sed "${opener}" "${closer}" "${filter}" "default"
   cmdline="${RVAL}"

   if [ "${dateenv}" != 'NO' ]
   then
      r_generated_seds "${opener}" "${closer}"
      r_concat "${cmdline}" "${RVAL}"
      cmdline="${RVAL}"
   fi

   #
   # finally append a set that cleans up all values that haven't been
   # expanded of the form <|key:-default|>
   #
   r_append_sed_default_expansion "${cmdline}" "${opener}" "${closer}"

   log_debug "${RVAL}"
}


_cat_template_file()
{
   log_entry "_cat_template_file" "$@"

   local line

   IFS=$'\n'
   while read -r line
   do
      case "${line}" in
         "${OPTION_OPENER}HEADER${OPTION_CLOSER}")
            if [ ! -z "${TEMPLATE_HEADER_FILE}" ]
            then
               cat "${TEMPLATE_HEADER_FILE}"
            fi
            continue # silently remove missing <|HEADER|> from template
         ;;

         "${OPTION_OPENER}FOOTER${OPTION_CLOSER}")
            if [ ! -z "${TEMPLATE_FOOTER_FILE}" ]
            then
               cat "${TEMPLATE_FOOTER_FILE}"
            fi
            continue # silently remove missing <|FOOTER|> from template
         ;;
      esac
      printf "%s\n" "${line}"
   done

   IFS="${DEFAULT_IFS}"
}


cat_template_file()
{
   log_entry "cat_template_file" "$@"

   local templatefile="$1"

   if [ "${templatefile}" = "-" ]
   then
      _cat_template_file
      return $?
   fi

   local char

   if ! char="`tail -c 1 "${templatefile}" 2> /dev/null`"
   then
      fail "\"${templatefile}\" is missing"
   fi

   case "${char}" in
      "")
      ;;

      $'\n'|$'\r')
      ;;

      *)
         fail "Invalid templatefile \"${templatefile}\" last char \"$char\" is not a linefeed"
      ;;
   esac

   _cat_template_file < "${templatefile}"
}


r_template_expand_filename()
{
   log_entry "r_template_expand_filename" "..." "$2"

   local filename_sed="$1"
   local filename="$2"

   if [ -z "${filename_sed}" ]
   then
      RVAL="${filename}"
      return 0
   fi

   if ! RVAL="`LC_ALL=C eval_rexekutor "'${SED:-sed}'" \
                                       "${filename_sed}" \
                                        <<< "${filename}" `"
   then
      fail "Given filename sed expression is broken: ${filename_sed}"
   fi

   if [ "${RVAL}" != "${filename}" ]
   then
      log_fluff "Expanded filename \"${filename}\" to \"${RVAL}\""
   fi
}


#
# We know here that "templatefile" is a file and we know "outputfile" is a
# file. And the filename expansion is through.
#
copy_and_expand_template()
{
   log_entry "copy_and_expand_template" "..." "$2" "$3"

   local template_sed="$1"
   local templatefile="$2"
   local outputfile="$3"

   [ -z "${templatefile}" ] && internal_fail "templatefile is empty"
   [ -z "${outputfile}" ]   && internal_fail "outputfile is empty"

   if [ "${outputfile}" != '-' ]
   then
      if [ "${templatefile}" -ef "${outputfile}" ]
      then
         log_error "Template \"${templatefile}\" would clobber itself, ignored"
         return 1
      fi

      if [ "${OPTION_OVERWRITE}" = 'NO' ] && [ -f "${outputfile}" ]
      then
         log_fluff "\"${templatefile}\" !! \"${outputfile}\" (exists)"
         return 4
      fi

      #
      # Directory
      #

      r_mkdir_parent_if_missing "${outputfile}"

      #
      # Permissions 1
      #
      if [ "${OPTION_PERMISSIONS}" = 'YES' ]
      then
         if [ -f "${outputfile}" ]
         then
            exekutor chmod ug+w "${outputfile}" || exit 1
         fi
      fi
   fi

   #
   # Generation
   #
   log_debug "Generating text from template \"${templatefile}\""

   local text

   text="`cat_template_file "${templatefile}"`" || exit 1
   if [ ! -z "${template_sed}" ]
   then
      if ! text="`LC_ALL=C eval_rexekutor "'${SED:-sed}'" \
                                          "${template_sed}" \
                                          <<< "${text}" `"
      then
         fail "Given template sed expression is broken: ${template_sed}"
      fi
   fi

   if [ "${outputfile}" = '-' ]
   then
      rexekutor printf "%s\n" "${text}"
   else
      log_debug "${C_RESET_BOLD}\"${templatefile}\" -> \"${outputfile}\""
      log_verbose "Created ${C_RESET_BOLD}${outputfile#${MULLE_USER_PWD}/}"
      redirect_exekutor "${outputfile}" printf "%s\n" "${text}" \
         || fail "failed to write to \"${outputfile}\" (${PWD#${MULLE_USER_PWD}/})"

      #
      # Permissions 2
      #
      if [ "${OPTION_PERMISSIONS}" = 'YES' ]
      then
         local permissions

         permissions="`lso "${templatefile}"`"
         exekutor chmod "${permissions}" "${outputfile}"
      fi
   fi
}


do_template_directory()
{
   log_entry "do_template_directory" "..." "..." "$3" "$4" "$5"

   local filename_sed="$1"
   local template_sed="$2"
   local templatedir="$3"
   local dst="$4"
   local onlyfile="$5"

   log_verbose "Installing template directory \"${templatedir}\""

   local filename
   local src_filename
   local dst_filename
   local expanded_filename
   local rval

   if [ "${OPTION_WITH_TEMPLATE_DIR}" = 'YES' ]
   then
      r_basename "${templatedir}"
      r_filepath_concat "${dst}" "${RVAL}"
      dst="${RVAL}"
   else
      dst="${dst:-.}"
   fi

   # too funny, IFS="" is wrong IFS="\n" is also wrong. Only hardcoded LF works

   IFS=$'\n'; set -f
   for filename in `( cd "${templatedir}" ; find -L . -type f -print )`
   do
      IFS="${DEFAULT_IFS}"; set +f

      filename="${filename#./}"

      # suppress OS X uglies
      case "${filename}" in
         *.DS_Store*)
            log_debug "Suppressed ugly \"${filename}\""
            IFS=$'\n'
            continue
         ;;
      esac

      r_filepath_concat "${dst}" "${filename}"
      dst_filename="${RVAL}"

      r_template_expand_filename "${filename_sed}" "${dst_filename}"
      expanded_filename="${RVAL}"

      #
      # possibly filter out files that don't match
      #
      if [ ! -z "${onlyfile}" ]
      then
         if [ "${expanded_filename}" != "${onlyfile}" -a "${dst_filename}" != "${onlyfile}" ]
         then
            log_fluff "Suppressed non matching \"${expanded_filename}\""
            continue
         fi
      fi

      r_filepath_concat "${templatedir}" "${filename}"
      src_filename="${RVAL}"

      # assume we can for as much as we want
      copy_and_expand_template "${template_sed}" \
                               "${src_filename}" \
                               "${expanded_filename}"
      if [ $? -eq 1 ]
      then
         return 1
      fi

      IFS=$'\n'
   done
   IFS="${DEFAULT_IFS}"; set +f
}


do_template_file()
{
   log_entry "do_template_file" "..." "..." "$3" "$4" "$5"

   local filename_sed="$1"
   local template_sed="$2"
   local templatefile="$3"
   local dst="$4"
   local onlyfile="$5"

   [ ! -z "${onlyfile}" ] && log_warning "--file is only used with template directories"

   log_verbose "Installing template file \"${templatefile}\""

   #
   # dst can be a directory it can be a filename or it can be empty, which
   # make this empty
   #
   local expanded_filename
   local directory

   directory="${dst:-`pwd`}"  # PWD could be gone or ?

   if [ -d "${directory}" ]
   then
      r_basename "${templatefile}"
      r_filepath_concat "${directory}" "${RVAL}"
      r_template_expand_filename "${filename_sed}" "${RVAL}"
      expanded_filename="${RVAL}"
   else
      expanded_filename="${directory}"
   fi

   if [ "${expanded_filename}" = "${templatefile}" ]
   then
      log_info "Template would clobber itself, appending .output to file"
      expanded_filename="${expanded_filename}.output"
   fi

   # assume we can for as much as we want
   copy_and_expand_template "${template_sed}" \
                            "${templatefile}" \
                            "${expanded_filename}"
   if [ $? -eq 1 ]
   then
      return 1
   fi
}


default_template_setup()
{
   log_entry "default_template_setup" "..." "..." "$3" "$4" "$5"

   local filename_sed="$1"
   local template_sed="$2"
   local src="$3"
   local dst="$4"
   local onlyfile="$5"

   [ $# -lt 3 -o $# -gt 5 ] && template_generate_write_usage "Wrong number of arguments"
   [ -z "${src}" ] && template_generate_write_usage "No template specified"

   if [ "${src}" != "-" ]
   then
      if [ -d "${src}" ]
      then
         do_template_directory "${filename_sed}" "${template_sed}" "${src}" "${dst}" "${onlyfile}"
         return $?
      fi
   fi

   do_template_file "${filename_sed}" "${template_sed}" "${src}" "${dst}"  "${onlyfile}"
   if [ $? -eq 1 ]
   then
      return 1
   fi
   return 0
}


template_generate_main()
{
   log_entry "template_generate_main" "$@"

   local OPTION_EMBEDDED='NO'

   local cmd

   cmd="$1"
   shift

   [ -z "${cmd}" ] && internal_fail "cmd is empty"

   # must be first after command
   case "$1" in
      --embedded)
         OPTION_EMBEDDED='YES'
         shift
      ;;

      *)
         # don't keep them around
         FILENAME_SED=""
         CONTENTS_SED=""
      ;;
   esac


   local OPTION_FILE
   local OPTION_PERMISSIONS='NO'
   local OPTION_OPENER="<|"
   local OPTION_CLOSER="|>"
   local OPTION_FILENAME_OPENER=""
   local OPTION_FILENAME_CLOSER=""
   local OPTION_OVERWRITE="${MULLE_FLAG_MAGNUM_FORCE}"
   local OPTION_WITH_TEMPLATE_DIR='YES'
   local OPTION_BORING_ENVIRONMENT='NO'
   local OPTION_DATE_ENVIRONMENT='YES'

   local template_callback

   template_callback="default_template_setup"

   while [ $# -ne 0 ]
   do

      if [ "${OPTION_EMBEDDED}" = 'NO' ]
      then
         if options_technical_flags "$1"
         then
            shift
            continue
         fi
      fi

      case "$1" in
         -h*|--help|help)
            template_generate_write_usage
         ;;

         --callback)
            [ $# -eq 1 ] && template_generate_write_usage "Missing argument to \"$1\""
            shift

            template_callback="$1"
         ;;

         --csed|--contents-sed)
            shift
            [ $# -eq 0 ] && template_generate_write_usage

            CONTENTS_SED="$1"
         ;;

         --overwrite)
            OPTION_OVERWRITE='YES'
         ;;

         --no-overwrite)
            OPTION_OVERWRITE='NO'
         ;;

         --with-template-dir)
            OPTION_WITH_TEMPLATE_DIR='YES'
         ;;

         --without-template-dir)
            OPTION_WITH_TEMPLATE_DIR='NO'
         ;;

         --no-overwrite)
            OPTION_OVERWRITE='NO'
         ;;

         -p|--permissions)
            OPTION_PERMISSIONS='YES'
         ;;

         --no-permissions)
            OPTION_PERMISSIONS='NO'
         ;;

         --boring-environment)
            OPTION_BORING_ENVIRONMENT='YES'
         ;;

         --no-boring-environment)
            OPTION_BORING_ENVIRONMENT='NO'
         ;;

         --date-environment)
            OPTION_DATE_ENVIRONMENT='YES'
         ;;

         --no-date-environment)
            OPTION_DATE_ENVIRONMENT='NO'
         ;;

         -fo|--filename-opener)
            [ $# -eq 1 ] && template_generate_write_usage "Missing argument to \"$1\""
            shift

            OPTION_FILENAME_OPENER="$1"
         ;;

         -fc|--filename-closer)
            [ $# -eq 1 ] && template_generate_write_usage "Missing argument to \"$1\""
            shift

            OPTION_FILENAME_CLOSER="$1"
         ;;

         -o|--opener)
            [ $# -eq 1 ] && template_generate_write_usage "Missing argument to \"$1\""
            shift

            OPTION_OPENER="$1"
         ;;

         -c|--closer)
            [ $# -eq 1 ] && template_generate_write_usage "Missing argument to \"$1\""
            shift

            OPTION_CLOSER="$1"
         ;;

         --file)
            [ $# -eq 1 ] && template_generate_write_usage "Missing argument to \"$1\""
            shift

            OPTION_FILE="$1"
         ;;

         --fsed|--filename-sed)
            shift
            [ $# -eq 0 ] && template_generate_write_usage

            FILENAME_SED="$1"
         ;;

         --header-file)
            shift
            [ $# -eq 0 ] && template_generate_write_usage

            TEMPLATE_HEADER_FILE="$1"
         ;;

         --footer-file)
            shift
            [ $# -eq 0 ] && template_generate_write_usage

            TEMPLATE_FOOTER_FILE="$1"
         ;;

         --version)
            printf "%s\n" "${VERSION}"
            exit 0
         ;;

         -)
            break;
         ;;

         -*)
            log_error "unknown options \"$1\""
            template_generate_write_usage
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   if [ "${OPTION_EMBEDDED}" = 'NO' ]
   then
      options_setup_trace "${MULLE_TRACE}"
   fi

   local contents_filter

   if [ "${OPTION_BORING_ENVIRONMENT}" = 'NO' ]
   then
      contents_filter=template_is_interesting_key
   fi

   case "${cmd}" in
      csed)
         [ $# -eq 0 ] || template_generate_csed_usage "Superflous arguments $*"

         r_template_contents_replacement_seds "${OPTION_OPENER}" \
                                              "${OPTION_CLOSER}" \
                                              "${contents_filter}" \
                                              "${OPTION_DATE_ENVIRONMENT}"
         printf "%s\n" "${RVAL}"
      ;;

      fsed)
         [ $# -eq 0 ] || template_generate_fsed_usage "Superflous arguments $*"

         r_template_filename_replacement_seds "${OPTION_FILENAME_OPENER}" \
                                              "${OPTION_FILENAME_CLOSER}"
         printf "%s\n" "${RVAL}"
      ;;

      write)
         if [ -z "${FILENAME_SED}" ]
         then
            r_template_filename_replacement_seds "${OPTION_FILENAME_OPENER}" \
                                                 "${OPTION_FILENAME_CLOSER}"
            FILENAME_SED="${RVAL}"
         fi
         if [ -z "${CONTENTS_SED}" ]
         then
            r_template_contents_replacement_seds "${OPTION_OPENER}" \
                                                 "${OPTION_CLOSER}" \
                                                 "${contents_filter}" \
                                                "${OPTION_DATE_ENVIRONMENT}"
            CONTENTS_SED="${RVAL}"
         fi

         "${template_callback}" "${FILENAME_SED}" \
                                "${CONTENTS_SED}" \
                                "$@" \
                                "${OPTION_FILE}"
     ;;

      *)
         internal_fail "Unknown command \"$1\""
      ;;
   esac
}



sde_template_main()
{
   #
   # hackish,  undocumented just for development
   #
   template_generate_main "write" --template-dir /tmp --callback expand_template_variables "$@"
}
