# Practice04: インベントリを編集してみる

この演習では、インベントリを編集してみます。

## 04-1 インベントリを開いてみる

これまで、`hosts` ファイルや、Playbookの `hosts` の項目については詳細を説明してきませんでした。

これらは、Playbookを適用するホストを指定したり、ホストをグループ化するために利用します。  
この `hosts` ファイルをインベントリと呼びます。

インベントリは、INI形式で複数の管理ノードやホストを指定できます。  
またそれらをまとめて、グループ化することができ、そのグループ名をPlaybookで指定することもできます。

以下の例では、`web_server` というグループに、`dev.example.com`、`prod.example.com`  
`database_server` というグループに、`dev_db.example.com`、`prod_db.example.com` が含まれるようにしています。

```ini
[web_server]
dev.example.com
prod.example.com

[database_server]
dev_db.example.com
prod_db.example.com
```

インベントリには、`hosts` 以外の他の名前をつけることもでき、 `ansible-playbook` コマンドで `-i` でファイル名を指定することで利用できます。

## 04-2 実際に書いてみる

それでは `hosts` を開いてみましょう。

```ini
[web:vars]
ansible_user = 'ec2-user'
ansible_ssh_private_key_file = '/.ssh/ansible_workshop'

[web]
# TODO: ホストを追加してみましょう
```

`[web:vars]` では `web` グループのホストに対する変数を指定できます。  
実は、いままでの演習で、Ansibleでのssh接続をするユーザーやssh鍵をコマンドで指定しなくてよかったのは、インベントリで指定がしてあったためです。

さて、`[web]` の部分にTODOが記載されています。  

TODOの部分をこれまでの演習の `hosts` を参考にして、以下のホストを追加してみてください。

* `managed_host`
* `managed_host2`

## 04-3 Playbookを実行してみる

それでは、実際にPlaybookを実行してみましょう。

今回はDockerコンテナ内から実行するため、Dockerコンテナに入って実行します。

Playbookは以下のようにして実行しましょう。

```sh
# practice04_inventory のディレクトリに移動します
cd ./practice04_inventory

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
失敗した場合はエラーの内容を確認して修正してみましょう。  
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

# ユーザーが作成されているか確認する
cat /etc/passwd | grep test_user
```

どうだったでしょうか？  
最後のコマンドで表示されれば、うまくユーザーが作成されているでしょう。

ここまでで、Practice04 は終わりになります。

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

inspec exec tests --config ./tests/config.json --target ssh://managed_node
inspec exec tests --config ./tests/config.json --target ssh://managed_node2
```

それぞれのinspecの実行で成功したら、想定通りのユーザーが作成されています！

```
Profile: tests from tests (tests from tests)
Version: (not specified)
Target:  ssh://ec2-user@managed_node:22

  User test_user
     ✔  is expected to exist

Test Summary: 1 successful, 0 failures, 0 skipped
```

## 追加でチャレンジ！

* 04-3で行ったPlaybookの実行をもう一度やってみましょう
  * 何回実行しても期待している状態になっているか確認してみましょう
* ホストのグループ名を `web` から `webserver` に変えてみましょう
  * ※ インベントリの `[web:vars]` 、Playbookの `hosts` を書き換えるのも忘れないようにしましょう
* インベントリについてのドキュメントを読んでみましょう
  * [Ansible Inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)