#!/bin/sh

KEYS_PLIST=${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Keys.plist
SECRET_KEYS=~/.givenowkeys

if [ -f "${SECRET_KEYS}" ] && [ -f "${KEYS_PLIST}" ]; then
    source ${SECRET_KEYS}

    echo "### Found Keys.plist ###"

    # Production

    # ProdParseApplicationId
    /usr/libexec/PlistBuddy -c "Set :ProdParseApplicationId '${ProdParseApplicationId}'" "${KEYS_PLIST}"
    /usr/libexec/PlistBuddy -c "Print :ProdParseApplicationId" "${KEYS_PLIST}"

    # ProdParseClientKey
    /usr/libexec/PlistBuddy -c "Set :ProdParseClientKey '${ProdParseClientKey}'" "${KEYS_PLIST}"
    /usr/libexec/PlistBuddy -c "Print :ProdParseClientKey" "${KEYS_PLIST}"

    # Development

    # DevParseApplicationId
    /usr/libexec/PlistBuddy -c "Set :DevParseApplicationId '${DevParseApplicationId}'" "${KEYS_PLIST}"
    /usr/libexec/PlistBuddy -c "Print :DevParseApplicationId" "${KEYS_PLIST}"

    # DevParseClientKey
    /usr/libexec/PlistBuddy -c "Set :DevParseClientKey '${DevParseClientKey}'" "${KEYS_PLIST}"
    /usr/libexec/PlistBuddy -c "Print :DevParseClientKey" "${KEYS_PLIST}"

    # Universal

    # MapboxToken
    /usr/libexec/PlistBuddy -c "Set :MapboxToken '${MapboxToken}'" "${KEYS_PLIST}"
    /usr/libexec/PlistBuddy -c "Print :MapboxToken" "${KEYS_PLIST}"

else
    echo "### Unable to update Keys.plist ###"
fi
