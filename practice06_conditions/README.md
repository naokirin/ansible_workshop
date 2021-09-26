# Practice06: 条件を利用してみる

この演習では、変数への保持と条件判定を利用してみます。

## 06-1 利用の仕方を見てみる

Practice03(`practice03_use_role`)で、Roleに以下のような記述があったことを覚えているでしょうか？  
`practice03_use_role/roles/nginx/tasks/main.yml` を開いて確認してみましょう。

```yaml
# nginxのパッケージが有効になっているかチェックする
- name: Check nginx1 package
  ansible.builtin.shell: "amazon-linux-extras list | grep nginx | grep enabled"
  register: nginx1_enabled_result
  changed_when: no
  ignore_errors: yes

# Amazon Linux 2 で nginx をyumインストールできるようにする
- name: Enable to install nginx
  ansible.builtin.command: "amazon-linux-extras enable nginx1"
  when: nginx1_enabled_result.rc == 1
```

ここで `Check nginx1 package` では `register` はコマンドの実行結果を保持する変数を指定しています。  
その後、 `Enable to install nginx` では、 `when` で変数の値をもとに、Taskを実行するかを判定しています。

`register` で保持できる値はモジュールごとに決まっており、モジュールのドキュメントの Return Values に記載されています。

## 06-2 実際に書いてみよう

それでは `server.yml` を開きましょう。

```yaml
---
- hosts: web
  become: yes
  tasks:
  - name: Check to exist file
    shell: "ls /tmp | grep -e /tmp/test_file"
    register:  # TODO: 変数を指定しよう
    changed_when: no
    ignore_errors: yes

  - name: Create file if not exist
    command: "touch /tmp/test_file"
    when: # TODO: すでにファイルがあったら何もしないようにしよう
```

2箇所にTODOがあるので、これらを解決しましょう。

## 06-3 Playbookを実行してみる

それでは、実際にPlaybookを実行してみましょう。

```sh
# practice06_conditions のディレクトリに移動します
cd ./practice06_conditions

# コンテナをビルドしておく
docker-compose build

# Ansibleを実行するコンテナと、管理対象にするコンテナを実行します
docker-compose up -d

# Ansibleを実行するコンテナに入ります
docker-compose exec control_node bash

# AnsibleでPlaybookを実行します
ansible-playbook server.yml -i hosts
```

うまく実行できたでしょうか？  
失敗した場合はエラーの内容を確認して、Playbookを修正してみましょう。  
今回は、ここでもう一度 `ansible-playbook` コマンドを実行してみましょう。

```
ansible-playbook server.yml -i hosts
```

今回は `changed` が出なかったでしょうか？  
`changed` が出ていたら、正しく動いていないかもしれません。  
条件部分を確認してみましょう。

成功した場合は一度Ansible実行用のコンテナから抜けて、管理対象のコンテナに入ってみましょう。

```sh
# exitコマンドでAnsible実行用のコンテナから抜ける
exit

# 管理対象のコンテナに入る
docker-compose exec managed_node bash

# ファイルができているか確認する
ls /tmp
```

どうだったでしょうか？  
想定通りにファイルが作成できているでしょうか？

ここまでで、Practice06 は終わりになります。

最後にdockerコンテナを終了しておきましょう（以降の内容を実行する場合は、それらを実行後に行ってください）。

```
docker-compose down
```

## 補足: InSpecで正しくファイルが作られているかチェックする

演習では事前に用意されたInSpecを用いて、正しく構築ができているかテストすることができます。  
すでにAnsibleを実行するコンテナにはInSpecがインストールされています。

InSpecの実行ファイルは現在、Chef Lisenceで提供されているため、実行の前に一度目を通しておいてください。  
[Chef EULA](https://www.chef.io/end-user-license-agreement)

上記を確認の上で、正しくファイル作成できているか検証したい方は、以下を実行してみてください。

```sh
docker-compose exec control_node bash

inspec exec tests --config ./tests/config.json
```

成功したら、想定通りに実行できています！

```
Profile: tests from tests (tests from tests)
Version: (not specified)
Target:  ssh://ec2-user@managed_node:22

  File /tmp/test_file
     ✔  is expected to exist

Test Summary: 1 successful, 0 failures, 0 skipped
```
