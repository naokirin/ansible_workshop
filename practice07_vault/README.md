# Practice07: Vaultを利用してみる

この演習では、機密データを暗号化して扱えるAnsible Vaultを利用してみます。

## 07-1 利用の仕方を知る

今回はAnsible Vaultを利用してみます。

サーバー構築などのインフラ環境構築では、機密データを扱うことが多々あります。  
ただし、平文で機密データを扱っていると、どこで漏れるかわかりません。  
また平文のままでは、バージョン管理システムなど不特定多数の目に触れるような場所にはそのまま追加することができず、せっかくAnsibleを用いてInfrastructure as Codeを行おうとしても、中途半端になってしまいます。

このような場面で、Ansible Vaultを利用することで、暗号化された状態で機密データをファイルに保存、Ansible実行時に復号化するということができます。

Ansible Vaultの利用は、基本的には `ansible-vault` コマンドを利用します。  
以下によく使うサブコマンドをまとめておきます。

| 種別     | サブコマンド   | 内容                             | 
| -------- | -------------- | -------------------------------- | 
| 文字列   | encrypt_string | 指定された文字列を暗号化         | 
| ファイル | encrypt        | 指定されたファイルを暗号化       | 
| ファイル | create         | 暗号化ファイルを作成             | 
| ファイル | view           | 暗号化ファイルを閲覧             | 
| ファイル | edit           | 暗号化ファイルを編集             | 
| ファイル | rekey          | 暗号化ファイルのパスワードを変更 | 

### 利用の手順

Ansible Vaultの基本的な手順は以下になります

1. `ansible-vault` コマンドでパスワードを指定して機密データを暗号化する
2. 暗号化された機密データを利用するTask、もしくはRoleをPlaybookに記載する
3. `ansible-playbook` コマンドに `--ask-vault-pass` を指定して、実行時に復号化する

## 07-2 実際に暗号化してみる

今回、ファイル暗号化と変数レベルの暗号化の両方を試してみましょう。

ファイル暗号化は、既存のファイルを `ansible-vault encrypt` で暗号化、もしくは `ansible-vault create` で作成するパターンです。  
一方で変数レベルの暗号化は、変数に指定する文字列を `ansible-vault encrypt_string` で暗号化したものを利用するパターンです。

### ファイル暗号化を行ってみる

それでは、`templates` ディレクトリに、暗号化された `credential` というファイルを作成してみましょう。  

まずはコマンドが実行できるように、Dockerコンテナを起動しましょう。

```sh
# コンテナをビルドしておく
docker-compose build

# practice07_vaultのディレクトリに移動する
cd practice07_vault

# Dockerコンテナを起動する
docker-compose up -d

# Ansibleを実行するコンテナに入る
docker-compose exec control_node bash
```

`ansible-vault create ./templates/credential` で作成できます。  
パスワードを聞かれると思いますが、好きなもので結構です（当たり前ですが、忘れないでください）。

今回、中身は `CREDENTIAL_FILE` としましょう。

### 変数レベルの暗号化を行ってみる

次は変数レベルの暗号化です。

ファイル暗号化ではなく、変数レベルの暗号化を利用する利点は、暗号化する必要のないファイル内の文字列を暗号化せずに済むことです。  
一方で、暗号化の単位が細切れになり、管理が難しくなりやすい欠点もあります。

今回は `secret_string` という文字列を暗号化してみましょう。  
`ansible-vault encrypt_string secret_string` で暗号化できます。  
ここで、パスワードはファイル暗号化の際と同じものにしてください。理由はPlaybookで指定するパスワードを1つとするためです。

暗号化すると、 `!vault |` から始まる複数行の文字列が出力されると思います。  

それではこちらを、`group_vars/web` に記載済みの変数 `password` の値に指定しましょう。

## 06-3 Playbookを実行してみる

Playbookを実行する前に、Playbookを軽く見てみましょう。

```yaml
---
- hosts: web
  become: yes
  tasks:
  - name: Create credential file
    ansible.builtin.template:
      src: ./templates/credential
      dest: /tmp/credential
      mode: '0644'

  - name: Create 'name_and_password' file
    ansible.builtin.file:
      path: /tmp/name_and_password
      mode: '0644'

  - name: Write name into 'name_and_password' file
    ansible.builtin.lineinfile:
      path: /tmp/name_and_password
      regexp: '^name='
      line: name={{ name }}

  - name: Write password into 'name_and_password' file
    ansible.builtin.lineinfile:
      path: /tmp/name_and_password
      regexp: '^password='
      line: password={{ password }}
```

先ほど作成した、`credential` ファイルを `/tmp` 以下に、`/tmp/name_and_password` ファイルに `group_vars/web` に指定した `password` 変数を書き出すようになっています。

今回のPlaybookがどのような処理を行うか把握したら、実際にPlaybookを実行してみましょう。

```sh
# 起動までは前節で準備済みを想定
# Ansibleを実行するコンテナに入ります
docker-compose exec control_node bash

# AnsibleでPlaybookを実行します（Volumeが設定されているので、コンテナ内でも編集した設定ファイルが利用可能です）
ansible-playbook server.yml -i hosts --ask-vault-pass
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

# ファイルができているか確認する
ls /tmp

# 各ファイルの中身を見てみる
cat /tmp/credential
cat /tmp/name_and_password
```

どうだったでしょうか？  
想定通りにファイルが作成できているでしょうか？

ここまでで、Practice07 は終わりになります。

最後にdockerコンテナを終了しておきましょう（以降の内容を実行する場合は、それらを実行後に行ってください）。

```
docker-compose down -rmi local
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

  File /tmp/credential
     ✔  is expected to exist
     ✔  content is expected to match /CREDENTIAL_FILE/
  File /tmp/name_and_password
     ✔  is expected to exist
     ✔  content is expected to match /name=foo/
     ✔  content is expected to match /password=secret_string/

Test Summary: 5 successful, 0 failures, 0 skipped
```
