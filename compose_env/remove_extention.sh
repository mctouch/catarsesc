 find ./ -name "*.sample" -exec sh -c 'mv $0 `basename "$0" .sample`' '{}' \;
