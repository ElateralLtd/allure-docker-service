#!/bin/bash

EXEC_STORE_RESULTS_PROCESS=$1
PROJECT_ID=$2

# USED FROM API
ORIGIN=$3
EXECUTION_NAME=$4
EXECUTION_FROM=$5
EXECUTION_TYPE=$6

PROJECT_REPORTS=$STATIC_CONTENT_PROJECTS/$PROJECT_ID/reports
if [ "$(ls $PROJECT_REPORTS | wc -l)" != "0" ]; then
    if [ -e "$PROJECT_REPORTS/latest" ]; then
        LAST_REPORT_PATH_DIRECTORY=$(ls -td $PROJECT_REPORTS/* | grep -v latest | grep -v $EMAILABLE_REPORT_FILE_NAME | head -1)
    else
        LAST_REPORT_PATH_DIRECTORY="$PROJECT_REPORTS/0"
    fi
fi

LAST_REPORT_DIRECTORY=$(basename -- "$LAST_REPORT_PATH_DIRECTORY")
#echo "LAST REPORT DIRECTORY >> $LAST_REPORT_DIRECTORY"

RESULTS_DIRECTORY=$STATIC_CONTENT_PROJECTS/$PROJECT_ID/results
if [ ! -d "$RESULTS_DIRECTORY" ]; then
    echo "Creating results directory for PROJECT_ID: $PROJECT_ID"
    mkdir -p $RESULTS_DIRECTORY
fi

EXECUTOR_PATH=$RESULTS_DIRECTORY/$EXECUTOR_FILENAME

echo "Creating $EXECUTOR_FILENAME for PROJECT_ID: $PROJECT_ID"
if [[ "$LAST_REPORT_DIRECTORY" != "latest" ]]; then
    BUILD_ORDER=$(($LAST_REPORT_DIRECTORY + 1))

    if [ -z "$EXECUTION_NAME" ]; then
        EXECUTION_NAME='Automatic Execution'
    fi

    if [ -z "$EXECUTION_TYPE" ]; then
        EXECUTION_TYPE='another'
    fi

EXECUTOR_JSON=$(cat <<EOF
{
    "reportName": "$PROJECT_ID",
    "buildName": "$PROJECT_ID #$BUILD_ORDER",
    "buildOrder": "$BUILD_ORDER",
    "name": "$EXECUTION_NAME",
    "reportUrl": "../$BUILD_ORDER/index.html",
    "buildUrl": "$EXECUTION_FROM",
    "type": "$EXECUTION_TYPE"
}
EOF
)
    if [[ "$EXEC_STORE_RESULTS_PROCESS" == "1" ]]; then
        echo $EXECUTOR_JSON > $EXECUTOR_PATH
    else
        echo '' > $EXECUTOR_PATH
    fi
else
    echo '' > $EXECUTOR_PATH
fi

echo "Generating report for PROJECT_ID: $PROJECT_ID"
echo "Results directory is: $RESULTS_DIRECTORY"
allure generate --clean $RESULTS_DIRECTORY -o $STATIC_CONTENT_PROJECTS/$PROJECT_ID/reports/$BUILD_ORDER
echo "BUILD_ORDER:$BUILD_ORDER"
