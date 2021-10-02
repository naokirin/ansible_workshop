# Practice05: 変数を利用してみる

この演習では、変数を設定、利用してみます。

## 05-1 Playbookを開く

`server.yml` を開いてみましょう。

```yaml
---
- hosts: web
  become: yes
  tasks:
  - name: Create user
    user:
      name: "{{ item }}"
    with_items:
      - "{{ user_names }}"
```

これまでと異なり、 `{{ ... }}` と書かれている部分が出てきました。  
AnsibleではPlaybookやRoleにJinja2テンプレートを利用することができるようになっており、変数を利用することができます。

`with_items` は指定したリストの各要素ごとに、Taskを繰り返し実行することができます。  
その際に、要素が `item` に格納されるので、Taskでその変数を利用することができます。

それでは、 `user_names` 変数を指定してみましょう。

## 05-2 group_vars を確認してみる

前節でAnsibleでは変数を利用することができることを説明しました。  
しかし変数の値をどこで指定すべきでしょうか？

用途によって、Playbook、Inventory、Role、または group_vars、host_varsなどに記載できます。

一般的に、Playbookでは、 `vars` という項目に記載し、複数箇所で利用する値を使い回す目的で利用します。  
一方で、Roleでは、Role内での値の使い回しやパラメータのデフォルト値の指定などに利用します。

Inventory、group_vars、host_varsは、特定のホストや、グループ化したホストに対しての変数の値の指定を行います。

今回は演習ということで、group_varsで指定してみることにしましょう。

`group_vars/web` を開きましょう。

```yaml
---
ansible_user: ec2-user
ansible_ssh_private_key_file: /.ssh/ansible_workshop
# TODO: 変数を追加する
```

前回、`hosts` に書いてあった変数が、こちらに書かれています。  
前回はInventoryに記載していましたが、このように `group_vars` 以下のグループ名のファイルで指定することもできます。  

## 05-3 実際に書いてみる

それでは、変数の値を実際に書いてみましょう。

`group_vars/web` は拡張子がありませんが、YAMLです。  

`user_names` にリストで `test_user` 、 `foo_user` を指定してみてください。

## 05-4 Playbookを実行してみる

それでは、実際にPlaybookを実行してみましょう。

```sh
# practice05_vars のディレクトリに移動します
cd ./practice05_vars

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
失敗した場合はエラーの内容を確認して、修正してみましょう。  
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
cat /etc/passwd | grep foo_user
```

どうだったでしょうか？  
最後のコマンドで表示されれば、うまくユーザーが作成されているでしょう。

ここまでで、Practice05 は終わりになります。

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

それぞれのinspecの実行で成功したら、想定通りのユーザーが作成されています！

```
Profile: tests from tests (tests from tests)
Version: (not specified)
Target:  ssh://ec2-user@managed_node:22

  User test_user
     ✔  is expected to exist
  User foo_user
     ✔  is expected to exist

Test Summary: 2 successful, 0 failures, 0 skipped
```

## 追加でチャレンジ！

* 05-4で行ったPlaybookの実行をもう一度やってみましょう
  * 何回実行しても期待している状態になっているか確認してみましょう
* 変数名を変えてみましょう
* 変数をgroup_varsでなく、Playbookで指定してみましょう
  * Playbookでは、直接指定する方法以外にも、別のYAMLファイルに記載された変数を読み込むこともできます