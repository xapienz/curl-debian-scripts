#!/bin/bash
# use like:
# cd lib && find . -name '*.c' -exec ../debian/make_openssl3_symbols.sh ../debian/libcurl4.symbols {} \;

syms_file=$1
source_file=$2
curl3_syms_header="// curl3 symbols go below:"

if grep -q "$curl3_syms_header" "$source_file"; then
	exit 1
fi

allowed_symbols_list=$(cat $syms_file | sed -rn 's/curl_(\w*)@.*$/\1/p')
general_symbols=$(cat $source_file | sed -rn 's/^\w* [\*]{0,1}curl_(\w*)\(.*$/\1/p')
struct_symbols=$(cat $source_file | sed -rn 's/^struct \w* [\*]{0,1}curl_(\w*)\(.*$/\1/p')
found_symbols=$(echo -e "$general_symbols\n$struct_symbols" | sort | uniq)
symbols=""

for found_sym in $found_symbols; do
	for allowed_sym in $allowed_symbols_list; do
		if [[ $found_sym = $allowed_sym ]]; then
			symbols=$symbols" "$found_sym
		fi
	done
done

if [[ ! -z "$symbols" ]]; then
	echo "$curl3_syms_header"  >> "$source_file"
	echo '#ifdef USE_OPENSSL' >> "$source_file"
	for sym in $symbols; do
		echo '__asm__(".symver curl3_'$sym',curl_'$sym'@CURL_OPENSSL_3");' >> "$source_file"
		echo 'void curl3_'$sym'(void) __attribute__ ((weak, alias ("curl_'$sym'")));' >> "$source_file"
	done
	echo '#endif' >> "$source_file"
fi
