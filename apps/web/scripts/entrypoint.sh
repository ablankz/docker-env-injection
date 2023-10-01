#!/bin/bash
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

# envの作成
expand_variables /docker-init/env_templates/.env.local.template /usr/src/app/.env.local #それ以外を追記

sh -c "npm install && npm run dev"