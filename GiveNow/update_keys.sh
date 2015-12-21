#!/bin/sh

KEYS_PLIST=${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Keys.plist
SECRET_KEYS=~/.givenowkeys

if [ -f "${SECRET_KEYS}" ] && [ -f "${KEYS_PLIST}" ]; then
    source ${SECRET_KEYS}

    echo "### Found Keys.plist ###"

    # ParseApplicationId
    /usr/libexec/PlistBuddy -c "Set :ParseApplicationId '${ParseApplicationId}'" "${KEYS_PLIST}"
    /usr/libexec/PlistBuddy -c "Print :ParseApplicationId" "${KEYS_PLIST}"

    # ParseClientKey
    /usr/libexec/PlistBuddy -c "Set :ParseClientKey '${ParseClientKey}'" "${KEYS_PLIST}"
    /usr/libexec/PlistBuddy -c "Print :ParseClientKey" "${KEYS_PLIST}"

    # MapboxToken
    /usr/libexec/PlistBuddy -c "Set :MapboxToken '${MapboxToken}'" "${KEYS_PLIST}"
    /usr/libexec/PlistBuddy -c "Print :MapboxToken" "${KEYS_PLIST}"

else
    echo "### Unable to update Keys.plist ###"
fi
