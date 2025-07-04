use argx

export def mc-alias [] {
    ^mc alias ls --json
    | from json -o
    | each {|x|
        {
            value: $"($x.alias)/"
            description: $x.URL
        }
    }
}

export def mc-subkey [] {
    let key = $in | default '' | split row '/'
    if ($key | length) < 2 {
        mc-alias
    } else {
        let k = $key | slice 0..-2 | str join '/'
        mc-ls $k
        | where {|x| $x.type == 'dir'}
        | get key
        | each {|x|
            [$k $x] | path join
        }
    }
}

def gen-cmpl [key] {
    $in | argx parse | get ($key | into cell-path) | mc-subkey
}

export def 'nu-cmp mc-src' [context: string] {
    $context | gen-cmpl [pos src]
}

export def 'nu-cmp mc-dest' [context: string] {
    $context | gen-cmpl [pos dest]
}

export def mc-ls [
    src: string@'nu-cmp mc-src'
] {
    ^mc ls $src --json
    | from json -o
    | each {|x|
        let t = match $x.type {
            folder => 'dir',
            _ => $x.type
        }
        let modified = $x.lastModified | into datetime
        {
            key: $x.key
            type: $t
            size: $x.size
            modified: $modified
            ver: $x.versionOrdinal
            etag: $x.etag
            url: $x.url
        }
    }
}

export def mc-rm [
    src: string@'nu-cmp mc-src'
] {
    ^mc rm -r --force $src
}

export def mc-du [
    src: string@'nu-cmp mc-src'
] {
    ^mc du $src
}

export def mc-tree [
    src: string@'nu-cmp mc-src'
] {
    ^mc tree $src
}

export def mc-mv [
    src: string@'nu-cmp mc-src'
    dest: string@'nu-cmp mc-dest'
] {
    ^mc mv $src $dest
}

export def mc-cp [
    src: string@'nu-cmp mc-src'
    dest: string@'nu-cmp mc-dest'
] {
    ^mc cp $src $dest
}

export def mc-put [
    src: string
    dest: string@'nu-cmp mc-dest'
] {
    ^mc put $src $dest
}
