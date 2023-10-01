# docker compose の env を一元管理する

## 作成できる環境

- react と laravel による簡易的な web サイトの土台
- プロキシには nginx、rdb には postgres を使用

## プロジェクトのクローン

```sh
git clone https://github.com/ablankz/docker-env-injection.git
```

## hosts ファイルの追記

- local で名前解決してくれるように、hosts に使用予定のドメインを記述
- 今回は作成するプロジェクトを`myproject`、api のプロジェクト名は`myproject-api`、web のプロジェクト名は`myproject-web`とする
- また使用するドメインは、web フロントを`myproject.com`、api サーバーを`api.myproject.com`とする
- この場合の hosts ファイルに追記する内容は以下のようになる
  ```hosts
  127.0.0.1        myproject.com
  127.0.0.1        api.myproject.com
  ```

## api サーバーのプロジェクト作成

- `apps/api`まで移動した後、以下のコマンドでプロジェクトを作成する
- `myproject-api`の部分は先程決めたapiのプロジェクト名が入る
  ```sh
  composer create-project laravel/laravel --prefer-dist myproject-api
  ```

## webサーバーのプロジェクト作成
- `apps/web`まで移動した後、以下のコマンドでプロジェクトを作成する
- projectが聞かれたときに先程決めたwebのプロジェクト名を入力する
- 他の設定は基本的には以下のような設定で良さそう
  ```sh
  npm create vite
  Need to install the following packages:
  create-vite@4.4.1
  Ok to proceed? (y) y
  ✔ Project name: … myproject-web
  ✔ Select a framework: › React
  ✔ Select a variant: › TypeScript + SWC

  Scaffolding project in /home/blank/docker-env-injection/apps/web/myproject-web...

  Done. Now run:

    cd myproject-web
    npm install
    npm run dev
  ```
- ターミナルにも書いてくれてるコマンドを実行する(`npm run dev`は今はいらない)
  ```sh
  cd myproject-web
  npm install
  ```
- `apps/web/myproject-web/vite.config.ts`を以下のように書き換える(docker内でhotreloadを解決するため)
  ```ts
  import { defineConfig } from 'vite'
  import react from '@vitejs/plugin-react-swc'

  // https://vitejs.dev/config/
  export default defineConfig({
    plugins: [react()],
    server: {
      host: true,
      watch: {
        usePolling: true,
      },
      hmr: {
        path: "_vite/ws-hmr",
      },
    },
  })
  ```

## envファイルの記載

- プロジェクト直下の`.env`にコメント記述通りの設定を記載していく

## コンテナの立ち上げ

```sh
docker compose up -d
```

## 失敗した時（もしくはコンテナが立ち上がらない時）
- 大抵の場合はwebやapiの作成したプロジェクト名と`.env`で設定したプロジェクト名が異なったり、`hosts`で設定したドメインと`.env`で記述したドメインが異なるなどだと思う
- 以下のような感じのエラーが出た場合
  ```sh
  Error response from daemon: error while mounting volume '/var/lib/docker/volumes/docker-env-injection_node_modules/_data': failed to mount local volume: mount /path/to/project/apps/web/myproject-web/node_modules:/var/lib/docker/volumes/docker-env-injection_node_modules/_data, flags: 0x1000: no such file or directory
  ```
- `.env`の`APP_ROOT_PATH`の記述ミスだと思うが、このエラーになるとdockerがvolumeを記憶させてしまうらしく、通常は`.env`を修正後、`docker compose down`した後、`docker compose up -d`をすると良い(`docker compose restart`でも良い)のだが、この場合は一度以下のコマンドでvolumeも削除してから再度startを行うこと(もちろん`.env`の修正を行ったあとで)
  ```sh
  docker compose down --volumes --remove-orphans
  ```

## 注意点

- コンテナすべてに.envに記載した設定情報が環境変数として組み込まれる
  - もともと開発環境のために作った構成なので、本番環境では使用しない
  - もしくは`api.env`や`web.env`など、設定ファイルを分けて`envfile`の指定にそれぞれ設定すれば良いが、これだとそれぞれの設定ファイルを記述するのと変わらない気がする😅
- 例えば、laravelのenvファイルを変更した際、そのコンテナが立ち上がっている際はその設定が保たれるが、一度落とすと`.env.template`の設定に合わせて`.env`の内容が消えるので注意
  - laravelの`APP_KEY`など残したい設定がある場合は`apps/api/scripts/entrypoint.sh`にて以下のように記述する
  ```
  ...
  app_key=`grep '^[[:space:]]*APP_KEY=' /var/www/${API_APP_NAME}/.env` # APP_KEYの値をapp_keyに保存

  expand_variables /docker-init/env_templates/.env.template /var/www/${API_APP_NAME}/.env # templateを元に環境変数を埋め込み追記

  echo ${app_key} >> /var/www/${API_APP_NAME}/.env # keyを後から追記
  ...
  ```
- postgresサーバーなどdocker内のネットワークで閉じているのでコンテナの外だとから`php artisan migrate:fresh`などデータベースアクセスコマンドが失敗する
  - portをコンテナ外部に出した後、laravelの設定テンプレートのdb_hostやdb_portをコンテナ内部から外に出たものに変更する
  - もしくは毎回、コンテナ内に入ってから実行する、僕は以下のようなスクリプトを作成して簡単にartisanコマンドを実行できるようにしている
  ```container-artisan.sh
  #!/bin/bash
  args=("$@")
  docker compose exec api php artisan "${args[@]}"
  sudo chmod -R a+w ./database
  sudo chmod -R a+w ./app
  sudo chmod -R a+w ./config
  sudo chmod -R a+w ./tests
  ```
  - `./container-artisan migrate:fresh`のように使用できる 
