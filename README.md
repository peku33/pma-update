Script for automatic update of phpMyAdmin
-----------------------------------------

**Requirements - basic linux commands**
* bash
* wget
* unzip
* mktemp

**Usage:**

 1. Download phpMyAdmin_Update.sh
 2. `chmod +x ./phpMyAdmin_Update.sh`
 3. `./phpMyAdmin_Update.sh <phpMyAdmin directory>`


This simple script will:

1. Download and unpack latest phpMyAdmin (zip) into temporary directory
2. Remove <phpMyAdmin directory>_old and rename <phpMyAdmin directory> to <phpMyAdmin directory>_old
3. Move downloaded phpMyAdmin to <phpMyAdmin directory>
4. Copy config.inc.php from <phpMyAdmin directory>_old to <phpMyAdmin directory>
5. Done