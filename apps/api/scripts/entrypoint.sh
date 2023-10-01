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

# envの作成
app_key=`grep '^[[:space:]]*APP_KEY=' /var/www/${API_APP_NAME}/.env`
# jwt_key=`grep '^[[:space:]]*JWT_SECRET=' /var/www/${API_APP_NAME}/.env`

# google_id=`grep '^[[:space:]]*GOOGLE_CLIENT_ID=' /var/www/${API_APP_NAME}/.env`
# google_secret=`grep '^[[:space:]]*GOOGLE_CLIENT_SECRET=' /var/www/${API_APP_NAME}/.env`
# line_id=`grep '^[[:space:]]*LINE_CLIENT_ID=' /var/www/${API_APP_NAME}/.env`
# line_secret=`grep '^[[:space:]]*LINE_CLIENT_SECRET=' /var/www/${API_APP_NAME}/.env`

expand_variables /docker-init/env_templates/.env.template /var/www/${API_APP_NAME}/.env #それ以外を追記

echo ${app_key} >> /var/www/${API_APP_NAME}/.env # key保存

# echo ${jwt_key} >> /var/www/${API_APP_NAME}/.env # secretKey保存

# echo ${google_id} >> /var/www/${API_APP_NAME}/.env
# echo ${google_secret} >> /var/www/${API_APP_NAME}/.env

# echo ${line_id} >> /var/www/${API_APP_NAME}/.env
# echo ${line_secret} >> /var/www/${API_APP_NAME}/.env

# fpmの起動
sh -c "/usr/local/sbin/php-fpm"