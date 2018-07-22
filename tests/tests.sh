XGOD="$(realpath "$(dirname "$0")")/../xgod"
CUR_DIR="$(realpath "$(dirname "$0")")"
OUT=1

TESTS_OK=0
TESTS_ALL=0

function check_test()
{
    if [[ -z "$1" ]]; then
        echo "Build file is empty"
        return 1
    fi
    if [[ -z "$2" ]]; then
        echo "Empty args"
        return 1
    fi
    if [[ "$3" != "equal" && "$3" != "subset" && "$3" != "notequal" && "$3" != "notsubset" ]]; then
        echo "Incorrect equal string"
        return 1
    fi
    if [[ -z "$4" ]]; then
        echo "Check string is empty"
        return 1
    fi
    TESTS_ALL=$(($TESTS_ALL + 1))
    out="$("$XGOD" "$1" "$2")"
    if [[ $OUT -eq 1 ]]; then
        echo "$out"
    fi
    res="true"
    for (( i = 3; i < $#; i++ ))
    do
        case "${!i}" in
            equal)
                let "i=$i+1"
                if [[ "$out" != "${!i}" ]]; then
                    res="false"
                fi
            ;;
            notequal)
                let "i=$i+1"
                if [[ "$out" == "${!i}" ]]; then
                    res="false"
                fi
            ;;
            subset)
                let "i=$i+1"
                if [[ -z "$(echo "$out" | grep "${!i}")" ]]; then
                    res="false"
                fi
            ;;
            notsubset)
                let "i=$i+1"
                if [[ -n "$(echo "$out" | grep "${!i}")" ]]; then
                    res="false"
                fi
            ;;
        esac
    done
    if [[ "$res" == "true" ]]; then
        echo -e "\033[32mTest with \033[1m\""$1 $2"\"\033[0m\033[32m is checked\033[0m"
        TESTS_OK=$(($TESTS_OK + 1))
    else
        echo -e "\033[31mTest with \033[1m\""$1 $2"\"\033[0m\033[31m is not checked\033[0m"
        echo "$out"
    fi
}



function target_simple()
{
    check_test targetok.xg simple1 subset "SIMPLE1-OK"
    check_test targetok.xg simple2 subset "SIMPLE2-OK"
}

function target_manytargets()
{
    check_test targetok.xg "simple1 simple2" subset "SIMPLE1-OK" \
        subset "SIMPLE2-OK"
}

function target_dependone()
{
    check_test targetok.xg "dependone" subset "SIMPLE1-OK" subset \
        "DEPENDONE-OK"
}

function target_dependtwo()
{
    check_test targetok.xg "dependtwo" subset "SIMPLE1-OK" subset \
        "SIMPLE2-OK" subset "DEPENDTWO-OK"
}

function target_dependdeep()
{
    check_test targetok.xg "dependdeep" subset "SIMPLE1-OK" subset \
        "SIMPLE2-OK" subset "DEPENDTWO-OK" subset "DEPENDDEEP-OK"
}

function target_dependmore()
{
    check_test targetok.xg "dependmore" subset "SIMPLE1-OK" subset \
        "SIMPLE2-OK" subset "DEPENDTWO-OK" subset "DEPENDDEEP-OK" \
        subset "DEPENDMORE-OK"
}

function target_nameunderscore()
{
    check_test targetok.xg "name_underscore" subset "NAME_UNDERSCORE-OK"
}

function target_namecipher1()
{
    check_test targetok.xg "namecipher1" subset "NAMECIPHER1-OK"
}

function target_1namecipher()
{
    check_test targetok.xg "1namecipher" subset "1NAMECIPHER-OK"
}

function target_alwaysunchecked()
{
    check_test targetok.xg "alwaysunchecked" subset "ALWAYSUNCHECKED-OK"
}

function target_alwayschecked()
{
    check_test targetok.xg "alwayschecked" notsubset \
    "ALWAYSCHECKED-FAILED"
}

function target_dependalwayschecked()
{
    check_test targetok.xg "dependalwayschecked" notsubset \
    "ALWAYSCHECKED-FAILED" subset "DEPENDALWAYSCHECKED-OK" 
}

function target_withargument()
{
    check_test targetok.xg "withargument --arg=MF" subset "arg=MF" 
}

function target_withcomment()
{
    check_test targetok.xg "withcomment" subset "WITHCOMMENT-OK"
}

target=( simple manytargets dependone dependtwo dependdeep dependmore \
    nameunderscore namecipher1 1namecipher alwaysunchecked \
    alwayschecked dependalwayschecked withargument withcomment )
tests=( target )

if [[ -z "$1" ]]; then
    for part in "${tests[@]}"
    do
        eval array=\(\${${part}[@]} \)
        for test in "${array[@]}"
        do
            "$part"_"$test"
        done
    done
elif [[ -z "$2" ]]; then
    part="$1"
    eval array=\(\${${part}[@]} \)
    for test in "${array[@]}"
    do
        "$part"_"$test"
    done
else
    for test in ${@:2}
    do
        "$1"_"$test"
    done
fi

echo "Targets [$TESTS_OK/$TESTS_ALL]"
