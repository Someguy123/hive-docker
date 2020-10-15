#!/usr/bin/env zsh
######################################################
#                         ##   Designed for ZSH.     #
# Date/Time Shell Helpers ##   Requires: curl, jq    #
#    by @someguy123       ##   May or may not work   #
# steemit.com/@someguy123 ##   with bash.            #
#                         ##   License: GNU AGPLv3   #
######################################################


_XDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${_XDIR}/core.sh"
SIAB_LIB_LOADED[rpclib]=1 # Mark this library script as loaded successfully

_XDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check that both SIAB_LIB_LOADED and SIAB_LIBS exist. If one of them is missing, then detect the folder where this
# script is located, and then source map_libs.sh using a relative path from this script.
array-exists() { declare -p "$1" &> /dev/null; }
{ ! array-exists SIAB_LIB_LOADED || ! array-exists SIAB_LIBS ; } && source "${_XDIR}/siab_libs.sh" || true
SIAB_LIB_LOADED[rpclib]=1 # Mark this library script as loaded successfully

# Returns the current UTC time in ISO/RFC format
#
#   $ rfc_datetime
#   2020-05-11T14:25:57
#
rfc_datetime() {
    TZ='UTC' date +'%Y-%m-%dT%H:%M:%S'
}
OS_NAME="$(uname -s)"

# date_to_seconds [date_time]
# Converts the first argument 'date_time' from a string date/time format, into
# standard integer UNIX time (epoch).
#
# For most reliable conversion, pass date/time in ISO format:
#       2020-02-28T20:08:09   (%Y-%m-%dT%H:%M:%S)
# e.g.
#   $ date_to_seconds "2020-02-28T20:08:09"
#   1582920489
#
date_to_seconds() {
    if [[ "$OS_NAME" == "Darwin" ]]; then
        date -j -f "%Y-%m-%dT%H:%M:%S" "$1" "+%s"
    else
        date -d "$1" '+%s'
    fi
}

# compare_dates [rfc_date_1] [rfc_date_2]
# Outputs the amount of seconds between date_2 and date_1
# 
# For most reliable conversion, pass date/time in ISO format:
#       2020-02-28T20:08:09   (%Y-%m-%dT%H:%M:%S)
#
# e.g.
#   $ compare_dates "2020-03-19T23:08:49" "2020-03-19T20:08:09"
#   10840
# means date_1 is 10,840 seconds in the future compared to date_2
#
compare_dates() {
    _compare_dates_usage() {
        msgerr cyan "Usage:${RESET} $0 [rfc_date_1] [rfc_date_2]\n"
        msgerr yellow "    Outputs the amount of seconds between date_2 and date_1"
        msgerr yellow "    For most reliable conversion, pass date/time in ISO format:\n"
        msgerr        "        2020-02-28T20:08:09   (%Y-%m-%dT%H:%M:%S)\n"

        msgerr bold blue "Examples:\n"
        msgerr cyan "   $ $0 '2020-05-11T14:42:03' '2020-05-11T14:25:57'"
        msgerr cyan "   966\n"
        msgerr cyan "   $ $0 '2020-05-11T14:42:03' '2020-05-01T10:15:21'"
        msgerr cyan "   880002\n"
        msgerr bold blue "Combine with the 'human-seconds' function to convert into days/hours/minutes etc.:\n"
        msgerr cyan "   $ human-seconds \$($0 '2020-05-11T14:42:03' '2020-05-01T10:15:21')"
        msgerr cyan "   10 day(s) + 4 hour(s) + 26 minute(s)\n"
    }

    if (( $# < 2 )); then msgerr bold red " [!!!] $0 expects TWO arguments"; _compare_dates_usage; return 1; fi
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then _compare_dates_usage; return 1; fi
    echo "$(($(date_to_seconds "$1")-$(date_to_seconds "$2")))"
}
compare-dates() { compare_dates "$@"; };

SECS_MIN=60
SECS_HR=$(( SECS_MIN * 60 ))
SECS_DAY=$(( SECS_HR * 24 ))
SECS_WK=$(( SECS_DAY * 7 ))
SECS_MON=$(( SECS_WK * 4 ))
SECS_YR=$(( SECS_DAY * 365 ))

# Separators between time units used by human_seconds
: ${REL_TIME_SEP=' + '}
: ${LAST_REL_TIME_SEP=' + '}

# Enable/disable time unit display / usage by human_seconds()
# by setting these env vars to 1 (enabled) or 0 (disabled)
: ${INC_MONTHS=1}
: ${INC_WEEKS=1}
: ${INC_DAYS=1}
: ${INC_HOURS=1}
: ${INC_MINUTES=1}
: ${INC_SECONDS=0}

# Alternative functionality for human_seconds when 2 args are passed
# Converts arg 1 'seconds' into a given time unit, e.g. 'hour'
_human_seconds_conv() {
    secs=$(( $1 ))
    case "$2" in
        m|M|min*|MIN*) _add_s minute "$(( secs / SECS_MIN ))";;
        h*|H*) _add_s hour "$(( secs / SECS_HR ))";;
        d|D|day*|DAY*) _add_s day "$(( secs / SECS_DAY ))";;
        w|W|we*|WE*) _add_s week "$(( secs / SECS_WK ))";;
        mon*|MON*) _add_s month "$(( secs / SECS_MON ))";;
        y*|Y*) _add_s year "$(( secs / SECS_YR ))";;
        *)
            msgerr bold red "Invalid unit '$2'\n"
            msgerr yellow "Valid units are: m(inute) h(our) d(ay) w(eek) mon(th) y(ear)"
            msgerr yellow "e.g. '$0 $secs min' or '$0 $secs h'\n"
            _human_seconds_usage
            return 1
            ;;
    esac
    return 0
}

# small helper function to plurify a unit if num isn't 1
# _add_s minute 1    # outputs: 1 minute
# _add_s minute 5    # outputs: 5 minutes
# _add_s hour 0      # outputs: 0 hours
_add_s() {
    local word="$1" num=$(( $2 ))
    (( num == 1 )) && echo "1 $word" || echo "$num ${word}s"
}

# Usage / help text for human_seconds()
_human_seconds_usage() {
    msgerr cyan "Usage:${RESET} human_seconds [seconds] (unit)\n"
    msgerr bold cyan "    (Also aliased to 'human-seconds')\n"
    msgerr yellow "    Converts integer seconds into relative human time. \n"

    msgerr bold blue "Basic examples:\n"
    msgerr red  "   \$${RESET} human_seconds 70"
    msgerr cyan "   1 minute + 10 seconds\n"
    msgerr red  "   \$${RESET} human_seconds 4000"
    msgerr cyan "   1 hour + 6 minutes\n"
    msgerr red  "   \$${RESET} human_seconds 60000000"
    msgerr cyan "   1 year + 11 months + 3 weeks + 10 hours + 40 minutes\n"

    msgerr bold blue "Convert 'seconds' directly into another unit (returns rounded integer):\n"
    msgerr red  "   \$${RESET} human_seconds 60000000 mon"
    msgerr cyan "   24 months\n"
    msgerr red  "   \$${RESET} human_seconds 60000000 day"
    msgerr cyan "   694 days\n"

    msgerr bold blue "Environment Variables for additional customisation:\n"

    msgerr yellow "   The env var 'REL_TIME_SEP' (default '${REL_TIME_SEP}') controls the separator used for all but the last"
    msgerr yellow "   time unit (normally seconds or minutes)\n"
    msgerr yellow "   The env var 'LAST_REL_TIME_SEP' (default '${LAST_REL_TIME_SEP}') controls the separator used to join the LAST"
    msgerr yellow "   time unit used (normally seconds or minutes)\n"

    msgerr red  "   \$${RESET} REL_TIME_SEP=', ' LAST_REL_TIME_SEP=' and ' human_seconds 60000000"
    msgerr cyan "   1 year + 11 months + 3 weeks + 10 hours + 40 minutes\n"
    msgerr red  "   \$${RESET} REL_TIME_SEP=' / ' LAST_REL_TIME_SEP=' & ' human_seconds 1200000"
    msgerr cyan "   1 week / 6 days / 21 hours & 20 minutes\n"

    msgerr yellow "   The env variables INC_SECONDS, INC_MINUTES, INC_HOURS, INC_DAYS, INC_WEEKS, and INC_MONTHS can be used"
    msgerr yellow "   to control the display of smaller time units when handling large time periods."
    msgerr yellow "   All of the INC_ envs default to 1, other than INC_SECONDS which defaults to 0 (disabled)\n"
    msgerr yellow "   NOTE: INC_WEEKS is a special case, when INC_WEEKS is disabled (set to 0), weeks will be completely disabled"
    msgerr yellow "         and will not be used as part of the calculations. \n"
    msgerr cyan   "    - INC_SECONDS (def: 0)    ${BOLD}1 = always show seconds,        0 = show seconds only if time period is < 60 mins\n"
    msgerr cyan   "    - INC_MINUTES (def: 1)    ${BOLD}1 = always show minutes,        0 = show minutes only if time period is < 24 hours\n"
    msgerr cyan   "    - INC_HOURS (def: 1)      ${BOLD}1 = always show hours,          0 = show hours only if time period is < 7 days\n"
    msgerr cyan   "    - INC_DAYS (def: 1)       ${BOLD}1 = always show days,           0 = show days only if time period is < 28 days\n"
    msgerr cyan   "    - INC_WEEKS (def: 1)      ${BOLD}1 = enable week(s) time unit    0 = disable use of week(s) entirely. days goes up to 28 instead of 7\n"

    msgerr red    "   \$${RESET} human_seconds 4002161"
    msgerr cyan   "   1 month + 2 weeks + 4 days + 7 hours + 42 minutes\n"
    msgerr bold cyan   "   # With INC_WEEKS=0, you can see that the 2 weeks + 4 days were flattened into 18 days."
    msgerr red    "   \$${RESET} INC_WEEKS=0 human_seconds 4002161"
    msgerr cyan   "   1 month + 18 days + 7 hours + 42 minutes\n"

    msgerr bold cyan   "   # By default INC_SECONDS is 0, which causes 'x seconds' to be truncated for times longer than 59 minutes"
    msgerr red    "   \$${RESET} human_seconds 620"
    msgerr cyan   "   10 minutes + 20 seconds\n"
    msgerr red    "   \$${RESET} human_seconds 6020"
    msgerr cyan   "   1 hour + 40 minutes\n"
    msgerr bold cyan   "   # If we change INC_SECONDS to 1, 'x seconds' will always be displayed, no matter how long the time period is."
    msgerr red    "   \$${RESET} INC_SECONDS=1 human_seconds 6020"
    msgerr cyan   "   1 hour + 40 minutes + 20 seconds\n"
}

# human_seconds [seconds]
# convert an amount of seconds into a humanized time (minutes, hours, days)
#
# human_seconds 60      # output: 1 minute(s)
# human_seconds 4000    # output: 1 hour(s) and 6 minute(s)
# human_seconds 90500   # output: 1 day(s) + 1 hour(s) + 8 minute(s)
#
human_seconds() {

    if (( $# < 1 )); then msgerr bold red " [!!!] $0 expects at least ONE argument"; _human_seconds_usage; return 1; fi
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then _human_seconds_usage; return 1; fi

    # Prevent weird quirks from leftover vars by blanking some of them.
    local secs="" mins="" hrs="" days="" m=""
    
    secs=$(( $1 ))
    # local rem_secs rem_mins rem_hrs m
    local mod_yrs mod_mons mod_wks mod_days mod_hrs mod_mins
    local rem_yrs rem_mons rem_wks rem_days rem_hrs rem_mins rem_secs
    local day_brkpt
    # Modulo the seconds against the amount of seconds in a year, a month, a week etc.
    # So we can determine the remainder seconds for each time unit
    mod_yrs=$(( secs % SECS_YR )) mod_mons=$(( mod_yrs % SECS_MON )) 
    # If weeks are disabled, mod_wks should just point to the month modulo
    (( INC_WEEKS )) && mod_wks=$(( mod_mons % SECS_WK )) || mod_wks="$mod_mons"
    mod_days=$(( mod_wks % SECS_DAY )) mod_hrs=$(( mod_days % SECS_HR )) mod_mins=$(( mod_hrs % SECS_MIN ))

    rem_yrs=$(( secs / SECS_YR )) rem_mons=$(( mod_yrs / SECS_MON ))
    # If weeks are disabled, rem_wks should just be 0.
    (( INC_WEEKS )) && rem_wks=$(( mod_mons / SECS_WK )) || rem_wks="0"
    rem_days=$(( mod_wks / SECS_DAY )) rem_hrs=$(( mod_days / SECS_HR )) rem_mins=$(( mod_hrs / SECS_MIN ))
    rem_secs="$mod_mins"

    # If a 2nd arg is specified, we're converting the passed seconds directly into another
    # time unit, e.g. days, weeks, months, minutes etc.
    if (( $# > 1 )); then
        _human_seconds_conv "$@"
        return $?
    fi

    # If weeks are enabled, days can only go up to 7 days before rolling over into 1 week
    # If weeks are disabled, days go up to 28 days instead (1 month = 4 weeks = 28 days)
    (( INC_WEEKS )) && day_brkpt="$SECS_WK" || day_brkpt="$SECS_MON"

    if (( secs < SECS_MIN )); then       # less than 1 minute
        m="$secs seconds"
    elif (( secs < SECS_HR )); then     # less than 1 hour
        mins=$(( secs / SECS_MIN ))
        m=$(_add_s minute $mins)
    elif (( secs < SECS_DAY )); then    # less than 1 day
        hrs=$(( secs / SECS_HR )) 
        m=$(_add_s hour $hrs)
    elif (( secs < day_brkpt )); then
        days=$(( secs / SECS_DAY ))
        m=$(_add_s day $days)
    elif (( INC_WEEKS )) && (( secs < SECS_MON )); then
        weeks=$(( secs / SECS_WK ))
        m=$(_add_s week $weeks)
    elif (( secs < SECS_YR )); then
        months=$(( secs / SECS_MON )) 
        m=$(_add_s month $months)
    else
        years=$(( secs / SECS_YR )) 
        m=$(_add_s year $years)
    fi
    # (( INC_MONTHS )) && (( secs > SECS_YR )) && (( rem_mons > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s month $rem_mons)"
    { (( INC_MONTHS )) || (( secs < SECS_YR )); } && (( secs > SECS_YR )) && (( rem_mons > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s month $rem_mons)"
    # (( INC_WEEKS )) && (( secs > SECS_MON )) && (( rem_wks > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s week $rem_wks)"
    # { (( INC_WEEKS )) || (( secs < SECS_YR )); } && (( secs > SECS_MON )) && (( rem_wks > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s week $rem_wks)"

    if (( INC_WEEKS )); then
        { (( INC_WEEKS )) || (( secs < SECS_YR )); } && (( secs > SECS_MON )) && (( rem_wks > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s week $rem_wks)"
    fi
    # (( INC_DAYS )) && (( secs > SECS_WK )) && (( rem_days > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s day $rem_days)"
    { (( INC_DAYS )) || (( secs < SECS_MON )); } && (( secs > day_brkpt )) && (( rem_days > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s day $rem_days)"

    # (( INC_HOURS )) && (( secs > SECS_DAY )) && (( rem_hrs > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s hour $rem_hrs)"

    { (( INC_HOURS )) || (( secs < SECS_WK )); } && (( secs > SECS_DAY )) && (( rem_hrs > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s hour $rem_hrs)"

    # ! (( INC_HOURS )) && (( secs > SECS_DAY )) && (( secs < SECS_MON )) && (( rem_hrs > 0 )) && m="${m}${REL_TIME_SEP}$(_add_s hour $rem_hrs)"
    # (( secs > SECS_HR )) && (( rem_mins > 0 )) && m="${m}${REL_TIME_SEP}$rem_mins minute(s)"
    # (( INC_MINUTES )) && (( secs > SECS_HR )) && (( rem_mins > 0 )) && m="${m}${LAST_REL_TIME_SEP}$(_add_s minute $rem_mins)"
    { (( INC_MINUTES )) || (( secs < SECS_DAY )); } && (( secs > SECS_HR )) && (( rem_mins > 0 )) && m="${m}${LAST_REL_TIME_SEP}$(_add_s minute $rem_mins)"
    # ! (( INC_MINUTES )) && (( secs > SECS_HR )) && (( secs < SECS_WK )) && (( rem_mins > 0 )) && m="${m}${LAST_REL_TIME_SEP}$(_add_s minute $rem_mins)"
    { (( INC_SECONDS )) || (( secs < SECS_HR )); } && (( secs > SECS_MIN )) && (( rem_secs > 0 )) && m="${m}${LAST_REL_TIME_SEP}$(_add_s second $rem_secs)"

    # if (( INC_SECONDS )); then
    #     (( secs > SECS_MIN )) && (( secs < SECS_HR )) && m="${m}${LAST_REL_TIME_SEP}$(_add_s second $rem_secs)"
    # else    
    #     (( secs > SECS_MIN )) && (( secs < SECS_HR )) && m="${m}${LAST_REL_TIME_SEP}$(_add_s second $rem_secs)"
    # fi

    echo "$m"
}

human-seconds() { human_seconds "$@"; };

######################################################
#                         ##   Designed for ZSH.     #
# Steem RPC Shell Helpers ##   Requires: curl, jq    #
#    by @someguy123       ##   May or may not work   #
# steemit.com/@someguy123 ##   with bash.            #
#                         ##   License: GNU AGPLv3   #
######################################################


# The default RPC node to use for rpc-rq
# hived.privex.io is a load balancer operated
# by @privex (Privex Inc.)
: ${DEFAULT_STM_RPC="https://hived.privex.io"}
export DEFAULT_STM_RPC
export LAST_STM_NODE
# [ -z ${LAST_STM_NODE+x} ] && export LAST_STM_NODE="$DEFAULT_STM_RPC"
# : ${LAST_STM_NODE="$DEFAULT_STM_RPC"}

export RPC_HOST="$DEFAULT_STM_RPC" RPC_PARAMS="[]" RPC_METHOD=""

: ${RPC_VERBOSE=0}

# _verb_msg [is_verbose] [msg_args...]
# Calls 'msgerr' with msg_args if is_verbose is non-zero or 'y'
# which outputs a coloured message to stderr
_verb_msg() {
    local is_verbose="$1"
    shift
    if (( is_verbose )) || [[ "$is_verbose" == "y" ]]; then
        >&2 msg "$@"
    fi
}

_rpc-rq-argparse() {
    export RPC_HOST="$DEFAULT_STM_RPC"
    RPC_PARAMS="[]"
    _verb_msg "$vrb" blue " [DEBUG] _rpc-rq-argparse arguments: $*"
    if [[ "$#" -eq 1 ]]; then
        export RPC_METHOD="$1"
        _verb_msg "$vrb" blue " [DEBUG] One argument detected. Using DEFAULT_STM_RPC (${RPC_HOST}) as HOST, " \
                              "default parameters '${RPC_PARAMS}', and 1st argument '${RPC_METHOD}' as the RPC method. "
    # if 2 arg, check if first param is a url
    elif [[ "$#" -eq 2 ]]; then
        # if url, then 1 = host, 2 = method, params = default
        if egrep -q "http(s)?://" <<< "$1"; then
            export RPC_HOST="$1" RPC_METHOD="$2"
            _verb_msg "$vrb" blue " [DEBUG] Two arguments detected. First argument is valid URL - using 1st arg as host '${RPC_HOST}'. " \
                                  "Using 2nd argument '${RPC_METHOD}' as the RPC method. Using default parameters '${RPC_PARAMS}'"
        # if not a url, then 1 = method, 2 = params, host = default
        else
            export RPC_METHOD="$1" RPC_PARAMS="$2"
            _verb_msg "$vrb" blue " [DEBUG] Two arguments detected. First argument not a valid URL - using DEFAULT_STM_RPC as host '${RPC_HOST}'. " \
                                  "Using 1st arg '${RPC_METHOD}' as the RPC method. Using 2nd arg for parameters '${RPC_PARAMS}'"
        fi
    # if all 3 args, 1 = host, 2 = method, 3 = params
    elif [[ "$#" -eq 3 ]]; then
        export RPC_HOST="$1" RPC_METHOD="$2" RPC_PARAMS="$3"
        _verb_msg "$vrb" blue " [DEBUG] Three arguments detected. Not using any defaults - only user args."
        _verb_msg "$vrb" blue " [DEBUG] Using 1st as host '${RPC_HOST}'. Using 2nd arg '${RPC_METHOD}' as the RPC method. Using 3rd arg for parameters '${RPC_PARAMS}'"
    fi
    export LAST_STM_NODE="$HOST"
    export RPC_HOST RPC_METHOD RPC_PARAMS
    echo "$RPC_HOST"
    echo "$RPC_METHOD"
    echo "$RPC_PARAMS"
}

: ${CURL_BIN="curl"}

#####
# Helper function to perform a query against a STEEM RPC (see https://www.steem.io)
# Used by all of the other functions, e.g. rpc-get-time, rpc-get-block
# As this is used by the other functions, it's recommended to pipe into jq if using alone
# 
# === USAGE ===
#
# $ rpc-rq get_dynamic_global_properties
# Single arg: host=default, method=$1, params=[]
#
# $ rpc-rq https://steemd.privex.io get_dynamic_global_properties
# $ rpc-rq get_dynamic_global_properties '[]'
# Two args: Detects if first arg is host.
#   If host: host=$1, method=$2, params=[]
#   If not:  host=default, method=$1, params=$2
# 
# $ rpc-rq https://steemd.privex.io get_dynamic_global_properties '[]'
# Three args: host=$1 method=$2 params=$3
#
#####
rpc-rq() {
    local vrb=0
    (( RPC_VERBOSE )) && vrb=1
    if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
        vrb=1
        shift
    fi

    if [[ "$#" -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "
=== USAGE ===
 Current default RPC: $DEFAULT_STM_RPC
 $ rpc-rq get_dynamic_global_properties
 Single arg: host=default, method=\$1, params=[]

 $ rpc-rq https://hived.privex.io get_dynamic_global_properties
 $ rpc-rq get_dynamic_global_properties '[]'
 Two args: Detects if first arg is host.
   If host: host=\$1, method=\$2, params=[]
   If not:  host=default, method=\$1, params=\$2
 
 $ rpc-rq https://hived.privex.io get_dynamic_global_properties '[]'
 Three args: host=\$1 method=\$2 params=\$3
"
        return 1
    fi

    _rpc-rq-argparse "$@" > /dev/null
    local HOST="$RPC_HOST" METHOD="$RPC_METHOD" PARAMS="$RPC_PARAMS"
    local data="{\"jsonrpc\": \"2.0\", \"method\": \"$METHOD\", \"params\": $PARAMS, \"id\": 1 }"
    export LAST_STM_NODE="$HOST"
    # export LAST_STM_NODE
    _verb_msg "$vrb" yellow "Querying RPC node ${HOST} using method '${METHOD}' and parameters '${PARAMS}'"
    _verb_msg "$vrb" cyan "POST data: ${BOLD}${data}"
    # s = silent, S = show errors when silent, f = fail silently and return error code 22 on error
    #_c_args=($CURL_BIN)

    if (( vrb )); then
        _c_args=("-v" "--data" "$data" "$HOST")
        eval $CURL_BIN "${_c_args[@]@Q}"
        #eval "\$CURL_BIN \$(printf \"'%s' \" \"\${_c_args[@]}\")"
        #env '$CURL_BIN -v --data "$data" "$HOST"'
        return $?
    else
        _c_args=("-sSf" "--data" "$data" "$HOST")
        eval $CURL_BIN "${_c_args[@]@Q}"
        #eval "\$CURL_BIN \$(printf \"'%s' \" \"\${_c_args[@]}\")"
        #eval '$CURL_BIN -s -S -f --data "$data" "$HOST"'
        return $?
    fi
}

#####
# Queries an RPC server for the last block time.
# Useful for checking if a node is out of sync
#
# $ rpc-get-time https://steemd.privex.io
#    "2018-10-05T19:07:03"
#
#####
rpc-get-time() {

    if (( $# > 0 )) && { [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; }; then
        msgerr cyan "Usage: $0 (host)\n"
        msgerr yellow "    Returns the head block for a given RPC node."
        msgerr yellow "    If 'host' isn't specified, it will fallback to DEFAULT_STM_RPC (current value: '${DEFAULT_STM_RPC}')"
        msgerr
        return 1
    fi

    (( $# > 0 )) && [[ "$1" == "-v" || "$1" == "--verbose" ]] && RPC_VERBOSE=1
    local q_cmd="condenser_api.get_dynamic_global_properties" ret
    _rpc-cmd-wrapper "$q_cmd" '[]' '.result.time' "$@"
    ret="$?"
    #RPC_VERBOSE=0
    return $ret
}


#####
# rpc-get-block (host)
#   Queries an RPC server for the last block number.
#   Useful for checking if a node is out of sync
#
# rpc-get-block (host) [block_num]
#   Retrieves the contents of 'block_num'. 
#
# $ rpc-get-block
#    26549337
# $ rpc-get-block https://steemd.privex.io
#    26549337
# $ rpc-get-block 12341234
#    {
#       "previous": "00bc4ff1e4700955d3fcf14fff15bbb63a6ab76e",
#       "timestamp": "2017-05-29T02:46:30", "witness": "anyx",
#       "transaction_merkle_root": "6615362495dfd5018ea8999840557248f3118380",
#       "extensions": [], "witness_signature": "1f62ea225501b4a9...",
#       "transactions": [
#           { "ref_block_num": 20464, ... },
#        ]
#    }
#
# $ rpc-get-block https://hived.hive-engine.com 12341234
#    (same as previous, but gets the block contents from RPC node https://hived.hive-engine.com instead of DEFAULT_STM_RPC)
#
#####
rpc-get-block() {
    local c ret q_cmd="condenser_api.get_dynamic_global_properties" j_query=".result.head_block_number"
    local q_host="${DEFAULT_STM_RPC}"

    if (( $# > 0 )) && { [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; }; then
        msgerr cyan "Usage: $0 (host)\n"
        msgerr yellow "    Returns the head block for a given RPC node."
        msgerr yellow "    If 'host' isn't specified, it will fallback to DEFAULT_STM_RPC (current value: '${DEFAULT_STM_RPC}')\n"
        msgerr bold magenta "Examples\n"
        msgerr magenta "    $ rpc-get-block https://steemd.privex.io"
        msgerr magenta "    43282919"
        msgerr magenta "    $ rpc-get-block https://hived.privex.io"
        msgerr magenta "    43309827\n"

        msgerr cyan "Usage: $0 (host) [block_num]\n"
        msgerr yellow  "    Retrieves the contents of 'block_num'. Optionally specify an RPC node URL before the block number"
        msgerr yellow  "    to call get_block against that RPC node instead of DEFAULT_STM_RPC"
        msgerr 
        msgerr bold magenta "Examples\n"
        msgerr magenta '    $ rpc-get-block 12341234'
        msgerr magenta '    {'
        msgerr magenta '        "previous": "00bc4ff1e4700955d3fcf14fff15bbb63a6ab76e",'
        msgerr magenta '        "timestamp": "2017-05-29T02:46:30", "witness": "anyx",'
        msgerr magenta '        "transaction_merkle_root": "6615362495dfd5018ea8999840557248f3118380",'
        msgerr magenta '        "extensions": [], "witness_signature": "1f62ea225501b4a9...",'
        msgerr magenta '        "transactions": ['
        msgerr magenta '            { "ref_block_num": 20464, ... },'
        msgerr magenta '        ]'
        msgerr magenta "    }\n"
        msgerr magenta '    $ rpc-get-block https://hived.hive-engine.com 12341234'
        msgerr magenta '    (same as previous, but gets the block contents from RPC node https://hived.hive-engine.com instead of DEFAULT_STM_RPC)'
        msgerr
        return 1
    fi

    (( $# > 0 )) && [[ "$1" == "-v" || "$1" == "--verbose" ]] && RPC_VERBOSE=1 && shift
    _args=()

    (( $# > 0 )) && _args+=("$@")
    for ((i=0;i<${#_args[@]};i++)); do
        _verb_msg "$RPC_VERBOSE" yellow " [rpc-get-block] Arg ${i}: ${_args[$i]}"
    done
    local params="[]"

    _argcount=${#_args[@]} 
    if (( _argcount > 0 )); then
        if ! egrep -q '^http' <<< "${_args[0]}" && (( _args[0] > 0 )); then
            params="[${_args[0]}]" q_cmd="condenser_api.get_block" j_query=".result"
            _verb_msg "$RPC_VERBOSE" yellow " [rpc-get-block] Argument 1 > 0: ${_args[0]}"
        else
            q_host="${_args[0]}"
            if (( _argcount > 1 )) && ! egrep -q '^http' <<< "${_args[1]}" && (( _args[1] > 0 )); then
                _verb_msg "$RPC_VERBOSE" yellow " [rpc-get-block] Argument 2 > 0: ${_args[1]}"
                params="[${_args[1]}]" q_cmd="condenser_api.get_block" j_query=".result"
            fi
        fi
    fi
    _verb_msg "$RPC_VERBOSE" yellow " [rpc-get-block] Host: ${q_host} Params: ${params} CMD: ${q_cmd} Query: ${j_query}"

    _rpc-cmd-wrapper "$q_cmd" "$params" "$j_query" "$q_host"
    ret=$?
    #RPC_VERBOSE=0
    return $ret
}

: ${USE_JQ_RAW=1}

[ -z ${JQ_PARAMS+x} ] && JQ_PARAMS=()
[ -z ${_JQ_PARAMS+x} ] && _JQ_PARAMS=()

# hasElement [element] [array_name]
#
#   $ myray=(hello world)
#   $ hasElement hello myray && echo "true" || echo "false"
#   true
#   $ hasElement orange myray && echo "true" || echo "false"
#   false
#   $ hasElement world myray && echo "true" || echo "false"
#   true
#
# (zsh version)  orig source: https://unix.stackexchange.com/a/411307/166253
# (bash version) orig source: https://stackoverflow.com/a/15394738/2648583
hasElement() {
    local param_el="$1" array_name="$2"

    eval '[[ " ${'$array_name'[@]} " =~ " '$param_el' " ]]'
}

# _jq-hasparam [item]
# Returns truthy if JQ_PARAMS contains $1
#   $ JQ_PARAMS=('-r')
#   $ _jq-hasparam '-r' && echo "true" || echo "false"
#   true
#   $ _jq-hasparam '-k' && echo "true" || echo "false"
#   false
#
_jq-hasparam() {
    local param_el="$1" array_name="JQ_PARAMS"
    (( $# > 1 )) && array_name="$2"
    hasElement "$param_el" "$array_name"
}

_jq-call() {
    _JQ_PARAMS=("${JQ_PARAMS[@]}")

    if (( USE_JQ_RAW )); then
        _verb_msg "$RPC_VERBOSE" bold cyan " [-jq_call] USE_JQ_RAW is enabled"

        _jq-hasparam -r _JQ_PARAMS || _JQ_PARAMS+=(-r)
    fi
    if (( $# < 1 )); then
        msgerr red " [!!!] _jq-call expects at least 1 param!"
        return 1
    fi

    local jqr="." data=""
    (( $# > 0 )) && jqr="$1"
    (( $# > 1 )) && data="$2"
    _JQ_PARAMS+=("$jqr")

    _verb_msg "$RPC_VERBOSE" bold cyan " [-jq_call] _JQ_PARAMS = ${_JQ_PARAMS[*]}"
    if [[ -z "$data" ]]; then
        _verb_msg "$RPC_VERBOSE" bold cyan " [-jq_call] \$data was empty. calling jq without feeding data (use pipe?)"
        jq "${_JQ_PARAMS[@]}"
        ret=$?
    else
        _verb_msg "$RPC_VERBOSE" bold cyan " [-jq_call] \$data is not empty. feeding in JSON data: $data"
        jq "${_JQ_PARAMS[@]}" <<< "$data"
        ret=$?
    fi
    
    _JQ_PARAMS=()
    return $ret
}

# _rpc-cmd-wrapper rpc_method rpc_params jq_query [rpc-rq params...]
# example:
#   _rpc-cmd-wrapper condenser_api.get_version '[]' '.result.blockchain_version' https://hived.privex.io
_rpc-cmd-wrapper() {
    local rpcverbose=0
    (( $# > 0 )) && [[ "$1" == "-v" || "$1" == "--verbose" ]] && rpcverbose=1 && RPC_VERBOSE=1 && shift
    local q_cmd="$1" q_params="$2" jq_query="$3"
    shift; shift; shift;

    (( $# > 0 )) && [[ "$1" == "-v" || "$1" == "--verbose" ]] && rpcverbose=1 && RPC_VERBOSE=1

    local _cm_args
    _cm_args=()
    (( $# > 0 )) && _cm_args+=("$@")
    _cm_args+=("$q_cmd" "$q_params")
    _rpc-rq-argparse "${_cm_args[@]}" &> /dev/null
    c=$(rpc-rq "${_cm_args[@]}")
    ret=$?
    if (( ret )); then
        msgerr bold red "\nGot non-zero return code from cURL (code: $ret). RPC node '${LAST_STM_NODE}' is dead?\n"
        msgerr red "Error result from server:\n"
        echo "$c"
        return $ret
    else
        err_msg=$(jq -r ".error.message" <<< "$c")
        if [[ "$err_msg" != "null" && "$err_msg" != "false" ]]; then
            msgerr bold red " [!!!] The server '${LAST_STM_NODE}' returned an error while querying method '${q_cmd}'!"
            msgerr bold red " [!!!] The RPC node ${LAST_STM_NODE} may be malfunctioning, or an invalid method / parameters were specified.\n"
            msgerr yellow "Error message from server:\n"
            msgerr "\t${err_msg}\n\n"
            return 1
        fi
        _verb_msg "$rpcverbose" bold cyan "Extracted ${jq_query} from ${q_cmd} (via '${LAST_STM_NODE}'):"
        _jq-call "$jq_query" "$c"
        ret="$?"

        if (( ret )); then
            msgerr bold red "\n [!!!] Got non-zero return code from jq (code: $ret). Failed to decode JSON?"
            msgerr bold red " [!!!] The RPC node ${LAST_STM_NODE} may be malfunctioning, or an invalid method / parameters were specified.\n"
            # return $ret
        fi
    fi
    return $ret
}

rpc-get-version() {
    _rpc-cmd-wrapper condenser_api.get_version '[]' '.result.blockchain_version' "$@"
    #RPC_VERBOSE=0
}

#####
# Queries an RPC server for all dynamic properties
# If node not specified, uses DEFAULT_STM_RPC
# $ rpc-get-all-dynamic https://steemd.privex.io
# {
#  "head_block_number": 26549358,
#  "head_block_id": "01951c6e21f05808c1180ff05783a4890372f934",
#  "time": "2018-10-05T19:09:24",
#  "current_witness": "someguy123",
#  "total_pow": 514415,
#  ...
# }
#
#####
rpc-get-all-dynamic() {
    (( $# > 0 )) && [[ "$1" == "-v" || "$1" == "--verbose" ]] && RPC_VERBOSE=1
    local c ret q_cmd="condenser_api.get_dynamic_global_properties"

    _rpc-cmd-wrapper condenser_api.get_dynamic_global_properties '[]' '.result' "$@"
    #RPC_VERBOSE=0
}

rpc-health() {
    local q_host="$DEFAULT_STM_RPC"
    (( $# > 0 )) && [[ "$1" == "-v" || "$1" == "--verbose" ]] && export RPC_VERBOSE=1 && shift

    (( $# > 0 )) && q_host="$1"

    #local h_ver h_time h_block h_time_compare h_time_secs t_now

    h_ver="$(rpc-get-version "$q_host")"
    h_time="$(rpc-get-time "$q_host")"
    h_block="$(rpc-get-block "$q_host")"
    t_now="$(rfc_datetime)"
    h_time_secs="$(compare-dates "$t_now" "$h_time")"
    h_time_compare="$(human-seconds "$h_time_secs")"
    {
        msg bold cyan "Host:\t${GREEN}${q_host}"
        msg bold cyan "Running Version:\t${GREEN}${h_ver}"
        msg bold cyan "Head Block:\t${GREEN}${h_block}"
        msg bold cyan "Block Time:\t${GREEN}${h_time}\t(${h_time_compare} ago)\t(${h_time_secs} seconds)"
    } | column -t -s $'\t'
    msg
}

