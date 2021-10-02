# Practice03: Roleを作成、利用してみよう

この演習では、TaskのまとまりをRoleにして利用してみます。

## 03-1 PlaybookとRoleを開く

これまで同様、まずはPlaybookを開いてみましょう。  
今回もPlaybookは `server.yml` です。

```yaml
---
- hosts: web
  become: yes
  roles:
    - nginx
```

今回は、`tasks` ではなく、`roles` になっています。
Roleを利用する場合は `roles` 以下に設定をしていくことになるため、今回は `roles` を記載しています。

今回はPlaybookには、TODOがありません。  
今回の演習では、nginxのRoleが利用できるようにしてもらいます。

nginxのRoleは `roles/nginx` にあります。  
Roleを作成する場合は、 `roles` ディレクトリ以下にRole名のディレクトリを作成し、規定のディレクトリを作っていきます。

今回は必要なディレクトリ、ファイルについては、すでに配置済みです。  
自分で作成する場合には、ドキュメントを参照してください。  
[Ansible Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

```
roles/nginx
┗ handlers
  ┗ main.yml
┗ tasks
  ┗ main.yml
┗ templates
  ┗ nginx.conf
```

以降では、それぞれのTODOを解決していきましょう。

## 03-2 Roleの tasks/main.yml を見てみる

Roleで実際に実行されるTaskを記載しているのは `roles/nginx/tasks/main.yml` になります。  
そのため、まずはこちらを確認してみましょう。

nginxユーザーの作成、およびAmazon Linux 2 特有のnginxパッケージの有効化については、すでに記載されています。

`# === 演習ではこれ以降の設定を行います ===` の部分以降を見てください。

```
- name: Install nginx
  # TODO: yumモジュールで、nginxをインストールする
  #         * キャッシュをアップデートするようにする

- name: Set nginx.conf
  # TODO: templateモジュールで、`templates/nginx.conf` を `/etc/nginx/nginx.conf` に配置する
  #         * 変更があったら、nginxがリスタートされるようにする（Hint: notifyを利用する）
  #         * ファイルのパーミッションを0644にする

- name: Enable nginx service
  # TODO: serviceモジュールで、nginxサービスを有効化する

- name: Start nginx
  # TODO: serviceモジュールで、nginxサービスをstartedにする
```

これまで通り、TODOを確認して設定を書いてみてください。

今回利用するモジュールもansible.builtin名前空間にあるので、そこからドキュメント探してみましょう。  
https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html

このうち、まだ紹介していないものに、 `notify` の利用があるのでこちらだけ次節で紹介します。

## 03-3 handlerを利用しよう

Roleでは、Handlerで、特定のTaskで変更があった際にのみ実行する操作を定義できます。  
今回は、Handlerを利用して、nginxの設定ファイルに変更があった場合、nginxを再起動して設定ファイルが再読み込みされるようにしたいと思います。

すでに、nginxを再起動するHandlerは準備済みです。  
`roles/nginx/handlers/main.yml` を見てみましょう。

```yaml
---
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

ここでは、 `Restart nginx` という名前のHandlerを定義しています。  
このHandlerでは、serviceモジュールを利用して、nginxを再起動しています。

このHandlerは、Taskに `notify` で指定することで、そのTaskで変更があった場合にのみ、**Roleの最後に実行されます**。  
また、同じRole内で複数回呼ばれても、1回のRoleの実行で1回のみ実行されます。

最後に簡単にnotifyの記載の仕方の例を示します。

```yaml
- name: Example notify
  debug:
    msg: notify!
  changed_when: yes
  notify: Restart nginx  # このTaskで変更があったら、 `Restart nginx` のHandlerを呼び出す
```

## 03-4 実際に書いてみる

ここまでで、RoleのTODOの部分を書く準備が整いました。  
`roles/nginx/tasks/main.yml` の `TODO` の部分に記載された条件を満たすように記載してください。

## 03-5 Playbookを実行してみる

それでは、実際にPlaybookを実行してみましょう。

これまで通り、dockerコンテナ内に入って、実行してみましょう。

```sh
# practice03_use_role のディレクトリに移動します
cd ./practice03_use_role

# コンテナをビルドしておく
docker-compose build

# Ansibleを実行するコンテナと、管理対象にするコンテナを実行します
docker-compose up -d

# Ansibleを実行するコンテナに入ります
docker-compose exec control_node bash

# AnsibleでPlaybookを実行します（Volumeが設定されているので、コンテナ内でも編集した設定ファイルが利用可能です）
ansible-playbook server.yml -i hosts
```

うまく実行できたでしょうか？  
失敗した場合はエラーの内容を確認して、Playbookを修正してみましょう。  
また一度環境をリセットしたい場合は、コンテナを作成し直してみましょう。

```sh
# コンテナを再作成する
docker-compose up --force-recreate -d

# Ansibleを実行するコンテナに入りなおす
docker-compose exec control_node bash
```

成功した場合は一度Ansible実行用のコンテナから抜けて、管理対象のコンテナに入ってみましょう。

```sh
# exitコマンドでAnsible実行用のコンテナから抜ける
exit

# 管理対象のコンテナに入る
docker-compose exec managed_node bash

# nginxがインストールできているか確認する
yum list installed nginx

# nginxが起動しているか確認する
systemctl status nginx
```

どうだったでしょうか？  
想定通りにnginxがインストール、起動ができているでしょうか？

ここまでで、Practice03 は終わりになります。

最後にdockerコンテナを終了しておきましょう（以降の内容を実行する場合は、それらを実行後に行ってください）。

```
docker-compose down --rmi local
```

## 補足: InSpecで正しくユーザーが作られているかチェックする

演習では事前に用意されたInSpecを用いて、正しく構築ができているかテストすることができます。  
すでにAnsibleを実行するコンテナにはInSpecがインストールされています。

InSpecの実行ファイルは現在、Chef Lisenceで提供されているため、実行の前に一度目を通しておいてください。  
[Chef EULA](https://www.chef.io/end-user-license-agreement)

上記を確認の上で、正しくユーザー作成できているか検証したい方は、以下を実行してみてください。

```sh
docker-compose exec control_node bash

inspec exec tests --config ./tests/config.json
```

成功したら、想定通りに実行できています！

```
Profile: tests from tests (tests from tests)
Version: (not specified)
Target:  ssh://ec2-user@managed_node:22

  User nginx
     ✔  is expected to exist
  System Package nginx
     ✔  is expected to be installed
  Service nginx
     ✔  is expected to be installed
     ✔  is expected to be enabled
     ✔  is expected to be running
  File /etc/nginx/nginx.conf
     ✔  is expected to exist
     ✔  content is expected to match /# サンプル用のnginx.conf/

Test Summary: 7 successful, 0 failures, 0 skipped
```

## 追加でチャレンジ！

* 03-5で行ったPlaybookの実行をもう一度やってみましょう
  * 何回実行しても期待している状態になっているか確認してみましょう
  * nginxの再起動が実行されていないことも確認してみましょう
* nginx.confにコメントを追加して、Handlerが実行されることを確認してみましょう
  * nginx.confに `# コメント` を1行追加して、Playbookを再度実行してみましょう
* 自分でRoleを作成してみましょう
  * `test` グループに所属する、`test_user` ユーザーを作成するRoleを作成してみましょう
  