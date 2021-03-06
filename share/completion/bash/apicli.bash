#!bash

# http://stackoverflow.com/questions/7267185/bash-autocompletion-add-description-for-possible-completions

_apicli() {

    COMPREPLY=()
    local program=apicli
    local cur=${COMP_WORDS[$COMP_CWORD]}
#    echo "COMP_CWORD:$COMP_CWORD cur:$cur" >>/tmp/comp
    declare -a FLAGS
    declare -a OPTIONS
    declare -a MYWORDS

    local INDEX=`expr $COMP_CWORD - 1`
    MYWORDS=("${COMP_WORDS[@]:1:$COMP_CWORD}")

    FLAGS=('--help' 'Show command help' '-h' 'Show command help')
    OPTIONS=()
    __apicli_handle_options_flags

    case $INDEX in

    0)
        __comp_current_options || return
        __apicli_dynamic_comp 'commands' 'appspec'$'\t''Generate App::Spec file'$'\n''help'$'\t''Show command help'

    ;;
    *)
    # subcmds
    case ${MYWORDS[0]} in
      _meta)
        FLAGS+=()
        OPTIONS+=()
        __apicli_handle_options_flags
        case $INDEX in

        1)
            __comp_current_options || return
            __apicli_dynamic_comp 'commands' 'completion'$'\t''Shell completion functions'$'\n''pod'$'\t''Pod documentation'

        ;;
        *)
        # subcmds
        case ${MYWORDS[1]} in
          completion)
            FLAGS+=()
            OPTIONS+=()
            __apicli_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __apicli_dynamic_comp 'commands' 'generate'$'\t''Generate self completion'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              generate)
                FLAGS+=('--zsh' 'for zsh' '--bash' 'for bash')
                OPTIONS+=('--name' 'name of the program (optional, override name in spec)')
                __apicli_handle_options_flags
                  case $INDEX in
                  *)
                    __comp_current_options true || return # after parameters
                    case ${MYWORDS[$INDEX-1]} in
                      --name)
                      ;;

                    esac
                    ;;
                esac
              ;;
            esac

            ;;
            esac
          ;;
          pod)
            FLAGS+=()
            OPTIONS+=()
            __apicli_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __apicli_dynamic_comp 'commands' 'generate'$'\t''Generate self pod'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              generate)
                FLAGS+=()
                OPTIONS+=()
                __apicli_handle_options_flags
                __comp_current_options true || return # no subcmds, no params/opts
              ;;
            esac

            ;;
            esac
          ;;
        esac

        ;;
        esac
      ;;
      appspec)
        FLAGS+=()
        OPTIONS+=('--from' 'Currently only '"'"'openapi'"'"' is supported' '--out' 'Output file (default stdout)' '--name' 'appname' '--class' 'Class name (default API::CLI)')
        __apicli_handle_options_flags
          case $INDEX in
          1)
              __comp_current_options || return
          ;;
          *)
            __comp_current_options true || return # after parameters
            case ${MYWORDS[$INDEX-1]} in
              --from)
              ;;
              --out)
              ;;
              --name)
              ;;
              --class)
              ;;

            esac
            ;;
        esac
      ;;
      help)
        FLAGS+=('--all' '')
        OPTIONS+=()
        __apicli_handle_options_flags
        case $INDEX in

        1)
            __comp_current_options || return
            __apicli_dynamic_comp 'commands' 'appspec'

        ;;
        *)
        # subcmds
        case ${MYWORDS[1]} in
          _meta)
            FLAGS+=()
            OPTIONS+=()
            __apicli_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __apicli_dynamic_comp 'commands' 'completion'$'\n''pod'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              completion)
                FLAGS+=()
                OPTIONS+=()
                __apicli_handle_options_flags
                case $INDEX in

                3)
                    __comp_current_options || return
                    __apicli_dynamic_comp 'commands' 'generate'

                ;;
                *)
                # subcmds
                case ${MYWORDS[3]} in
                  generate)
                    FLAGS+=()
                    OPTIONS+=()
                    __apicli_handle_options_flags
                    __comp_current_options true || return # no subcmds, no params/opts
                  ;;
                esac

                ;;
                esac
              ;;
              pod)
                FLAGS+=()
                OPTIONS+=()
                __apicli_handle_options_flags
                case $INDEX in

                3)
                    __comp_current_options || return
                    __apicli_dynamic_comp 'commands' 'generate'

                ;;
                *)
                # subcmds
                case ${MYWORDS[3]} in
                  generate)
                    FLAGS+=()
                    OPTIONS+=()
                    __apicli_handle_options_flags
                    __comp_current_options true || return # no subcmds, no params/opts
                  ;;
                esac

                ;;
                esac
              ;;
            esac

            ;;
            esac
          ;;
          appspec)
            FLAGS+=()
            OPTIONS+=()
            __apicli_handle_options_flags
            __comp_current_options true || return # no subcmds, no params/opts
          ;;
        esac

        ;;
        esac
      ;;
    esac

    ;;
    esac

}

_apicli_compreply() {
    IFS=$'\n' COMPREPLY=($(compgen -W "$1" -- ${COMP_WORDS[COMP_CWORD]}))
    if [[ ${#COMPREPLY[*]} -eq 1 ]]; then # Only one completion
        COMPREPLY=( ${COMPREPLY[0]%% -- *} ) # Remove ' -- ' and everything after
        COMPREPLY="$(echo -e "$COMPREPLY" | sed -e 's/[[:space:]]*$//')"
    fi
}


__apicli_dynamic_comp() {
    local argname="$1"
    local arg="$2"
    local comp name desc cols desclength formatted
    local max=0

    while read -r line; do
        name="$line"
        desc="$line"
        name="${name%$'\t'*}"
        if [[ "${#name}" -gt "$max" ]]; then
            max="${#name}"
        fi
    done <<< "$arg"

    while read -r line; do
        name="$line"
        desc="$line"
        name="${name%$'\t'*}"
        desc="${desc/*$'\t'}"
        if [[ -n "$desc" && "$desc" != "$name" ]]; then
            # TODO portable?
            cols=`tput cols`
            [[ -z $cols ]] && cols=80
            desclength=`expr $cols - 4 - $max`
            formatted=`printf "'%-*s -- %-*s'" "$max" "$name" "$desclength" "$desc"`
            comp="$comp$formatted"$'\n'
        else
            comp="$comp'$name'"$'\n'
        fi
    done <<< "$arg"
    _apicli_compreply "$comp"
}

function __apicli_handle_options() {
    local i j
    declare -a copy
    local last="${MYWORDS[$INDEX]}"
    local max=`expr ${#MYWORDS[@]} - 1`
    for ((i=0; i<$max; i++))
    do
        local word="${MYWORDS[$i]}"
        local found=
        for ((j=0; j<${#OPTIONS[@]}; j+=2))
        do
            local option="${OPTIONS[$j]}"
            if [[ "$word" == "$option" ]]; then
                found=1
                i=`expr $i + 1`
                break
            fi
        done
        if [[ -n $found && $i -lt $max ]]; then
            INDEX=`expr $INDEX - 2`
        else
            copy+=("$word")
        fi
    done
    MYWORDS=("${copy[@]}" "$last")
}

function __apicli_handle_flags() {
    local i j
    declare -a copy
    local last="${MYWORDS[$INDEX]}"
    local max=`expr ${#MYWORDS[@]} - 1`
    for ((i=0; i<$max; i++))
    do
        local word="${MYWORDS[$i]}"
        local found=
        for ((j=0; j<${#FLAGS[@]}; j+=2))
        do
            local flag="${FLAGS[$j]}"
            if [[ "$word" == "$flag" ]]; then
                found=1
                break
            fi
        done
        if [[ -n $found ]]; then
            INDEX=`expr $INDEX - 1`
        else
            copy+=("$word")
        fi
    done
    MYWORDS=("${copy[@]}" "$last")
}

__apicli_handle_options_flags() {
    __apicli_handle_options
    __apicli_handle_flags
}

__comp_current_options() {
    local always="$1"
    if [[ -n $always || ${MYWORDS[$INDEX]} =~ ^- ]]; then

      local options_spec=''
      local j=

      for ((j=0; j<${#FLAGS[@]}; j+=2))
      do
          local name="${FLAGS[$j]}"
          local desc="${FLAGS[$j+1]}"
          options_spec+="$name"$'\t'"$desc"$'\n'
      done

      for ((j=0; j<${#OPTIONS[@]}; j+=2))
      do
          local name="${OPTIONS[$j]}"
          local desc="${OPTIONS[$j+1]}"
          options_spec+="$name"$'\t'"$desc"$'\n'
      done
      __apicli_dynamic_comp 'options' "$options_spec"

      return 1
    else
      return 0
    fi
}


complete -o default -F _apicli apicli

