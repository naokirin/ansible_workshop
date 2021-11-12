# Practice02: ファイルを作成・編集してみよう

この演習では、環境構築でよく行うファイルの作成・編集をAnsibleで行ってみましょう。

## 02-1 Playbookを開く

前回同様、まずはPlaybookを開いてみましょう。  
今回もPlaybookは `server.yml` です。

以下のようになっているでしょう。

```yaml
---
- hosts: web
  become: yes  # sudoで実行する
  tasks:
  - name: Create test_user
    ...略...
  
  - name: Create /home/test_user/test_dir directory
    # TODO: fileモジュールでディレクトリを作成する
    #         パス: /home/test_user/test_dir
    #         パーミッション: 0755

  - name: Add line `export HOST_ENV_NAME=dev` in bashrc for test_user
    # TODO: lineinfileモジュールでファイルを変更する
    #         /home/test_user/.bashrc に `export HOST_ENV_NAME=dev` を追加する
    #         すでにHOST_ENV_NAMEがexportされている場合は `export HOST_ENV_NAME=dev` になるようにする
```

以降では、それぞれのTODOを解決していきましょう。

## 02-2 fileモジュールを見てみよう

まずは、ファイルやディレクトリの作成、削除、モードの変更などを行うためのfileモジュールです。

fileモジュールは、ansible.builtin名前空間にあるので、そこからドキュメント探してみましょう。  
https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html

## 02-3 lineinfileモジュールを見てみよう

次に、lineinfileモジュールです。  
lineinfileモジュールは、ファイルに行を追加や削除、またはファイル内の行を編集する際に使います。

設定ファイルなどに設定を追加する際に、Ansibleを実行するたびに行が増えていくと困るでしょう。  
lineinfileモジュールは、対象の行を正規表現などで指定することができます。

こちらもドキュメントを探してみましょう。  
https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html

## 02-4 実際に書いてみる

ここまでで、PlaybookのTODOの部分を書く準備が整いました。  
`server.yml` の `TODO` の部分に記載された条件を満たすように記載してください。

## 02-5 Playbookを実行してみる

それでは、実際にPlaybookを実行してみましょう。

今回はDockerコンテナ内から実行するため、Dockerコンテナに入って実行します。

Playbookは以下のようにして実行しましょう。

```sh
# practice02_create_and_edit_files のディレクトリに移動します
cd ./practice02_create_and_edit_files

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

# test_userになる
su -- test_user

# /home/test_user 以下を確認してみる
ls -l /home/test_user

# /home/test_user/.bashrc を確認してみる
cat /home/test_user/.bashrc
```

どうだったでしょうか？  
想定通りにディレクトリの作成、ファイルの変更ができているでしょうか？

ここまでで、Practice02 は終わりになります。

最後にdockerコンテナを終了しておきましょう（以降の内容を実行する場合は、それらを実行後に行ってください）。

```
docker-compose down --rmi local
```

## 補足: InSpecで正しくファイルが作成、編集されているかチェックする

演習では事前に用意されたInSpecを用いて、正しく構築ができているかテストすることができます。  
すでにAnsibleを実行するコンテナにはInSpecがインストールされています。

InSpecの実行ファイルは現在、Chef Lisenceで提供されているため、実行の前に一度目を通しておいてください。  
[Chef EULA](https://www.chef.io/end-user-license-agreement)

上記を確認の上で、正しくファイルを作成、編集できているか検証したい方は、以下を実行してみてください。

```sh
docker-compose exec control_node bash

inspec exec tests --config ./tests/config.json
```

成功したら、想定通りに実行できています！

```
Profile: tests from tests (tests from tests)
Version: (not specified)
Target:  ssh://ec2-user@managed_node:22

  User test_user
     ✔  is expected to exist
     ✔  shell is expected to eq "/bin/bash"
  Directory /home/test_user/test_dir
     ✔  is expected to exist
     ✔  mode is expected to cmp == "0755"
  File /home/test_user/.bashrc
     ✔  is expected to exist
     ✔  content is expected to match /export HOST_ENV_NAME=dev/

Test Summary: 6 successful, 0 failures, 0 skipped
```

## 追加でチャレンジ！

* 02-5で行ったPlaybookの実行をもう一度やってみましょう
  * 何回実行しても期待している状態になっているか確認してみましょう
* ファイルを削除してみましょう
  * 作成した `/home/test_user/test_dir` をPlaybookの最後で削除するようにしてみましょう
* blockinfile モジュールを使ってみよう
  * lineinfileモジュールと似たモジュールである、blockinfileモジュールを使ってみましょう
  * blockinfileは単一行ではなく、複数行をまとめて操作できます
