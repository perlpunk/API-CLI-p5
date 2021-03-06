#!bash

# http://stackoverflow.com/questions/7267185/bash-autocompletion-add-description-for-possible-completions

_digitaloceancl() {

    COMPREPLY=()
    local program=digitaloceancl
    local cur=${COMP_WORDS[$COMP_CWORD]}
#    echo "COMP_CWORD:$COMP_CWORD cur:$cur" >>/tmp/comp
    declare -a FLAGS
    declare -a OPTIONS
    declare -a MYWORDS

    local INDEX=`expr $COMP_CWORD - 1`
    MYWORDS=("${COMP_WORDS[@]:1:$COMP_CWORD}")

    FLAGS=('--debug' 'debug' '-d' 'debug' '--verbose' 'verbose' '-v' 'verbose' '--help' 'Show command help' '-h' 'Show command help')
    OPTIONS=('--data-file' 'File with data for POST/PUT/PATCH/DELETE requests')
    __digitaloceancl_handle_options_flags

    case $INDEX in

    0)
        __comp_current_options || return
        __digitaloceancl_dynamic_comp 'commands' 'GET'$'\t''GET call'$'\n''POST'$'\t''POST call'$'\n''help'$'\t''Show command help'

    ;;
    *)
    # subcmds
    case ${MYWORDS[0]} in
      GET)
        FLAGS+=()
        OPTIONS+=()
        __digitaloceancl_handle_options_flags
        case $INDEX in

        1)
            __comp_current_options || return
            __digitaloceancl_dynamic_comp 'commands' '/account'$'\t''Account information'$'\n''/droplets'$'\t''List all droplets'$'\n''/droplets/:id'$'\t''Retrieve a droplet by id'

        ;;
        *)
        # subcmds
        case ${MYWORDS[1]} in
          /account)
            FLAGS+=()
            OPTIONS+=()
            __digitaloceancl_handle_options_flags
            __comp_current_options true || return # no subcmds, no params/opts
          ;;
          /droplets)
            FLAGS+=()
            OPTIONS+=()
            __digitaloceancl_handle_options_flags
            __comp_current_options true || return # no subcmds, no params/opts
          ;;
          /droplets/:id)
            FLAGS+=()
            OPTIONS+=()
            __digitaloceancl_handle_options_flags
              case $INDEX in
              2)
                  __comp_current_options || return
              ;;
              *)
                __comp_current_options true || return # after parameters
                case ${MYWORDS[$INDEX-1]} in
                  --data-file)
                  ;;

                esac
                ;;
            esac
          ;;
        esac

        ;;
        esac
      ;;
      POST)
        FLAGS+=()
        OPTIONS+=()
        __digitaloceancl_handle_options_flags
        case $INDEX in

        1)
            __comp_current_options || return
            __digitaloceancl_dynamic_comp 'commands' '/droplets/:id/actions'$'\t''Trigger droplet action'

        ;;
        *)
        # subcmds
        case ${MYWORDS[1]} in
          /droplets/:id/actions)
            FLAGS+=()
            OPTIONS+=()
            __digitaloceancl_handle_options_flags
            __comp_current_options true || return # no subcmds, no params/opts
          ;;
        esac

        ;;
        esac
      ;;
      _meta)
        FLAGS+=()
        OPTIONS+=()
        __digitaloceancl_handle_options_flags
        case $INDEX in

        1)
            __comp_current_options || return
            __digitaloceancl_dynamic_comp 'commands' 'completion'$'\t''Shell completion functions'$'\n''pod'$'\t''Pod documentation'

        ;;
        *)
        # subcmds
        case ${MYWORDS[1]} in
          completion)
            FLAGS+=()
            OPTIONS+=()
            __digitaloceancl_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __digitaloceancl_dynamic_comp 'commands' 'generate'$'\t''Generate self completion'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              generate)
                FLAGS+=('--zsh' 'for zsh' '--bash' 'for bash')
                OPTIONS+=('--name' 'name of the program (optional, override name in spec)')
                __digitaloceancl_handle_options_flags
                  case $INDEX in
                  *)
                    __comp_current_options true || return # after parameters
                    case ${MYWORDS[$INDEX-1]} in
                      --data-file)
                      ;;
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
            __digitaloceancl_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __digitaloceancl_dynamic_comp 'commands' 'generate'$'\t''Generate self pod'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              generate)
                FLAGS+=()
                OPTIONS+=()
                __digitaloceancl_handle_options_flags
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
      help)
        FLAGS+=('--all' '')
        OPTIONS+=()
        __digitaloceancl_handle_options_flags
        case $INDEX in

        1)
            __comp_current_options || return
            __digitaloceancl_dynamic_comp 'commands' 'GET'$'\n''POST'

        ;;
        *)
        # subcmds
        case ${MYWORDS[1]} in
          GET)
            FLAGS+=()
            OPTIONS+=()
            __digitaloceancl_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __digitaloceancl_dynamic_comp 'commands' '/account'$'\n''/droplets'$'\n''/droplets/:id'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              /account)
                FLAGS+=()
                OPTIONS+=()
                __digitaloceancl_handle_options_flags
                __comp_current_options true || return # no subcmds, no params/opts
              ;;
              /droplets)
                FLAGS+=()
                OPTIONS+=()
                __digitaloceancl_handle_options_flags
                __comp_current_options true || return # no subcmds, no params/opts
              ;;
              /droplets/:id)
                FLAGS+=()
                OPTIONS+=()
                __digitaloceancl_handle_options_flags
                __comp_current_options true || return # no subcmds, no params/opts
              ;;
            esac

            ;;
            esac
          ;;
          POST)
            FLAGS+=()
            OPTIONS+=()
            __digitaloceancl_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __digitaloceancl_dynamic_comp 'commands' '/droplets/:id/actions'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              /droplets/:id/actions)
                FLAGS+=()
                OPTIONS+=()
                __digitaloceancl_handle_options_flags
                __comp_current_options true || return # no subcmds, no params/opts
              ;;
            esac

            ;;
            esac
          ;;
          _meta)
            FLAGS+=()
            OPTIONS+=()
            __digitaloceancl_handle_options_flags
            case $INDEX in

            2)
                __comp_current_options || return
                __digitaloceancl_dynamic_comp 'commands' 'completion'$'\n''pod'

            ;;
            *)
            # subcmds
            case ${MYWORDS[2]} in
              completion)
                FLAGS+=()
                OPTIONS+=()
                __digitaloceancl_handle_options_flags
                case $INDEX in

                3)
                    __comp_current_options || return
                    __digitaloceancl_dynamic_comp 'commands' 'generate'

                ;;
                *)
                # subcmds
                case ${MYWORDS[3]} in
                  generate)
                    FLAGS+=()
                    OPTIONS+=()
                    __digitaloceancl_handle_options_flags
                    __comp_current_options true || return # no subcmds, no params/opts
                  ;;
                esac

                ;;
                esac
              ;;
              pod)
                FLAGS+=()
                OPTIONS+=()
                __digitaloceancl_handle_options_flags
                case $INDEX in

                3)
                    __comp_current_options || return
                    __digitaloceancl_dynamic_comp 'commands' 'generate'

                ;;
                *)
                # subcmds
                case ${MYWORDS[3]} in
                  generate)
                    FLAGS+=()
                    OPTIONS+=()
                    __digitaloceancl_handle_options_flags
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
        esac

        ;;
        esac
      ;;
    esac

    ;;
    esac

}

_digitaloceancl_compreply() {
    IFS=$'\n' COMPREPLY=($(compgen -W "$1" -- ${COMP_WORDS[COMP_CWORD]}))
    if [[ ${#COMPREPLY[*]} -eq 1 ]]; then # Only one completion
        COMPREPLY=( ${COMPREPLY[0]%% -- *} ) # Remove ' -- ' and everything after
        COMPREPLY="$(echo -e "$COMPREPLY" | sed -e 's/[[:space:]]*$//')"
    fi
}


__digitaloceancl_dynamic_comp() {
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
    _digitaloceancl_compreply "$comp"
}

function __digitaloceancl_handle_options() {
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

function __digitaloceancl_handle_flags() {
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

__digitaloceancl_handle_options_flags() {
    __digitaloceancl_handle_options
    __digitaloceancl_handle_flags
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
      __digitaloceancl_dynamic_comp 'options' "$options_spec"

      return 1
    else
      return 0
    fi
}


complete -o default -F _digitaloceancl digitaloceancl

