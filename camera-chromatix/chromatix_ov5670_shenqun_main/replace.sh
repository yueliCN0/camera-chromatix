#!/bin/bash

################################################################################
# Name: repren.sh me: repren.sh
# Description:
#   按顺序做以下事情：
#   1. 查找特定类型的文件，如 .h、.cpp
#   2. 将文件内容中的文本 OLD_TEXT 替换成 NEW_TEXT
#   3. 将含 OLD_TEXT 的文件名重命名为 NEW_TEXT
#   4. 将含 OLD_TEXT 的目录名重命名为 NEW_TEXT
#
# Author:   Breaker <breaker.zy_AT_gmail>
# Date:     2011-10
################################################################################

# IFS 表示 for 语句中各项之间的分隔符
OLDIFS=$IFS
IFS=$'\n'   # $ 使字面量启动转义，否则 \n 为直接字面量而非 LF
SCRIPT_NAME=`basename "$0" `

# 用法
usage()
{
    echo "usage:"
        echo "  $SCRIPT_NAME OLD_TEXT NEW_TEXT"
	}

	if [ $# -lt 2 ]; then
	    usage
	        exit -1
		fi

		# 替换前后的 文本
		OLD_TEXT="$1"
		NEW_TEXT="$2"

		OLD_TEXT_UPPER=` echo $OLD_TEXT | tr '[a-z]' '[A-Z]' `     # 全大写的 旧文本
		OLD_TEXT_LOWER=` echo $OLD_TEXT | tr '[A-Z]' '[a-z]' `     # 全小写的 旧文本

		NEW_TEXT_UPPER=` echo $NEW_TEXT | tr '[a-z]' '[A-Z]' `     # 全大写的 新文本
		NEW_TEXT_LOWER=` echo $NEW_TEXT | tr '[A-Z]' '[a-z]' `     # 全小写的 新文本

		echo -e 'replace text & rename file ...\n'

		# 查找指定文件
		FIND_REGEX='.*(/(makefile|readme)|\.(h|hxx|hpp|c|cpp|cxx|txt|mak|rc|mk))'
		FILES=`find -type f -regextype posix-egrep -iregex "$FIND_REGEX" `

		# 文本替换时的 字符串边界
		#SED_REGEX='\(\b\|_\)'
		SED_REGEX='\(\b\|[0-9_]\)'
		#SED_REGEX='\(\b\|[0-9a-zA-Z_]\)'

		# 重命名时的 文件名边界
		#GREP_REGEX='(\b|_)'
		GREP_REGEX='(\b|[0-9_])'
		#GREP_REGEX='(\b|[0-9a-zA-Z_])'

		# 对每个查找到的文件去做...
		for EACH in $FILES
		do
	    # 替换文件中的文本 OLD_TEXT 为 NEW_TEXT
	        sed -i "s/$SED_REGEX$OLD_TEXT$SED_REGEX/\1$NEW_TEXT\2/g" $EACH
	    sed -i "s/$SED_REGEX$OLD_TEXT_UPPER$SED_REGEX/\1$NEW_TEXT_UPPER\2/g" $EACH
	        sed -i "s/$SED_REGEX$OLD_TEXT_LOWER$SED_REGEX/\1$NEW_TEXT_LOWER\2/g" $EACH
	    echo "$EACH: replace: $OLD_TEXT => $NEW_TEXT"

        # 重命名含 OLD_TEXT 的文件名为 NEW_TEXT
    OLD_FILE_0=`basename $EACH | grep -E -i "$GREP_REGEX$OLD_TEXT$GREP_REGEX" `    # 只针对文件名，不管目录部分
	        if [ "$OLD_FILE_0"!="" ]; then
	        DIR=`dirname $EACH `
        OLD_FILE="$DIR/$OLD_FILE_0"

       NEW_FILE_0=` echo "$OLD_FILE_0" | sed "s/$OLD_TEXT/$NEW_TEXT/gi" `
        NEW_FILE="$DIR/$NEW_FILE_0"

       mv "$OLD_FILE" "$NEW_FILE"
        echo "rename: $OLD_FILE => $NEW_FILE"
    fi

      echo ''
done

echo -e 'rename dir ...\n'

# 更改目录名：重命名含 OLD_TEXT 的目录名
DIRS=`find -type d `
for EACH in $DIRS; do
    OLD_DIR_0=`basename $EACH | grep -E -i "$GREP_REGEX$OLD_TEXT$GREP_REGEX" `
       if [ "$OLD_DIR_0"!="" ]; then
      OLD_DIR_DIR=`dirname $EACH `
       OLD_OLD_DIR="$OLD_DIR_DIR/$OLD_DIR_0"
       NEW_DIR_0=` echo "$OLD_DIR_0" | sed "s/$OLD_TEXT/$NEW_TEXT/gi" `
       NEW_DIR_DIR=` echo "$OLD_DIR_DIR" | sed "s/$OLD_TEXT/$NEW_TEXT/gi" `

																		        # find 先输出父目录，所以父目录这时已经重命名了
 # 所以 OLD_DIR 由新的父目录名和 OLD_DIR_0 拼成，而不是原来的 OLD_OLD_DIR 了
	  OLD_DIR="$NEW_DIR_DIR/$OLD_DIR_0" 
	  NEW_DIR="$NEW_DIR_DIR/$NEW_DIR_0"
        mv "$OLD_DIR" "$NEW_DIR"
       echo "rename: $OLD_OLD_DIR => $NEW_DIR"
       echo ''
       fi
done
																		    # 恢复环境
 IFS=$OLDIFS 
