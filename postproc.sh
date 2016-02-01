#!/bin/bash

cd module

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
                       \"   WHERE response LIKE '%'||'\"+term+\"'||'%'  \"+
                       \"ORDER BY uuid DESC \"+
                       \"   LIMIT ? \"+
                       \"  OFFSET ? \";"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make local records work with autosaving
string="  saveTabGroup(\"Field\");"
replacement="  saveTabGroup(\"Field\", \"saveFieldCallback(); saveFieldGeometry()\");"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make local records work with duplication
string="onSave(autosaveUuid, autosaveNewRecord) {
          setUuid(tabgroup, autosaveUuid);
        }"
replacement="onSave(autosaveUuid, autosaveNewRecord) {
          setUuid(tabgroup, autosaveUuid);
          saveFieldCallback();
          saveFieldGeometry();
        }"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make local records work with deletion
string="reallyDeleteField(){
  String tabgroup = \"Field\";"
replacement="reallyDeleteField(){
  String tabgroup = \"Field\";
  deleteFieldCallback();"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make module unpack geometry into globals on Field load
string="loadFieldFrom(String uuid) {
  String tabgroup = \"Field\";
  setUuid(tabgroup, uuid);
  if (isNull(uuid)) return;

  showTabGroup(tabgroup, uuid);
}"
replacement="loadFieldFrom(String uuid) {
  String tabgroup = \"Field\";
  setUuid(tabgroup, uuid);
  if (isNull(uuid)) return;

  showTabGroup(tabgroup, uuid, onLoadField);
}"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

# Make module save geometry correctly
string="List    geometry        = null;"
replacement="List    geometry        = packFieldGeometry();"
perl -0777 -i.original -pe "s/\\Q$string/$replacement/igs" ui_logic.bsh

rm ui_logic.bsh.original
