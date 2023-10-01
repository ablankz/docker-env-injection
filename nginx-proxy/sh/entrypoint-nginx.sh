#!/bin/bash
# 環境変数を指定してテンプレートを展開する関数
expand_variables() {
    local content
    content=$(< "$1")  # テンプレートファイルの内容を読み込む
    
    # 環境変数を正規表現で検索し、対応する値で置き換える
    for var in $(compgen -A variable); do
        value="${!var}"  # 環境変数の値を取得
        content="${content//\$\{$var\}/$value}"  # 置換
    done
    echo "$content" > "$2"
}

expand_variables /etc/nginx/conf.d/templates/default.conf.template /etc/nginx/conf.d/default.conf
expand_variables /etc/nginx/conf.d/templates/domain_list.template /etc/nginx/conf.d/domain_list
sh -c "nginx -g 'daemon off;'"