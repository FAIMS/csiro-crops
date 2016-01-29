#!/bin/bash

cd module

# Disallow users from logging in with a blank dropdown
string="onClickLoginLogin () {"
replacement="onClickLoginLogin () {
  String val = getDropdownItemValue();
  if (isNull(val)) {
    String msgTitle = \"Cannot log in\";
    String msgBody  = \"A user must be selected in order to log in.\";
    showWarning(msgTitle, msgBody);
    return;
  }
"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make local records work with the search feature
string="String searchQuery = \"SELECT uuid, response \"+
                       \"  FROM latestNonDeletedArchEntFormattedIdentifiers  \"+
                       \" WHERE uuid in (SELECT uuid \"+
                       \"                  FROM latestNonDeletedArchEntIdentifiers \"+
                       \"                 WHERE measure LIKE '\"+term+\"'||'%'  \"+
                       \"                   AND ( aenttypename LIKE '\"+type+\"' OR '' = '\"+type+\"' ) \"+
                       \"                )  \"+
                       \" ORDER BY response \"+
                       \" LIMIT ? \"+
                       \"OFFSET ? \";"
replacement="String searchQuery = \"  SELECT uuid, response \"+
                       \"    FROM localRecord \"+
                       \"   WHERE response LIKE '\"+term+\"'||'%'  \"+
                       \"ORDER BY uuid DESC \"+
                       \"   LIMIT ? \"+
                       \"  OFFSET ? \";"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make local records work with autosaving
string="  saveTabGroup(\"Field\");"
replacement="  saveTabGroup(\"Field\", \"saveFieldCallback()\");"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make local records work with duplication
string="onSave(autosaveUuid, autosaveNewRecord) {
          setUuid(tabgroup, autosaveUuid);
        }"
replacement="onSave(autosaveUuid, autosaveNewRecord) {
          setUuid(tabgroup, autosaveUuid);
          saveFieldCallback();
        }"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make local records work with deletion
string="reallyDeleteField(){
  String tabgroup = \"Field\";"
replacement="reallyDeleteField(){
  String tabgroup = \"Field\";
  deleteFieldCallback();"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh


rm ui_logic.bsh.original
