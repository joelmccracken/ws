setup (){
    load 'test_helper/helper'
    _setup_common
    . "$PROJECT_ROOT/ws_tool/lib/lib.bash"
}

@test "find_bracketed_content" {
    local tmp content
    tmp="$(_mktemp "get-content")/file"
    read -r -d '' src <<-EOF || :
	BEFORE
	BEGIN
	1
	2
	END
	AFTER
EOF

    REPLY=()
    find_bracketed_content "BEGIN" "END" <<< "$src"
    local content=("${REPLY[@]}");
    REPLY=()

    assert [ "${content[0]}" == $'BEFORE\n' ]
    assert [ "${content[1]}" == $'BEGIN\n1\n2\nEND\n' ]
    assert [ "${content[2]}" == $'AFTER\n' ]
}

@test "find_bracketed_content never ending" {
    local tmp content
    tmp="$(_mktemp "get-content")/file"
    read -r -d '' src <<-EOF || :
	BEFORE
	BEGIN
	1
	2
	AFTER
EOF

    REPLY=()
    find_bracketed_content "BEGIN" "END" <<< "$src"
    local content=("${REPLY[@]}");
    REPLY=()

    assert [ "${content[0]}" == $'BEFORE\n' ]
    assert [ "${content[1]}" == $'BEGIN\n1\n2\nAFTER\n' ]
    assert [ "${content[2]}" == '' ]
}

@test "find_bracketed_content never starts" {
    local tmp content
    tmp="$(_mktemp "get-content")/file"
    read -r -d '' src <<-EOF || :
	BEFORE
	1
	2
    END
	AFTER
EOF

    REPLY=()
    find_bracketed_content "BEGIN" "END" <<< "$src"
    local content=("${REPLY[@]}");
    REPLY=()

    assert [ "${content[0]}" == $'BEFORE\n1\n2\nEND\nAFTER\n' ]
    assert [ "${content[1]}" == '' ]
    assert [ "${content[2]}" == '' ]
}




# @test "get_content_between never starts" {
#     local tmp content
#     tmp="$(_mktemp "get-content")/file"
#     cat <<-EOF > "$tmp"
# 	BEFORE
# 	BEGIN
# 	1
# 	2
# 	3
# 	AFTER
# EOF
#     content=$(get_content_between_lines "BEGINNN" "END" < "$tmp")
# }
