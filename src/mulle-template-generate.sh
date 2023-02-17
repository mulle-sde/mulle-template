# shellcheck shell=bash
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
MULLE_TEMPLATE_GENEREATE_SH='included'

#
# TEMPLATE
#

template::generate::csed_usage()
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


template::generate::fsed_usage()
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


template::generate::print_usage()
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


template::generate::usage()
{
   [ "$#" -ne 0 ] && log_error "$1"

   cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} [flags] generate [options] <file|dir> [output]

   Copy a template \`dir\` or a template \`file\` to \`output\`, which can also
   be a file or a directory. Keys in the template are expanded while copying.
   You can use '-' for output, to print without generating files.
   This command will not overwrite existing files. To force overwrites, use
   the '-f' flag.

Example:
   mulle-template -f -DCLUB="VfL Bochum 1848" generate ./dox /tmp/test

Options:
EOF
   template::generate::print_usage "${MULLE_FLAG_LOG_VERBOSE}" >&2

   cat <<EOF >&2
      (use ${MULLE_USAGE_NAME} -v generate help to show more options)
EOF

   exit 1
}


template::generate::r_append_sed_default_var_expansion()
{
   local cmdline="$1"
   local o="$2"
   local c="$3"
   local sep="$4"
   local prefix="$5"
   local suffix="$6"
   local key="$7"
   local value="$8"

   [ -z "${c}" ] && _internal_fail "can't have no closer"

   r_escaped_sed_replacement "${value}"

   # \(<|[^:|]*\)\(:-[^|]\)\{0,1\}|>
   # MEMO: the \{0,1\} makes the preceeding capture optional

   r_concat "${cmdline}" "${prefix}s/${o}${key}\\(:-[^${c:0:1}]*\\)\\{0,1\\}${c}/${RVAL}/g${suffix}" "${sep}"
}



template::generate::r_append_sed_var_expansion()
{
   local cmdline="$1"
   local o="$2"
   local c="$3"
   local sep="$4"
   local prefix="$5"
   local suffix="$6"
   local key="$7"
   local value="$8"

   r_escaped_sed_replacement "${value}"

   r_concat "${cmdline}" "${prefix}s/${o}${key}${c}/${RVAL}/g${suffix}" "${sep}"
}


# expand key:-default to default
template::generate::r_append_sed_default_expansion()
{
   local cmdline="$1"
   local o="$2"
   local c="$3"
   local sep="$4"
   local prefix="$5"
   local suffix="$6"

   r_concat "${cmdline}" "${prefix}s/${o}[^${c:0:1}]*:-\\([^${c:0:1}]*\\)${c}/\1/g${suffix}" "${sep}"
}


template::generate::r_generated_seds()
{
   local o="$1"
   local c="$2"
   local sep="$3"
   local prefix="$4"
   local suffix="$5"

   local nowdate
   local nowtime
   local nowyear

   nowdate="`date "+%d.%m.%Y"`"
   nowtime="`date "+%H:%M:%S"`"
   nowyear="`date "+%Y"`"

   template::generate::r_append_sed_var_expansion ""        "${o}" "${c}" "${sep}" "${prefix}" "${suffix}" 'DATE' "${nowdate}"
   template::generate::r_append_sed_var_expansion "${RVAL}" "${o}" "${c}" "${sep}" "${prefix}" "${suffix}" 'TIME' "${nowtime}"
   template::generate::r_append_sed_var_expansion "${RVAL}" "${o}" "${c}" "${sep}" "${prefix}" "${suffix}" 'YEAR' "${nowyear}"
}

#
# We want the keys sorted so longest keys come first for matches. This
# is only important for filename expansion, where we don't have <||> guards.
# With filenames ONE_NAME should be matched after ONE_NAME_NO_EXT
#
template::generate::get_environment_keys()
{
   env \
      | sed -e 's/^\([^=]*\)=.*/\1/' \
      | LC_ALL=C sort
}


template::generate::print_csv_pascal_strings()
{
   (
      IFS=$'\n'; shell_disable_glob
      while read -r line
      do
         printf "%d;%s\\n" "${#line}" "${line}"
      done
   )
}


template::generate::print_csv_pascal_keys_sorted_by_reverse_length()
{
   case "${MULLE_UNAME}" in
      sunos)
         LC_ALL=C sort -t';' -k 1,1 -k 2,2 | sed 's/^[^;]*;//' | sort -n -r
      ;;

      *)
         LC_ALL=C sort -t';' -k 1,1gr -k 2,2 | sed 's/^[^;]*;//'
      ;;
   esac
}


template::generate::get_variable_keys()
{
   template::generate::get_environment_keys \
      | template::generate::print_csv_pascal_strings \
      | template::generate::print_csv_pascal_keys_sorted_by_reverse_length
}


template::generate::is_filekey()
{
   case "$1" in
      MULLE*_LIBEXEC_DIR|MULLE_SDE_EXTENSION_PATH)
         return 1
      ;;

      *DIRECTORY*|*FILENAME*|*EXTENSION*|*_NAME|*_IDENTIFIER|*_FILE|*_DIR|*_EXT)
         return 0
      ;;
   esac

   return 1
}


template::generate::is_interesting_key()
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

      # windows specific
   esac

   return 0
}


#
# make <||> substitutions for all environment variables
#
template::generate::r_shell_var_sed()
{
   local o="$1"
   local c="$2"
   local sep="$3"
   local prefix="$4"
   local suffix="$5"
   local pattern_function="$6"
   local mode="$7"

   log_entry "template::generate::r_shell_var_sed" "$@"

   local cmdline

   local variablekeys
   local key
   local value
   local replacement

   variablekeys="`template::generate::get_variable_keys`"

   .foreachline key in ${variablekeys}
   .do
      log_debug "${key}"
      
      if [ ! -z "${pattern_function}" ] && ! ${pattern_function} "${key}"
      then
         .continue
      fi

      #
      # if undefined skip, otherwise we like to use empty strings
      #
      if [ -z ${key+x} ]
      then
         .continue
      fi

      # mingw has some weird keys we can't deal with
      case "${key}" in
         *\!*|*\(*\)*)
            .continue
         ;;
      esac

      r_shell_indirect_expand "${key}"
      value="${RVAL}"

      if [ "${mode}" = "default" ]
      then
         template::generate::r_append_sed_default_var_expansion "${cmdline}" "${o}" "${c}" "${sep}" "${prefix}" "${suffix}" "${key}" "${value}"
      else
         template::generate::r_append_sed_var_expansion "${cmdline}" "${o}" "${c}" "${sep}" "${prefix}" "${suffix}" "${key}" "${value}"
      fi

      cmdline="${RVAL}"
   .done

   RVAL="${cmdline}"
}


template::generate::r_filename_replacement_seds()
{
   log_entry "template::generate::r_filename_replacement_seds" "$@"

   local opener="$1"
   local closer="$2"
   local sep="$3"
   local prefix="$4"
   local suffix="$5"

   r_escaped_sed_pattern "${opener}"
   opener="${RVAL}"
   r_escaped_sed_pattern "${closer}"
   closer="${RVAL}"

   template::generate::r_shell_var_sed "${opener}" \
                                       "${closer}" \
                                       "${sep}"  \
                                       "${prefix}" \
                                       "${suffix}" \
                                       template::generate::is_filekey

   log_debug "${RVAL}"
}


template::generate::r_content_replacement_seds()
{
   log_entry "template::generate::r_content_replacement_seds" "$@"

   local opener="$1"
   local closer="$2"
   local sep="$3"
   local prefix="$4"
   local suffix="$5"
   local filter="$6"
   local dateenv="$7"

   r_escaped_sed_pattern "${opener}"
   opener="${RVAL}"
   r_escaped_sed_pattern "${closer}"
   closer="${RVAL}"

   local cmdline

   template::generate::r_shell_var_sed "${opener}" "${closer}" "${sep}" "${prefix}" "${suffix}" "${filter}" "default"
   cmdline="${RVAL}"

   if [ "${dateenv}" != 'NO' ]
   then
      template::generate::r_generated_seds "${opener}" "${closer}" "${sep}" "${prefix}" "${suffix}"
      r_concat "${cmdline}" "${RVAL}" "${sep}"
      cmdline="${RVAL}"
   fi

   #
   # finally append a set that cleans up all values that haven't been
   # expanded of the form <|key:-default|>
   #
   template::generate::r_append_sed_default_expansion "${cmdline}" "${opener}" "${closer}" "${sep}" "${prefix}" "${suffix}"

   log_debug "${RVAL}"
}


template::generate::_cat_template_file()
{
   log_entry "template::generate::_cat_template_file" "$@"

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


template::generate::cat_template_file()
{
   log_entry "template::generate::cat_template_file" "$@"

   local templatefile="$1"

   if [ "${templatefile}" = "-" ]
   then
      template::generate::_cat_template_file
      return $?
   fi

   local char

   if ! char="`tail -c 1 "${templatefile}" 2> /dev/null`"
   then
      fail "Template file or directory \"${templatefile}\" is missing"
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

   template::generate::_cat_template_file < "${templatefile}"
}


template::generate::r_expand_filename()
{
   log_entry "template::generate::r_expand_filename" "..." "$2"

   local filename_sed="$1"
   local filename="$2"

   if [ -z "${filename_sed}" ]
   then
      RVAL="${filename}"
      return 0
   fi

   if ! RVAL="`LC_ALL=C eval sed \
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


template::generate::r_comment_for_templatefile()
{
   log_entry "template::generate::r_comment_for_templatefile"

   local templatefile="$1"
   local templatesed="$2"
   local outputfile="$2"

   local commentstart='DEFAULT'
   local commentmiddle='DEFAULT'
   local commentend='DEFAULT'

   if [ "${outputfile}" = "-" ]
   then
      outputfile=""
   fi
   outputfile="${outputfile:-${templatefile}}"

   r_basename "${outputfile}"
   r_lowercase "${RVAL}"

   case "${RVAL}" in
      *.c|*.h|*.inc|*.m|*.aam|*.js|*.cs|*.css|*.go|*.cpp|*.hpp)
         commentstart="/*"
         commentmiddle=" * "
         commentend=" */"
      ;;

      *.f|*.for|*.f90)
         commentstart=""
         commentmiddle="! "
         commentend=""
      ;;

      *.s)
         commentstart=""
         commentmiddle="; "
         commentend=""
      ;;

      *.md|*.html)
         commentstart="<!--"
         commentmiddle=""
         commentend="-->"
      ;;

      *.bas|*.bat)
         commentstart=""
         commentmiddle="REM "
         commentend=""
      ;;

      *.pl|*.py|*.rb|*.sh|*.cmake|makefile*|cmakelists.txt)
         commentstart=""
         commentmiddle="# "
         commentend=""
      ;;

      *.sql|*.hs|*.hls)
         commentstart=""
         commentmiddle="-- "
         commentend=""
      ;;

      *.zig)
         commentstart=""
         commentmiddle="// "
         commentend=""
      ;;
   esac

   RVAL=
   if [ "${OPTION_COMMENT_START}" = 'DEFAULT' ]
   then
      [ "${commentstart}" = 'DEFAULT' ] && return 1
   else
      commentstart="${OPTION_COMMENT_START}"
   fi

   if [ "${OPTION_COMMENT_MIDDLE}" = 'DEFAULT' ]
   then
      [ "${commentmiddle}" = 'DEFAULT' ] && return 1
   else
      commentmiddle="${OPTION_COMMENT_MIDDLE}"
   fi

   if [ "${OPTION_COMMENT_END}" = 'DEFAULT' ]
   then
      [ "${commentend}" = 'DEFAULT' ] && return 1
   else
      commentend="${OPTION_COMMENT_END}"
   fi

   log_verbose "Appending comment to template file \"${templatefile}\""

   local result

   result=$'\n'

   if [ ! -z "${commentstart}" ]
   then
      r_add_line "${result}" "${commentstart}"
      result="${RVAL}"
   fi

   local comment_sed

   r_basename "${templatefile}"
   TEMPLATE_FILE="${RVAL}"

   template::generate::r_append_sed_var_expansion "" "<|"  "|>" " " "'" "'" 'TEMPLATE_FILE'
   comment_sed="${RVAL}"

   local expanded

   expanded="`LC_ALL=C eval sed" \
                            -e "'${comment_sed}'" \
                            "${template_sed}" \
                            <<< "${OPTION_COMMENT//\\\\n/$'\n'}" `"

   local line

   .foreachline line in ${expanded}
   .do
      r_add_line "${result}" "${commentmiddle}${line}"
      result="${RVAL}"
   .done

   if [ ! -z "${commentend}" ]
   then
      r_add_line "${result}" "${commentend}"
      result="${RVAL}"
   fi

   RVAL="${result}"
}

#
# We know here that "templatefile" is a file and we know "outputfile" is a
# file. And the filename expansion is through.
#
template::generate::copy_and_expand()
{
   log_entry "template::generate::copy_and_expand" "..." "$2" "$3"

   local template_sed="$1"
   local templatefile="$2"
   local outputfile="$3"

   [ -z "${templatefile}" ] && _internal_fail "templatefile is empty"
   [ -z "${outputfile}" ]   && _internal_fail "outputfile is empty"

   local permissions

   if [ "${outputfile}" != '-' ]
   then
      if [ "${templatefile}" -ef "${outputfile}" ]
      then
         log_error "Template \"${templatefile}\" would clobber itself, ignored"
         return 1
      fi

      if [ -f "${outputfile}" ]
      then
         if [ "${OPTION_OVERWRITE}" = 'NO' ]
         then
            log_fluff "\"${templatefile}\" !! \"${outputfile}\" (exists)"
            return 4
         fi

         if [ ! -w "${outputfile}" ]
         then
            permissions="`lso "${outputfile}"`"
            exekutor chmod ug+w "${outputfile}" || exit 1
         fi
      else
         #
         # Directory
         #

         r_mkdir_parent_if_missing "${outputfile}"
      fi
   fi

   #
   # Permissions 1
   #
   if [ "${OPTION_PERMISSIONS}" = 'YES' ]
   then
      permissions="`lso "${templatefile}"`"
   fi

   #
   # Generation
   #
   log_debug "Generating text from template \"${templatefile}\""

   local text

   text="`template::generate::cat_template_file "${templatefile}"`" || exit 1
   if [ ! -z "${template_sed}" ]
   then
      if ! text="`LC_ALL=C eval sed \
                                "${template_sed}" \
                                <<< "${text}" `"
      then
         fail "Given template sed expression is broken: ${template_sed}"
      fi
   fi

   if [ ! -z "${OPTION_COMMENT}" ]
   then
      if template::generate::r_comment_for_templatefile "${templatefile}" \
                                                        "${template_sed}" \
                                                       "${outputfile}"
      then
         r_add_line "${text}" "${RVAL}"
         text="${RVAL}"
      fi
   fi

   if [ "${outputfile}" = '-' ]
   then
      rexekutor printf "%s\n" "${text}"
   else
      log_debug "${C_RESET_BOLD}\"${templatefile}\" -> \"${outputfile}\""
      redirect_exekutor "${outputfile}" printf "%s\n" "${text}" \
         || fail "failed to write to \"${outputfile}\" (${PWD#"${MULLE_USER_PWD}/"})"

      log_verbose "Created ${C_RESET_BOLD}${outputfile#"${MULLE_USER_PWD}/"}"

      #
      # Permissions 2
      #
      if [ ! -z "${permissions}" ]
      then
         exekutor chmod "${permissions}" "${outputfile}"
      fi
   fi
}


template::generate::do_directory()
{
   log_entry "template::generate::do_directory" "..." "..." "$3" "$4" "$5"

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

   .foreachline filename in `( cd "${templatedir}" ; find -L . -type f -print )`
   .do
      filename="${filename#./}"

      # suppress OS X uglies
      case "${filename}" in
         *.DS_Store*)
            log_debug "Suppressed ugly \"${filename}\""
            .continue
         ;;
      esac

      r_filepath_concat "${dst}" "${filename}"
      dst_filename="${RVAL}"

      template::generate::r_expand_filename "${filename_sed}" "${dst_filename}"
      expanded_filename="${RVAL}"

      #
      # possibly filter out files that don't match
      #
      if [ ! -z "${onlyfile}" ]
      then
         if [ "${expanded_filename}" != "${onlyfile}" -a "${dst_filename}" != "${onlyfile}" ]
         then
            log_fluff "Suppressed non matching \"${expanded_filename}\""
            .continue
         fi
      fi

      r_filepath_concat "${templatedir}" "${filename}"
      src_filename="${RVAL}"

      # assume we can for as much as we want
      template::generate::copy_and_expand "${template_sed}" \
                                          "${src_filename}" \
                                          "${expanded_filename}"
      if [ $? -eq 1 ]
      then
         return 1
      fi
   .done
}


template::generate::do_file()
{
   log_entry "template::generate::do_file" "..." "..." "$3" "$4" "$5"

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
      template::generate::r_expand_filename "${filename_sed}" "${RVAL}"
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
   template::generate::copy_and_expand "${template_sed}" \
                                       "${templatefile}" \
                                       "${expanded_filename}"
   if [ $? -eq 1 ]
   then
      return 1
   fi
}


template::generate::default_setup()
{
   log_entry "template::generate::default_setup" "..." "..." "$3" "$4" "$5"

   local filename_sed="$1"
   local template_sed="$2"
   local src="$3"
   local dst="$4"
   local onlyfile="$5"

   [ $# -lt 3 -o $# -gt 5 ] && template::generate::usage "Wrong number of arguments"
   [ -z "${src}" ] && template::generate::usage "No template specified"

   if [ "${src}" != "-" ]
   then
      if [ -d "${src}" ]
      then
         template::generate::do_directory "${filename_sed}" "${template_sed}" "${src}" "${dst}" "${onlyfile}"
         return $?
      fi
   fi

   template::generate::do_file "${filename_sed}" "${template_sed}" "${src}" "${dst}"  "${onlyfile}"
   if [ $? -eq 1 ]
   then
      return 1
   fi
   return 0
}



template::generate::main()
{
   log_entry "template::generate::main" "$@"

   local OPTION_EMBEDDED='NO'

   local cmd

   cmd="$1"
   shift

   [ -z "${cmd}" ] && _internal_fail "cmd is empty"

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
   local OPTION_PERMISSIONS='YES'
   local OPTION_OPENER="<|"
   local OPTION_CLOSER="|>"
   local OPTION_FILENAME_OPENER=""
   local OPTION_FILENAME_CLOSER=""
   local OPTION_OVERWRITE="${MULLE_FLAG_MAGNUM_FORCE:-NO}"
   local OPTION_WITH_TEMPLATE_DIR='YES'
   local OPTION_BORING_ENVIRONMENT='NO'
   local OPTION_DATE_ENVIRONMENT='YES'
   local OPTION_COMMENT=
   local OPTION_COMMENT_START='DEFAULT'
   local OPTION_COMMENT_MIDDLE='DEFAULT'
   local OPTION_COMMENT_END='DEFAULT'
   local OPTION_SED_PREFIX="-e '"
   local OPTION_SED_SUFFIX="'"
   local OPTION_SED_SEPARATOR=" "
   local template_callback

   template_callback="template::generate::default_setup"

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
            template::generate::usage
         ;;

         --callback)
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            template_callback="$1"
         ;;

         --comment-start)
            shift
            [ $# -eq 0 ] && template::generate::usage

            OPTION_COMMENT_START="$1"
         ;;

         --comment-middle)
            shift
            [ $# -eq 0 ] && template::generate::usage

            OPTION_COMMENT_MIDDLE="$1"
         ;;

         --comment-end)
            shift
            [ $# -eq 0 ] && template::generate::usage

            OPTION_COMMENT_END="$1"
         ;;

         --comment)
            shift
            [ $# -eq 0 ] && template::generate::usage

            OPTION_COMMENT="$1"
         ;;

         --csed|--contents-sed)
            shift
            [ $# -eq 0 ] && template::generate::usage

            CONTENTS_SED="$1"
         ;;

         --csed-script)
            shift
            [ $# -eq 0 ] && template::generate::usage

            CONTENTS_SED="-f '$1'"
         ;;

         --fsed|--filename-sed)
            shift
            [ $# -eq 0 ] && template::generate::usage

            FILENAME_SED="$1"
         ;;

         --fsed-script)
            shift
            [ $# -eq 0 ] && template::generate::usage

            FILENAME_SED="-f '$1'"
         ;;


         --file)
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            OPTION_FILE="$1"
         ;;

         --header-file)
            shift
            [ $# -eq 0 ] && template::generate::usage

            TEMPLATE_HEADER_FILE="$1"
         ;;

         --footer-file)
            shift
            [ $# -eq 0 ] && template::generate::usage

            TEMPLATE_FOOTER_FILE="$1"
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
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            OPTION_FILENAME_OPENER="$1"
         ;;

         -fc|--filename-closer)
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            OPTION_FILENAME_CLOSER="$1"
         ;;

         -o|--opener)
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            OPTION_OPENER="$1"
         ;;

         -c|--closer)
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            OPTION_CLOSER="$1"
         ;;

         --sed-separator)
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            OPTION_SED_SEPARATOR="$1"
         ;;

         --sed-prefix)
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            OPTION_SED_PREFIX="$1"
         ;;

         --sed-suffix)
            [ $# -eq 1 ] && template::generate::usage "Missing argument to \"$1\""
            shift

            OPTION_SED_SUFFIX="$1"
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
            template::generate::usage
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   if [ "${OPTION_EMBEDDED}" = 'NO' ]
   then
      options_setup_trace "${MULLE_TRACE}" && set -x
   fi

   local contents_filter

   if [ "${OPTION_BORING_ENVIRONMENT}" = 'NO' ]
   then
      contents_filter=template::generate::is_interesting_key
   fi

   case "${cmd}" in
      csed)
         [ $# -eq 0 ] || template::generate::csed_usage "Superflous arguments $*"

         template::generate::r_content_replacement_seds "${OPTION_OPENER}" \
                                                        "${OPTION_CLOSER}" \
                                                        "${OPTION_SEPARATOR}" \
                                                        "${OPTION_SED_PREFIX}" \
                                                        "${OPTION_SED_SUFFIX}" \
                                                        "${contents_filter}" \
                                                        "${OPTION_DATE_ENVIRONMENT}"
         printf "%s\n" "${RVAL}"
      ;;

      csed-script)
         local scriptfile
         local text

         template::generate::r_content_replacement_seds "${OPTION_OPENER}" \
                                                        "${OPTION_CLOSER}" \
                                                        $'\n' \
                                                        "" \
                                                        "" \
                                                        "${contents_filter}" \
                                                        "${OPTION_DATE_ENVIRONMENT}"

         text="${RVAL}"

         r_make_tmp_file "" "csed"
         scriptfile="${RVAL}"

         redirect_exekutor "${scriptfile}" printf "%s\n" "${text}"
         echo "${scriptfile}"
      ;;

      fsed)
         [ $# -eq 0 ] || template::generate::fsed_usage "Superflous arguments $*"

         template::generate::r_filename_replacement_seds "${OPTION_FILENAME_OPENER}" \
                                                         "${OPTION_FILENAME_CLOSER}" \
                                                         "${OPTION_SED_SEPARATOR}" \
                                                         "${OPTION_SED_PREFIX}" \
                                                         "${OPTION_SED_SUFFIX}"
         printf "%s\n" "${RVAL}"
      ;;

      fsed-script)
         local scriptfile
         local text

         template::generate::r_filename_replacement_seds "${OPTION_FILENAME_OPENER}" \
                                                         "${OPTION_FILENAME_CLOSER}" \
                                                         $'\n' \
                                                         "" \
                                                         ""

         text="${RVAL}"

         r_make_tmp_file "" "fsed"
         scriptfile="${RVAL}"

         redirect_exekutor "${scriptfile}" printf "%s\n" "${text}"
         echo "${scriptfile}"
      ;;


      write)
         if [ -z "${FILENAME_SED}" ]
         then
            template::generate::r_filename_replacement_seds "${OPTION_FILENAME_OPENER}" \
                                                            "${OPTION_FILENAME_CLOSER}" \
                                                            "${OPTION_SED_SEPARATOR}" \
                                                            "${OPTION_SED_PREFIX}" \
                                                            "${OPTION_SED_SUFFIX}"
            FILENAME_SED="${RVAL}"
         fi
         if [ -z "${CONTENTS_SED}" ]
         then
            template::generate::r_content_replacement_seds "${OPTION_OPENER}" \
                                                           "${OPTION_CLOSER}" \
                                                           "${OPTION_SED_SEPARATOR}" \
                                                           "${OPTION_SED_PREFIX}" \
                                                           "${OPTION_SED_SUFFIX}" \
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
         _internal_fail "Unknown command \"${cmd}\""
      ;;
   esac
}



template::generate::sde_main()
{
   #
   # hackish,  undocumented just for development
   #
   template::generate::main "write" --template-dir /tmp --callback expand_template_variables "$@"
}
