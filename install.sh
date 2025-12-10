#!/bin/bash
set -o nounset

die () {
    while test $# -ge 1
    do
        printf >&2 "%s\n" "$1"
        shift
    done
    exit 1
}

associate_files () {
    local ft
    if test "$uninstall"
    then
        for ft in "${!ftt[@]}"
        do
            printf "Remove association of %s\n" "$ft"
            reg delete "$classes\\nvim.$ft" //f 1>/dev/null 2>&1
            reg delete "$classes\\.$ft\\OpenWithProgids" //v "nvim.$ft" //f 1>/dev/null 2>&1
        done
        return 0
    else
        for ft in "${!ftt[@]}"
        do
            printf "Associate %s\n" "$ft"
            reg add "$classes\\nvim.$ft" //ve //t "$t_sz" //d "${ftt[$ft]}" //f 1>/dev/null || return
            reg add "$classes\\nvim.$ft\\DefaultIcon" //ve //t "$t_ex" //d "$icon" //f 1>/dev/null || return
            reg add "$classes\\nvim.$ft\\shell\\open" //v "Icon" //t "$t_ex" //d "$prog" //f 1>/dev/null || return
            reg add "$classes\\nvim.$ft\\shell\\open" //v "FriendlyAppName" //t "$t_sz" //d "$name" //f 1>/dev/null || return
            reg add "$classes\\nvim.$ft\\shell\\open\\command" //ve //t "$t_ex" //d "$command" //f 1>/dev/null || return
            reg add "$classes\\.$ft\\OpenWithProgids" //v "nvim.$ft" //t "$t_none" //f 1>/dev/null || return
        done
    fi
}

associate_text_type () {
    if test "$uninstall"
    then
        printf "Remove associations of text type\n"
        reg delete "$classes\\SystemFileAssociations\\text\\shell\\edit\\command" //f 1>/dev/null 2>&1
        reg delete "$classes\\SystemFileAssociations\\text\\shell\\open\\command" //f 1>/dev/null 2>&1
        return 0
    else
        printf "Associate text type\n"
        reg add "$classes\\SystemFileAssociations\\text\\shell\\edit\\command" //ve //t "$t_ex" //d "$command" //f 1>/dev/null || return
        reg add "$classes\\SystemFileAssociations\\text\\shell\\open\\command" //ve //t "$t_ex" //d "$command" //f 1>/dev/null || return
    fi
}

install_open_with () {
    local text="Edit with NeoVim (&W)"
    if test "$uninstall"
    then
        printf "Remove Edit with NeoVim\n"
        reg delete "$classes\\*\\shell\\nvim" //f 1>/dev/null 2>&1
        reg delete "$classes\\Applications\\nvim.exe" //f 1>/dev/null 2>&1
        return 0
    else
        printf "Register program\n"
        reg add "$classes\\*\\shell\\nvim" //ve //t "$t_sz" //d "$text" //f 1>/dev/null || return
        reg add "$classes\\*\\shell\\nvim" //v "Icon" //t "$t_ex" //d "$prog" //f  1>/dev/null || return
        reg add "$classes\\*\\shell\\nvim\\command" //ve //t "$t_ex" //d "$command" //f 1>/dev/null || return
        reg add "$classes\\Applications\\nvim.exe\\DefaultIcon" //ve //t "$t_ex" //d "$icon" //f 1>/dev/null || return
        reg add "$classes\\Applications\\nvim.exe\\shell\\open" //v "Icon" //t "$t_ex" //d "$prog" //f 1>/dev/null || return
        reg add "$classes\\Applications\\nvim.exe\\shell\\open\\command" //ve //t "$t_ex" //d "$command" //f 1>/dev/null || return
    fi
}

InitFileTypeTable () {
    ftt=( \
        ['adoc']='AsciiDoc File' \
        ['asl']='ACPI Source Language File' \
        ['ass']='ASS Subtitle File' \
        ['bash']='Bash Script' \
        ['bashrc']='Bash Run Command Script' \
        ['bash_history']='Bash History File' \
        ['bash_login']='Bash Login Script' \
        ['bash_logout']='Bash Logout Script' \
        ['bash_profile']='Bash Profile Script' \
        ['c']='C Source File' \
        ['c++']='C++ Source File' \
        ['cfg']='Configuration File' \
        ['conf']='Configuration File' \
        ['config']='Configuration File' \
        ['cpp']='C++ Source File' \
        ['cs']='C# Source File' \
        ['css']='Cascading Style Sheet File' \
        ['csv']='Comma Separated Values File' \
        ['diff']='Diff File' \
        ['dockerfile']='Dockerfile Source File' \
        ['editorconfig']='Editor Configuration File' \
        ['git']='git Source File' \
        ['gitattributes']='Git Attributes File' \
        ['gitconfig']='Git Configuration File' \
        ['gitignore']='Git Ignore File' \
        ['gitmodules']='Git Modules File' \
        ['go']='Go Source File' \
        ['groovy']='Groovy Source File' \
        ['h']='C Header Source File' \
        ['h++']='C++ Header Source File' \
        ['hpp']='C++ Header Source File' \
        ['htm']='HTML Source File' \
        ['html']='HTML Source File' \
        ['ini']='INI Configuration File' \
        ['inputrc']='Inputrc File' \
        ['java']='Java Source File' \
        ['js']='JavaScript Source File' \
        ['json']='JavaScript Object Notation File' \
        ['lesshst']='Less History File' \
        ['log']='Log File' \
        ['lua']='Lua Source File' \
        ['mak']='Makefile Source File' \
        ['makefile']='Makefile Source File' \
        ['markdown']='Markdown File' \
        ['md']='Markdown File' \
        ['minttyrc']='Mintty Run Command Script' \
        ['netrc']='Netrw Run Command Script' \
        ['netrwhist']='Netrw History File' \
        ['nsh']='EFI Shell Script' \
        ['patch']='Patch File' \
        ['php']='PHP Source File' \
        ['profile']='Profile Script' \
        ['ps1']='PowerShell Source File' \
        ['py']='Python Script' \
        ['pyi']='Python Stub File' \
        ['rej']='Patch Rejected Hunks File' \
        ['sh']='Shell Script' \
        ['shtml']='SHTML Source File' \
        ['srt']='SubRip Subtitle File' \
        ['ssa']='Sub Station Alpha Subtitle File' \
        ['toml']='TOML File' \
        ['txt']='Text Document' \
        ['vb']='vb Source File' \
        ['vim']='Vimscript Source File' \
        ['viminfo']='Viminfo File' \
        ['vimrc']='Vim Run Command Script' \
        ['xml']='Extensible Markup Language File' \
        ['yaml']='YAML File' \
        ['yml']='YAML File' \
        ['zsh']='Zsh Script' \
    )
}

install () {
    local classes='HKCU\SOFTWARE\Classes'
    local name='NeoVim'
    local prog='%ProgramFiles%\NeoVim\bin\nvim.exe'
    local flag='"%1"'
    local command="$prog $flag"
    local icon='%SystemRoot%\system32\imageres.dll,-102'
    local t_sz="REG_SZ" t_ex="REG_EXPAND_SZ" t_none="REG_NONE"
    local -A ftt
    is_windows || die "error: system is not Windows"
    InitFileTypeTable || return
    install_open_with || return
    associate_text_type || return
    associate_files || return
}

is_windows () {
    test "${WINDIR-}"
}

print_help () {
cat <<EOF
usage: $0 [-h] [-u]

Use without argument to create file associations for NeoVim.

options:
    -h, --help          print help and exit
    -u, --uninstall     remove file associations created by this script
EOF
}

parse_args () {
    while test $# -ge 1
    do
        case $1 in
            -h|--help)
                print_help
                return 0
                ;;
            -u|--uninstall)
                uninstall=1
                shift
                ;;
            *)
                die "error: invalid argument \`$1'"
                ;;
        esac
    done
}

main () {
    local uninstall=
    parse_args "$@"
    install || return
}

main "$@"
