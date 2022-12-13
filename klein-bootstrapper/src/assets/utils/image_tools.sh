hash_src() {
    export TARGET_PATH="$(readlink -f "$1")"
    (
        set -e
        tmpfile="$(mktemp /tmp/klein-tools.XXXXXX)"
        trap "rm --force $tmpfile;" EXIT INT TERM

        cd "$TARGET_PATH" 1>/dev/null
        find . -type f -print0 \
            | xargs -0 -n1 realpath --relative-to="$TARGET_PATH" \
            | sort | while read -r line; do echo "./$line"; done \
            | xargs sha1sum \
            | tee "$tmpfile" \
            | sha1sum
        cat "$tmpfile"
        rm --force "$tmpfile"
    )
}
clear_manifest() {
    DIGESTS="$(podman manifest inspect "$1" | jq '.manifests[]?.digest')"
    if [ -z "$DIGESTS" ]; then 
        return 0;
    fi
    echo "$DIGESTS" | xargs -n1 podman manifest remove "$1"
}