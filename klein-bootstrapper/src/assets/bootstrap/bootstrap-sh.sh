#!/usr/bin/env sh

export KLEIN_BOOTSTRAPPER_REPO="$([ -z "$KLEIN_BOOTSTRAPPER_REPO" ] && echo "quay.io/klein" || echo "$KLEIN_BOOTSTRAPPER_REPO")"
export KLEIN_BOOTSTRAPPER="$([ -z "$KLEIN_BOOTSTRAPPER" ] && echo "klein-bootstrapper-test" || echo "$KLEIN_BOOTSTRAPPER")"
export KLEIN_SESSION_NAME="$([ -z "$KLEIN_SESSION_NAME" ] && echo "klein-localdev-$(date +%s)" || echo "$KLEIN_SESSION_NAME")"
export KLEIN_INTERNAL_USER="podman"
{ # UTILS
    indent() {
        local indentSize=2
        local indent=1
        if [ -n "$1" ]; then indent=$1; fi
        pr -to $(($indent * $indentSize))
    }
    common() {
        diff <(echo "$1" | tr '/' '\n') <(echo "$2" | tr '/' '\n') -w --old-line-format '' --new-line-format '' | paste -sd /
    }
    { # tmpfile management
        klein_reserve_temp() {
            klein_reserve_session_tmp_files
            tmpfile="$(mktemp -t klein-bootstrap.file.XXXXXXXXXX)"
            echo $tmpfile >> $SESSION_FILES
            echo $tmpfile
        }
    }
    { # Cleanup Utils
        klein_reserve_session_tmp_files() {
            if [[ -z "$SESSION_FILES" ]] ; then
                export SESSION_FILES="$(mktemp -t klein-bootstrap.session.XXXXXXXXXX)"
                trap "exit \$exit_code" INT TERM
                trap "exit_code=\$?; klein_cleanup; kill 0" EXIT
            fi
        }
        klein_cleanup() {
            if [[ -z "$SESSION_FILES" ]] ; then
                echo "No session to cleanup..."
                return 0
            fi
            echo "Cleaning up $(cat $SESSION_FILES | wc -l) tmpfiles"
            cat $SESSION_FILES | while read tmpfile; do
                rm -f $tmpfile
            done
            rm -f $SESSION_FILES
            unset SESSION_FILES
            klein_stop_localdev
        }
    }
    klein_reserve_session_tmp_files
}
klein_raw() {
    podman exec -it $KLEIN_SESSION_NAME bash -c "$@"
}
klein_cache_env_defaults() {
    export KLEIN_ENV_OVERRIDES="$(klein_reserve_temp)"
    klein_raw "cat /bootstrap/env_overrides" > $KLEIN_ENV_OVERRIDES
}
klein_restart_localdev() {
    CWD="$(pwd)"
    if [[ ! -z "$(podman ps -qf "name=$KLEIN_SESSION_NAME")" ]]; then
        klein_stop_localdev
    fi
    podman run \
        -v "/:/devroot" \
        -v "$HOME/.bash_history:/root/.bash_history" \
        -v "$HOME/.bash_history:/podman/.bash_history" \
        -v "$HOME/.local/share/containers:/$KLEIN_INTERNAL_USER/.local/share/containers" \
        --hostname klein-localdev \
        -itd \
        --rm \
        --workdir "/devroot/$CWD" \
        --name $KLEIN_SESSION_NAME \
        "$KLEIN_BOOTSTRAPPER_REPO/$KLEIN_BOOTSTRAPPER" \
        sh
    klein_cache_env_defaults
}
klein_stop_localdev() {
    podman stop -t 0 $KLEIN_SESSION_NAME 
}

klein_restart_localdev
klein_shell() {
    podman exec -it \
        --env-file <(env) \
        --env-file $KLEIN_ENV_OVERRIDES \
        --workdir "/devroot/$CWD" \
        $KLEIN_SESSION_NAME \
        bash --login
}
_() {
    CWD="$(pwd)"
    HAS_PIPE=$([ ! -t 0 ]; echo $?)
    vars="$@"
    podman exec \
        -i \
        --env-file <(env) \
        --env-file $KLEIN_ENV_OVERRIDES \
        --env "SHLVL=$(( $SHLVL + 1 ))" \
        --workdir "/devroot/$CWD" \
        $KLEIN_SESSION_NAME \
        bash --login --pretty-print -ic "exec 0>/dev/pts/0; exec 1>/dev/pts/0; exec 2>/dev/pts/0; { [[ $HAS_PIPE -eq 0 ]] && cat || echo ''; } | $vars"
}
