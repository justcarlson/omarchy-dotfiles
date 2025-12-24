# Add ~/.local/bin to PATH (for bd, etc.)
fish_add_path -gP ~/.local/bin

# Source secrets from ~/.secrets (bash format export statements)
if test -f ~/.secrets
    for line in (grep -E '^export ' ~/.secrets)
        set -l kv (string replace 'export ' '' $line | string replace -r '="(.*)"\s*$' '=$1')
        set -l key (string split -m1 '=' $kv)[1]
        set -l val (string split -m1 '=' $kv)[2]
        set -gx $key $val
    end
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end
