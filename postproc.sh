#!/bin/bash

cd module

string=     "  String searchQuery = \"SELECT uuid, response \"+
                       \"  FROM latestNonDeletedArchEntFormattedIdentifiers"
replacement="  String searchQuery = \"SELECT uuid, text \"+
                       \"  FROM localRecords"
perl -0777 -i.original -pe 's/$string/$replacement/igs' ui_logic.bsh


string=     "  saveTabGroup(\"Field\");"
replacement="  saveTabGroup(\"Field\", \"saveFieldCallback()\");"
perl -0777 -i.original -pe 's/$string/$replacement/igs' ui_logic.bsh


rm ui_logic.bsh.original
